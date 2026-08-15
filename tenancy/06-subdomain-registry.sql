/*
    A clinic may be renamed, but its old name is never given away.

    The subdomain is how a request without a token is traced to a clinic, so it ends
    up in bookmarks, in saved links, in emails and in whatever a receptionist typed
    into their browser two years ago. Two consequences follow.

    First, a retired subdomain must never be reissued to a different clinic. If
    'healandcare' were freed and handed to somebody else, a stale link would land a
    member of staff on another clinic's sign-in page — looking, to them, entirely
    correct. That is the failure this table exists to make impossible.

    Second, a retired subdomain should keep working. Renaming a clinic is not a
    reason to break every link anyone holds.

    So every subdomain a clinic has ever held is recorded here, with the current one
    flagged. The UNIQUE constraint spans current and retired alike, which is what
    makes reuse impossible rather than merely discouraged. tenants.subdomain stays as
    the current value because everything already reads it; this table is the registry
    behind it, and the two are written together in one transaction.

    Also tightens the format check. The existing one only rejected characters outside
    a-z0-9-, so it admitted 'SUNRISE', 'ab', '-lead' and 'trail-'. The full rule lived
    only in the application, which was fine while provisioning was the only writer and
    would stop being fine the day somebody added an edit screen.

    Run AFTER 05-updated-at-nullable.sql. Idempotent.
*/
SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;
SET XACT_ABORT ON;
GO

------------------------------------------------------------------ the registry
IF OBJECT_ID('dbo.tenant_subdomains') IS NULL
BEGIN
    CREATE TABLE dbo.tenant_subdomains
    (
        tenant_subdomain_id INT IDENTITY(1,1) NOT NULL,
        tenant_id           INT           NOT NULL,
        subdomain           NVARCHAR(63)  NOT NULL,
        is_current          BIT           NOT NULL CONSTRAINT DF_tenant_subdomains_current DEFAULT (1),
        assigned_at         DATETIME2(7)  NOT NULL CONSTRAINT DF_tenant_subdomains_assigned DEFAULT (SYSUTCDATETIME()),
        retired_at          DATETIME2(7)  NULL,
        assigned_by         NVARCHAR(100) NULL,
        retired_reason      NVARCHAR(400) NULL,

        CONSTRAINT PK_tenant_subdomains PRIMARY KEY CLUSTERED (tenant_subdomain_id),

        -- Spans current and retired. This is the constraint that makes a retired
        -- name unusable by anybody else, which is the whole point of the table.
        CONSTRAINT UQ_tenant_subdomains_subdomain UNIQUE (subdomain),

        CONSTRAINT FK_tenant_subdomains_tenant FOREIGN KEY (tenant_id)
            REFERENCES dbo.tenants (tenant_id) ON DELETE CASCADE
    );

    PRINT '  dbo.tenant_subdomains created';
END
GO

-- A clinic has exactly one current subdomain. Anything else means a rename went
-- half-finished, and the resolver would have to guess.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_tenant_subdomains_one_current'
               AND object_id = OBJECT_ID('dbo.tenant_subdomains'))
    CREATE UNIQUE INDEX UX_tenant_subdomains_one_current
        ON dbo.tenant_subdomains (tenant_id) WHERE is_current = 1;
GO

-- Resolving a request reads this on the way in.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_tenant_subdomains_lookup'
               AND object_id = OBJECT_ID('dbo.tenant_subdomains'))
    CREATE INDEX IX_tenant_subdomains_lookup
        ON dbo.tenant_subdomains (subdomain) INCLUDE (tenant_id, is_current);
GO

------------------------------------------------------------------ backfill
INSERT INTO dbo.tenant_subdomains (tenant_id, subdomain, is_current, assigned_by)
SELECT t.tenant_id, t.subdomain, 1, N'migration'
FROM dbo.tenants t
WHERE NOT EXISTS (SELECT 1 FROM dbo.tenant_subdomains s WHERE s.tenant_id = t.tenant_id);
GO

------------------------------------------------------------------ format
-- Lowercase letters, digits and hyphens; starts and ends alphanumeric; 3 to 63 long.
-- Written with COLLATE because the database is case-insensitive, so a plain [a-z]
-- range silently matches uppercase too — which is exactly how 'SUNRISE' got through
-- the previous constraint.
IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_tenants_subdomain')
    ALTER TABLE dbo.tenants DROP CONSTRAINT CK_tenants_subdomain;
GO

ALTER TABLE dbo.tenants WITH NOCHECK ADD CONSTRAINT CK_tenants_subdomain CHECK
(
        LEN(subdomain) >= 3
    AND subdomain COLLATE Latin1_General_BIN2 NOT LIKE '%[^a-z0-9-]%'
    AND subdomain COLLATE Latin1_General_BIN2 NOT LIKE '-%'
    AND subdomain COLLATE Latin1_General_BIN2 NOT LIKE '%-'
);
GO

IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_tenant_subdomains_format')
    ALTER TABLE dbo.tenant_subdomains DROP CONSTRAINT CK_tenant_subdomains_format;
GO

ALTER TABLE dbo.tenant_subdomains ADD CONSTRAINT CK_tenant_subdomains_format CHECK
(
        LEN(subdomain) >= 3
    AND subdomain COLLATE Latin1_General_BIN2 NOT LIKE '%[^a-z0-9-]%'
    AND subdomain COLLATE Latin1_General_BIN2 NOT LIKE '-%'
    AND subdomain COLLATE Latin1_General_BIN2 NOT LIKE '%-'
);
GO

------------------------------------------------------------------ report
SELECT 'subdomains on record : ' + CAST(COUNT(*) AS VARCHAR) FROM dbo.tenant_subdomains;

SELECT 'clinics without a current subdomain : ' + CAST(COUNT(*) AS VARCHAR) + '   (expected 0)'
FROM dbo.tenants t
WHERE NOT EXISTS (SELECT 1 FROM dbo.tenant_subdomains s
                  WHERE s.tenant_id = t.tenant_id AND s.is_current = 1);

-- Proves the tightened rule rejects what the old one let through.
SELECT v.code + REPLICATE(' ', 12 - LEN(v.code)) + ' -> '
     + CASE WHEN LEN(v.code) >= 3
             AND v.code COLLATE Latin1_General_BIN2 NOT LIKE '%[^a-z0-9-]%'
             AND v.code COLLATE Latin1_General_BIN2 NOT LIKE '-%'
             AND v.code COLLATE Latin1_General_BIN2 NOT LIKE '%-'
            THEN 'accepted' ELSE 'rejected' END
FROM (VALUES ('sunrise'),('SUNRISE'),('ab'),('-lead'),('trail-'),('dot.com'),('a-b-c')) AS v(code);
