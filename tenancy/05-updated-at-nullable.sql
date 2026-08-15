/*
    updated_at means "when this row was last changed", and a row that has never been
    changed has no such moment.

    Most tables already model it that way and leave the column nullable. Forty-two do
    not: they are NOT NULL with a default of the current time, which quietly records
    every new row as having been updated at the moment it was created.

    The defect this hides is not cosmetic. Entity Framework sends the column
    explicitly, so the default never applies — it sends NULL, and the insert fails
    outright. Nothing had noticed because no code path inserted into these tables
    through the application until clinics began to be provisioned through it, at
    which point creating a clinic failed on access_levels.

    Making them nullable brings the whole schema in line with the tables that already
    were, and with the entities. The defaults are left in place for anything that
    inserts without naming the column; existing values are untouched.

    Run AFTER 04-user-branches.sql. Idempotent.
*/
SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;
SET XACT_ABORT ON;
GO

DECLARE @sql NVARCHAR(MAX) = N'';
DECLARE @count INT = 0;

SELECT @sql = @sql + N'ALTER TABLE dbo.' + QUOTENAME(t.name) +
                     N' ALTER COLUMN updated_at DATETIME2(7) NULL;' + CHAR(10),
       @count = @count + 1
FROM sys.columns c
JOIN sys.tables t ON t.object_id = c.object_id
WHERE c.name = 'updated_at'
  AND c.is_nullable = 0
  AND SCHEMA_NAME(t.schema_id) = 'dbo'
  -- A column an index depends on cannot be altered in place. None currently are,
  -- and if one ever is, this says so rather than failing halfway through.
  AND NOT EXISTS (SELECT 1 FROM sys.index_columns ic
                  WHERE ic.object_id = c.object_id AND ic.column_id = c.column_id);

IF @count = 0
    PRINT '  nothing to do: updated_at is already nullable everywhere';
ELSE
BEGIN
    PRINT '  making updated_at nullable on ' + CAST(@count AS VARCHAR) + ' tables';
    EXEC sp_executesql @sql;
END
GO

------------------------------------------------------------------ report
SELECT 'tables with updated_at NOT NULL : ' + CAST(COUNT(*) AS VARCHAR) + '   (expected 0)'
FROM sys.columns c
JOIN sys.tables t ON t.object_id = c.object_id
WHERE c.name = 'updated_at' AND c.is_nullable = 0 AND SCHEMA_NAME(t.schema_id) = 'dbo';

SELECT 'tables with updated_at at all   : ' + CAST(COUNT(*) AS VARCHAR)
FROM sys.columns c
JOIN sys.tables t ON t.object_id = c.object_id
WHERE c.name = 'updated_at' AND SCHEMA_NAME(t.schema_id) = 'dbo';
