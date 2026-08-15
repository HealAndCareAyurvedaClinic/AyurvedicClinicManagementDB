/*
    A clinic's place in its lifecycle, rather than a yes/no.

    is_active could say only "usable" or "not usable", which conflated three quite
    different situations: a clinic being set up and not open yet, a clinic stopped
    for non-payment and expected back, and a clinic that has left. Support cannot
    tell them apart, and none of them can be reported on.

        Pending      onboarding is not finished; the clinic has never been used
        Active       open for business — the only status that can be used
        Suspended    stopped, and expected to come back
        Deactivated  the relationship has ended; the data is kept

    is_active is replaced rather than kept alongside. Two columns that must agree
    eventually disagree, and then nobody knows which one is right. Only two places
    in the application read it, both of which move to status in the same change.

    No history table. Every change to a clinic row already goes to audit_log with
    its old and new values, so the trail exists; a second one would be a second
    thing to keep correct. status_reason and status_changed_at are kept on the row
    because "why is this clinic suspended" is asked far too often to be worth a
    join into the audit trail.

    Run AFTER 06-subdomain-registry.sql. Idempotent.
*/
SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;
SET XACT_ABORT ON;
GO

IF COL_LENGTH('dbo.tenants', 'status') IS NULL
BEGIN
    ALTER TABLE dbo.tenants ADD status NVARCHAR(20) NULL;
    PRINT '  tenants.status added';
END
GO

IF COL_LENGTH('dbo.tenants', 'status_changed_at') IS NULL
    ALTER TABLE dbo.tenants ADD status_changed_at DATETIME2(7) NULL;
GO

IF COL_LENGTH('dbo.tenants', 'status_reason') IS NULL
    ALTER TABLE dbo.tenants ADD status_reason NVARCHAR(400) NULL;
GO

------------------------------------------------------------------ backfill
-- Everything that was usable becomes Active. Everything that was not becomes
-- Suspended rather than Deactivated: a clinic that was switched off is far more
-- likely to be coming back than gone, and Suspended is the recoverable reading.
IF COL_LENGTH('dbo.tenants', 'is_active') IS NOT NULL
BEGIN
    UPDATE dbo.tenants
    SET    status            = CASE WHEN is_active = 1 THEN N'Active' ELSE N'Suspended' END,
           status_changed_at = ISNULL(status_changed_at, SYSUTCDATETIME()),
           status_reason     = ISNULL(status_reason, N'Set by the lifecycle migration')
    WHERE  status IS NULL;
END
ELSE
BEGIN
    UPDATE dbo.tenants
    SET    status            = N'Active',
           status_changed_at = ISNULL(status_changed_at, SYSUTCDATETIME())
    WHERE  status IS NULL;
END
GO

ALTER TABLE dbo.tenants ALTER COLUMN status NVARCHAR(20) NOT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = 'DF_tenants_status')
    ALTER TABLE dbo.tenants ADD CONSTRAINT DF_tenants_status DEFAULT (N'Pending') FOR status;
GO

-- A clinic created without saying otherwise has not been set up yet. Provisioning
-- says otherwise explicitly, because it creates a clinic that is ready to use.
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_tenants_status')
    ALTER TABLE dbo.tenants ADD CONSTRAINT CK_tenants_status
        CHECK (status IN (N'Pending', N'Active', N'Suspended', N'Deactivated'));
GO

------------------------------------------------------------------ retire is_active
IF COL_LENGTH('dbo.tenants', 'is_active') IS NOT NULL
BEGIN
    DECLARE @default SYSNAME = (SELECT dc.name FROM sys.default_constraints dc
                                JOIN sys.columns c ON c.default_object_id = dc.object_id
                                WHERE c.object_id = OBJECT_ID('dbo.tenants') AND c.name = 'is_active');

    IF @default IS NOT NULL
    BEGIN
        DECLARE @drop NVARCHAR(500) = N'ALTER TABLE dbo.tenants DROP CONSTRAINT ' + QUOTENAME(@default);
        EXEC sp_executesql @drop;
    END

    ALTER TABLE dbo.tenants DROP COLUMN is_active;
    PRINT '  tenants.is_active dropped — status replaces it';
END
GO

-- "Which clinics are suspended" is a support question, so it gets an index.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_tenants_status'
               AND object_id = OBJECT_ID('dbo.tenants'))
    CREATE INDEX IX_tenants_status ON dbo.tenants (status) INCLUDE (tenant_name, subdomain);
GO

------------------------------------------------------------------ report
SELECT 'clinics by status : ' + status + ' = ' + CAST(COUNT(*) AS VARCHAR)
FROM dbo.tenants GROUP BY status;

SELECT 'is_active column  : ' +
       CASE WHEN COL_LENGTH('dbo.tenants','is_active') IS NULL THEN 'gone (correct)' ELSE 'STILL PRESENT' END;
