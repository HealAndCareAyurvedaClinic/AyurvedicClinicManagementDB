/*
    Some changes belong to no clinic.

    The audit trail was built on the assumption that every change happens inside a
    clinic, so audit_log.tenant_id was mandatory. That holds for everything a clinic
    does and fails for everything the platform does to shared data — the price list
    being the first case to arrive.

    The failure was worse than a refusal. The row was written, committed, and only
    then did the audit row fail, so the caller was told the plan already existed
    while the plan sat in the database. Three plans were created that way while
    every attempt reported a conflict.

    tenant_id therefore becomes nullable on audit_log alone, and null means exactly
    what it says: this change was not made inside any clinic. Clinics cannot see
    those rows — their filter compares tenant_id to their own id and null is never
    equal to anything — which is right, because the price list is not theirs.

    This is the only table where a null clinic is allowed, and it is allowed because
    an audit row describes a change rather than belonging to a clinic's data.

    Run AFTER 08-subscription-plans.sql. Idempotent.
*/
SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;
SET XACT_ABORT ON;
GO

IF EXISTS (SELECT 1 FROM sys.columns
           WHERE object_id = OBJECT_ID('dbo.audit_log') AND name = 'tenant_id' AND is_nullable = 0)
BEGIN
    -- Indexes lead on tenant_id, so they have to come off before the column can change.
    DECLARE @rebuild NVARCHAR(MAX) = N'';

    SELECT @rebuild = @rebuild +
           N'CREATE INDEX ' + QUOTENAME(i.name) + N' ON dbo.audit_log (' +
           STUFF((SELECT N', ' + QUOTENAME(c.name)
                  FROM sys.index_columns ic
                  JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
                  WHERE ic.object_id = i.object_id AND ic.index_id = i.index_id AND ic.is_included_column = 0
                  ORDER BY ic.key_ordinal
                  FOR XML PATH('')), 1, 2, '') + N');' + CHAR(10)
    FROM sys.indexes i
    WHERE i.object_id = OBJECT_ID('dbo.audit_log') AND i.is_primary_key = 0 AND i.name IS NOT NULL
      AND EXISTS (SELECT 1 FROM sys.index_columns ic
                  JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
                  WHERE ic.object_id = i.object_id AND ic.index_id = i.index_id AND c.name = 'tenant_id');

    DECLARE @drop NVARCHAR(MAX) = N'';

    SELECT @drop = @drop + N'DROP INDEX ' + QUOTENAME(i.name) + N' ON dbo.audit_log;' + CHAR(10)
    FROM sys.indexes i
    WHERE i.object_id = OBJECT_ID('dbo.audit_log') AND i.is_primary_key = 0 AND i.name IS NOT NULL
      AND EXISTS (SELECT 1 FROM sys.index_columns ic
                  JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
                  WHERE ic.object_id = i.object_id AND ic.index_id = i.index_id AND c.name = 'tenant_id');

    IF LEN(@drop) > 0 EXEC sp_executesql @drop;

    ALTER TABLE dbo.audit_log ALTER COLUMN tenant_id INT NULL;

    IF LEN(@rebuild) > 0 EXEC sp_executesql @rebuild;

    PRINT '  audit_log.tenant_id is now nullable — null means a platform change';
END
ELSE
    PRINT '  audit_log.tenant_id is already nullable';
GO

------------------------------------------------------------------ report
SELECT 'audit_log.tenant_id : ' +
       CASE WHEN EXISTS (SELECT 1 FROM sys.columns
                         WHERE object_id = OBJECT_ID('dbo.audit_log')
                           AND name = 'tenant_id' AND is_nullable = 1)
            THEN 'nullable (correct)' ELSE 'STILL MANDATORY' END;

SELECT 'tables where a null clinic is allowed : ' + CAST(COUNT(*) AS VARCHAR) + '   (expected 1)'
FROM sys.columns c
JOIN sys.tables t ON t.object_id = c.object_id
WHERE c.name = 'tenant_id' AND c.is_nullable = 1;

SELECT 'audit_log indexes : ' + CAST(COUNT(*) AS VARCHAR)
FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.audit_log') AND name IS NOT NULL;
