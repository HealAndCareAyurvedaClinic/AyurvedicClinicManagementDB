/*
    What "today" means for a clinic.

    Timestamps are already right: 63 columns default to SYSUTCDATETIME(), and the
    audit trail is UTC throughout. This is about the other kind of date — the one a
    person means. A bill dated the 15th, a registration number stamped REG-20260815,
    a batch that expires today. Those are the clinic's dates, not the server's.

    Today the application asks the server what day it is, and the server is in
    India, so the two agree. On Azure the server will be UTC, and they will stop
    agreeing for five and a half hours out of every twenty-four — the window in
    which a bill raised at 3am in Pune would be stamped with the previous day.

    Stored as an IANA identifier ('Asia/Kolkata') rather than a Windows one
    ('India Standard Time'), because IANA is the portable form and the deployment
    target is Linux. Verified that .NET 8 resolves IANA identifiers on Windows too,
    so a developer's machine behaves the same as production.

    Deliberately NOT added here: country and locale. Nothing on the server formats a
    date, a number or a currency — the browser does all of it, against the user's own
    locale, which is already correct. Columns nobody reads are a liability. See
    ADR 0005.

    Run AFTER 10-isolation-mode.sql. Idempotent.
*/
SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;
SET XACT_ABORT ON;
GO

IF COL_LENGTH('dbo.tenants', 'time_zone') IS NULL
BEGIN
    ALTER TABLE dbo.tenants ADD time_zone NVARCHAR(64) NULL;
    PRINT '  tenants.time_zone added';
END
GO

-- Every clinic is in India today, and the servers have been too, so this is what
-- they have been getting implicitly all along. Making it explicit changes nothing
-- now and stops it changing under them on Azure.
UPDATE dbo.tenants SET time_zone = N'Asia/Kolkata' WHERE time_zone IS NULL;
GO

ALTER TABLE dbo.tenants ALTER COLUMN time_zone NVARCHAR(64) NOT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = 'DF_tenants_time_zone')
    ALTER TABLE dbo.tenants ADD CONSTRAINT DF_tenants_time_zone
        DEFAULT (N'Asia/Kolkata') FOR time_zone;
GO

-- No CHECK constraint listing valid zones. The list is the operating system's, it
-- changes when governments change their minds, and a constraint written today would
-- start rejecting a legitimate zone the first time that happened. The application
-- validates against the runtime's own list instead, which is the list that matters.
GO

------------------------------------------------------------------ report
SELECT 'clinics by time zone : ' + time_zone + ' = ' + CAST(COUNT(*) AS VARCHAR)
FROM dbo.tenants GROUP BY time_zone;

SELECT 'default for a new clinic : ' +
       ISNULL((SELECT REPLACE(REPLACE(dc.definition, '(N''', ''), ''')', '')
               FROM sys.default_constraints dc WHERE dc.name = 'DF_tenants_time_zone'), 'MISSING');
