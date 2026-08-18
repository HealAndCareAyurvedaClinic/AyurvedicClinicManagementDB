/*
    One numbering series per clinic, allocated without collisions.

    Bill, receipt and registration numbers were produced by reading the highest one
    that existed and adding one. Two people billing in the same second read the same
    highest number, and the second write fails on the unique constraint — or, before
    that constraint was scoped per clinic, quietly took a number that was already in
    use.

    Two branches make that likelier rather than new. The clinic runs one series across
    its branches, which is what was decided, so both counters now push against the
    same row instead of against separate ones.

    The allocation is a single UPDATE that returns the value it replaced. Under SQL
    Server that takes an exclusive lock on the row for the length of the statement, so
    two callers are serialised by the database rather than by hope. No SELECT-then-
    UPDATE, because that is the pattern being replaced.

    period_key is what makes a series restart: 'yyyyMMdd' for numbers that begin again
    each day, and '' for one that runs forever. It is part of the key rather than
    computed here, so the application decides the shape and this table only counts.

    Run AFTER 11-clinic-timezone.sql. Idempotent.
*/
SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;
SET XACT_ABORT ON;
GO

IF OBJECT_ID('dbo.number_series') IS NULL
BEGIN
    CREATE TABLE dbo.number_series
    (
        series_id   INT IDENTITY(1,1) NOT NULL,
        tenant_id   INT           NOT NULL,

        -- What is being numbered: 'bill', 'payment', 'registration'.
        series_key  NVARCHAR(40)  NOT NULL,

        -- When it restarts. 'yyyyMMdd' for a daily series, '' for a continuous one.
        period_key  NVARCHAR(20)  NOT NULL,

        next_value  INT           NOT NULL CONSTRAINT DF_number_series_next DEFAULT (1),
        updated_at  DATETIME2(7)  NOT NULL CONSTRAINT DF_number_series_updated DEFAULT (SYSUTCDATETIME()),

        CONSTRAINT PK_number_series PRIMARY KEY CLUSTERED (series_id),

        -- One counter per clinic per series per period. This is also the row the
        -- allocation locks, so it has to be exactly one.
        CONSTRAINT UQ_number_series UNIQUE (tenant_id, series_key, period_key),

        CONSTRAINT FK_number_series_tenant FOREIGN KEY (tenant_id)
            REFERENCES dbo.tenants (tenant_id) ON DELETE CASCADE,

        CONSTRAINT CK_number_series_next CHECK (next_value >= 1)
    );

    PRINT '  dbo.number_series created';
END
GO

/*
    Seeds each clinic's counters past whatever it has already issued, so the first
    number allocated after this runs cannot repeat one that is already on a bill.
    Reading the existing maximum is safe here precisely because this runs once,
    before anything is using the table.
*/
IF NOT EXISTS (SELECT 1 FROM dbo.number_series)
BEGIN
    -- Bills: BILL-yyyyMMdd-NNN, restarting daily.
    INSERT INTO dbo.number_series (tenant_id, series_key, period_key, next_value)
    SELECT b.tenant_id,
           N'bill',
           FORMAT(b.bill_date, 'yyyyMMdd'),
           MAX(TRY_CONVERT(INT, RIGHT(b.bill_number, 3))) + 1
    FROM dbo.bills b
    WHERE b.bill_number LIKE '%-%-%'
      AND TRY_CONVERT(INT, RIGHT(b.bill_number, 3)) IS NOT NULL
    GROUP BY b.tenant_id, FORMAT(b.bill_date, 'yyyyMMdd');

    -- Registrations: REG-yyyyMMdd-NNNN, restarting daily.
    INSERT INTO dbo.number_series (tenant_id, series_key, period_key, next_value)
    SELECT p.tenant_id,
           N'registration',
           SUBSTRING(p.registration_number, 5, 8),
           MAX(TRY_CONVERT(INT, RIGHT(p.registration_number, 4))) + 1
    FROM dbo.patients p
    WHERE p.registration_number LIKE 'REG-________-%'
      AND TRY_CONVERT(INT, RIGHT(p.registration_number, 4)) IS NOT NULL
    GROUP BY p.tenant_id, SUBSTRING(p.registration_number, 5, 8);

    PRINT '  counters seeded past the numbers already issued';
END
GO

------------------------------------------------------------------ report
SELECT 'counters : ' + CAST(COUNT(*) AS VARCHAR) FROM dbo.number_series;

SELECT '  ' + series_key + ' ' + period_key + ' -> next ' + CAST(next_value AS VARCHAR)
FROM dbo.number_series
ORDER BY series_key, period_key;
