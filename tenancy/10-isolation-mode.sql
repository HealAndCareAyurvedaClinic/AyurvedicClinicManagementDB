/*
    Where a clinic's data lives.

        Shared             this database, alongside every other clinic, kept apart
                           by tenant_id and the query filters
        DedicatedDatabase  a database of its own, for a customer whose contract or
                           regulator requires it

    Every clinic is Shared today and nothing routes anywhere else. This column
    exists so that when routing is built, the answer for each clinic is already
    recorded rather than being inferred from a list somebody maintains by hand.

    The obvious risk with a flag nothing reads is that somebody sets it, believes
    it, and carries on — a clinic marked DedicatedDatabase while its data quietly
    stays in the shared one, which is precisely the promise that flag makes to a
    customer. So the application refuses to serve any clinic that is not Shared
    rather than serving it from here. The flag is inert, but it is not a lie.

    Run AFTER 09-audit-platform-changes.sql. Idempotent.
*/
SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;
SET XACT_ABORT ON;
GO

IF COL_LENGTH('dbo.tenants', 'isolation_mode') IS NULL
BEGIN
    ALTER TABLE dbo.tenants ADD isolation_mode NVARCHAR(20) NULL;
    PRINT '  tenants.isolation_mode added';
END
GO

UPDATE dbo.tenants SET isolation_mode = N'Shared' WHERE isolation_mode IS NULL;
GO

ALTER TABLE dbo.tenants ALTER COLUMN isolation_mode NVARCHAR(20) NOT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = 'DF_tenants_isolation_mode')
    ALTER TABLE dbo.tenants ADD CONSTRAINT DF_tenants_isolation_mode
        DEFAULT (N'Shared') FOR isolation_mode;
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_tenants_isolation_mode')
    ALTER TABLE dbo.tenants ADD CONSTRAINT CK_tenants_isolation_mode
        CHECK (isolation_mode IN (N'Shared', N'DedicatedDatabase'));
GO

------------------------------------------------------------------ report
SELECT 'clinics by isolation : ' + isolation_mode + ' = ' + CAST(COUNT(*) AS VARCHAR)
FROM dbo.tenants GROUP BY isolation_mode;

SELECT 'default for a new clinic : ' +
       ISNULL((SELECT REPLACE(REPLACE(dc.definition, '(N''', ''), ''')', '')
               FROM sys.default_constraints dc WHERE dc.name = 'DF_tenants_isolation_mode'), 'MISSING');
