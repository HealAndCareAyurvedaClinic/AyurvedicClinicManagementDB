/*
    One normalised line per schema fact, ordered deterministically, so that two
    databases can be compared with an ordinary text diff.

    Run it against each database, send each output to a file, diff the files. There is
    a Compare-Schema.ps1 beside this file that does exactly that; the raw form is:

        sqlcmd -S <A> -d <dbA> -C -b -y0 -i deploy/schema-fingerprint.sql > a.txt
        sqlcmd -S <B> -d <dbB> -C -b -y0 -i deploy/schema-fingerprint.sql > b.txt
        diff a.txt b.txt

    -y0 stops sqlcmd truncating CHECK expressions and view bodies at 256 characters,
    which would hide the very differences being looked for. Note that -y0 cannot be
    combined with -h -1, so the two header lines are still emitted and have to be
    dropped (Compare-Schema.ps1 does this); -W cannot be combined with it either.

    ------------------------------------------------------------------ why not names

    192 of this schema's 252 column defaults are unnamed, so SQL Server names them
    with a hash of the object id -- DF__access_gr__creat__38996AB5 -- and that name
    differs in every database. The same is true of some CHECK constraints. Keying a
    diff on constraint names therefore reports every default as changed, in both
    directions, and the real difference drowns in the noise.

    So nothing here is keyed on an auto-generated name. A default is identified by
    the column it sits on and what it does; a CHECK by its table and its
    expression. Names appear only where this schema assigns them deliberately
    (FK_*, UQ_*, IX_*, PK_*), because there a rename is a real difference worth
    seeing.

    ------------------------------------------------------------------ what it skips

    dbo.schema_versions, the migration ledger. It is created by Apply-Database.ps1
    rather than by a migration, its contents differ between environments by design,
    and -- as the consultation_fee and staff_id outages both showed -- it can
    disagree with the schema around it. Comparing schemas means comparing the
    schema, not what a database claims about itself. Compare the ledgers separately
    and deliberately:

        SELECT script_name FROM dbo.schema_versions ORDER BY script_name;

    ------------------------------------------------------------------ two traps met

    COLLATE DATABASE_DEFAULT on every definition column is load-bearing.
    sys.sql_modules.definition and sysname carry different collations
    (SQL_Latin1_General_CP1_CI_AS and Latin1_General_CI_AS_KS_WS on the local
    server), and concatenating the two yields an expression with NO collation. That
    is legal right up until something has to sort it -- so the query failed on the
    final ORDER BY with 'Cannot resolve collation conflict', naming a line nowhere
    near the cause.

    Column lists are aggregated with STRING_AGG rather than the older
    FOR XML PATH('') idiom. FOR XML needs .value(), an XML data type method, and
    those are refused unless SET QUOTED_IDENTIFIER is ON -- which sqlcmd defaults
    OFF. That produces error 1934, the same misleading 'SET options have incorrect
    settings' complaint documented in tenancy/15-link-doctor-to-staff.sql.
    STRING_AGG needs no such thing, so this script runs under any client.
*/
SET NOCOUNT ON;

WITH facts AS (

    ---------------------------------------------------------------- tables
    SELECT CONCAT('1 TABLE  ', t.name) AS line
      FROM sys.tables t
     WHERE t.schema_id = SCHEMA_ID('dbo') AND t.name <> 'schema_versions'

    ---------------------------------------------------------------- columns
    UNION ALL
    SELECT CONCAT('2 COLUMN ', t.name, '.', c.name, ' ', ty.name,
           CASE
             WHEN ty.name IN ('varchar','char','varbinary','binary')
               THEN '(' + CASE WHEN c.max_length = -1 THEN 'max'
                               ELSE CAST(c.max_length AS varchar(11)) END + ')'
             WHEN ty.name IN ('nvarchar','nchar')
               THEN '(' + CASE WHEN c.max_length = -1 THEN 'max'
                               ELSE CAST(c.max_length / 2 AS varchar(11)) END + ')'
             WHEN ty.name IN ('decimal','numeric')
               THEN '(' + CAST(c.precision AS varchar(11)) + ','
                        + CAST(c.scale     AS varchar(11)) + ')'
             WHEN ty.name IN ('datetime2','time','datetimeoffset')
               THEN '(' + CAST(c.scale AS varchar(11)) + ')'
             ELSE '' END,
           CASE WHEN c.is_nullable  = 1 THEN ' NULL' ELSE ' NOT NULL' END,
           CASE WHEN c.is_identity  = 1 THEN ' IDENTITY' ELSE '' END,
           CASE WHEN c.is_computed  = 1 THEN ' COMPUTED' ELSE '' END,
           CASE WHEN c.collation_name IS NOT NULL
                 AND c.collation_name <> CONVERT(sysname, DATABASEPROPERTYEX(DB_NAME(), 'Collation'))
                THEN ' COLLATE ' + c.collation_name ELSE '' END)
      FROM sys.tables t
      JOIN sys.columns c ON c.object_id = t.object_id
      JOIN sys.types  ty ON ty.user_type_id = c.user_type_id
     WHERE t.schema_id = SCHEMA_ID('dbo') AND t.name <> 'schema_versions'

    ---------------------------------------------------------------- computed columns
    UNION ALL
    SELECT CONCAT('3 COMPUTED ', t.name, '.', c.name, ' AS ',
                  cc.definition COLLATE DATABASE_DEFAULT)
      FROM sys.tables t
      JOIN sys.columns c ON c.object_id = t.object_id
      JOIN sys.computed_columns cc ON cc.object_id = c.object_id
                                  AND cc.column_id = c.column_id
     WHERE t.schema_id = SCHEMA_ID('dbo') AND t.name <> 'schema_versions'

    ---------------------------------------------------------------- defaults
    -- Keyed on the column, never the name: 192 of these names are hashes.
    UNION ALL
    SELECT CONCAT('4 DEFAULT ', t.name, '.', c.name, ' = ',
                  d.definition COLLATE DATABASE_DEFAULT,
                  CASE WHEN d.name NOT LIKE 'DF[_][_]%' THEN ' [' + d.name + ']' ELSE '' END)
      FROM sys.tables t
      JOIN sys.columns c ON c.object_id = t.object_id
      JOIN sys.default_constraints d ON d.parent_object_id = t.object_id
                                    AND d.parent_column_id = c.column_id
     WHERE t.schema_id = SCHEMA_ID('dbo') AND t.name <> 'schema_versions'

    ---------------------------------------------------------------- check constraints
    -- Keyed on table + expression. A CHECK is its expression; some are auto-named.
    UNION ALL
    SELECT CONCAT('5 CHECK   ', t.name, ' ', ck.definition COLLATE DATABASE_DEFAULT,
                  CASE WHEN ck.name NOT LIKE 'CK[_][_]%' THEN ' [' + ck.name + ']' ELSE '' END,
                  CASE WHEN ck.is_disabled    = 1 THEN ' DISABLED'    ELSE '' END,
                  CASE WHEN ck.is_not_trusted = 1 THEN ' NOT TRUSTED' ELSE '' END)
      FROM sys.tables t
      JOIN sys.check_constraints ck ON ck.parent_object_id = t.object_id
     WHERE t.schema_id = SCHEMA_ID('dbo') AND t.name <> 'schema_versions'

    ---------------------------------------------------------------- primary & unique keys
    UNION ALL
    SELECT CONCAT('6 ', CASE WHEN kc.type = 'PK' THEN 'PK      ' ELSE 'UQ      ' END,
                  t.name, ' [', kc.name, '] (',
                  (SELECT STRING_AGG(CONVERT(nvarchar(max), c2.name
                            + CASE WHEN ic.is_descending_key = 1 THEN ' DESC' ELSE '' END), ', ')
                            WITHIN GROUP (ORDER BY ic.key_ordinal)
                     FROM sys.index_columns ic
                     JOIN sys.columns c2 ON c2.object_id = ic.object_id
                                        AND c2.column_id = ic.column_id
                    WHERE ic.object_id = t.object_id AND ic.index_id = kc.unique_index_id), ')')
      FROM sys.tables t
      JOIN sys.key_constraints kc ON kc.parent_object_id = t.object_id
     WHERE t.schema_id = SCHEMA_ID('dbo') AND t.name <> 'schema_versions'

    ---------------------------------------------------------------- indexes
    -- Constraint-backed indexes are already reported above as PK/UQ.
    UNION ALL
    SELECT CONCAT('7 INDEX   ', t.name, ' [', i.name, ']',
                  CASE WHEN i.is_unique = 1 THEN ' UNIQUE' ELSE '' END, ' (',
                  (SELECT STRING_AGG(CONVERT(nvarchar(max), c2.name
                            + CASE WHEN ic.is_descending_key = 1 THEN ' DESC' ELSE '' END), ', ')
                            WITHIN GROUP (ORDER BY ic.key_ordinal)
                     FROM sys.index_columns ic
                     JOIN sys.columns c2 ON c2.object_id = ic.object_id
                                        AND c2.column_id = ic.column_id
                    WHERE ic.object_id = i.object_id AND ic.index_id = i.index_id
                      AND ic.is_included_column = 0), ')',
                  ISNULL(' INCLUDE (' +
                  (SELECT STRING_AGG(CONVERT(nvarchar(max), c2.name), ', ')
                            WITHIN GROUP (ORDER BY c2.name)
                     FROM sys.index_columns ic
                     JOIN sys.columns c2 ON c2.object_id = ic.object_id
                                        AND c2.column_id = ic.column_id
                    WHERE ic.object_id = i.object_id AND ic.index_id = i.index_id
                      AND ic.is_included_column = 1) + ')', ''),
                  ISNULL(' WHERE ' + i.filter_definition COLLATE DATABASE_DEFAULT, ''))
      FROM sys.tables t
      JOIN sys.indexes i ON i.object_id = t.object_id
     WHERE t.schema_id = SCHEMA_ID('dbo') AND t.name <> 'schema_versions'
       AND i.type_desc <> 'HEAP' AND i.is_primary_key = 0 AND i.is_unique_constraint = 0

    ---------------------------------------------------------------- foreign keys
    UNION ALL
    SELECT CONCAT('8 FK      ', t.name, ' [', fk.name, '] (',
                  (SELECT STRING_AGG(CONVERT(nvarchar(max), pc.name), ', ')
                            WITHIN GROUP (ORDER BY fkc.constraint_column_id)
                     FROM sys.foreign_key_columns fkc
                     JOIN sys.columns pc ON pc.object_id = fkc.parent_object_id
                                        AND pc.column_id = fkc.parent_column_id
                    WHERE fkc.constraint_object_id = fk.object_id),
                  ') -> ', rt.name, ' (',
                  (SELECT STRING_AGG(CONVERT(nvarchar(max), rc.name), ', ')
                            WITHIN GROUP (ORDER BY fkc.constraint_column_id)
                     FROM sys.foreign_key_columns fkc
                     JOIN sys.columns rc ON rc.object_id = fkc.referenced_object_id
                                        AND rc.column_id = fkc.referenced_column_id
                    WHERE fkc.constraint_object_id = fk.object_id), ')',
                  ' ON DELETE ', REPLACE(fk.delete_referential_action_desc, '_', ' '),
                  ' ON UPDATE ', REPLACE(fk.update_referential_action_desc, '_', ' '),
                  CASE WHEN fk.is_disabled    = 1 THEN ' DISABLED'    ELSE '' END,
                  CASE WHEN fk.is_not_trusted = 1 THEN ' NOT TRUSTED' ELSE '' END)
      FROM sys.tables t
      JOIN sys.foreign_keys fk ON fk.parent_object_id = t.object_id
      JOIN sys.tables rt ON rt.object_id = fk.referenced_object_id
     WHERE t.schema_id = SCHEMA_ID('dbo') AND t.name <> 'schema_versions'

    ---------------------------------------------------------------- programmable objects
    -- Views, procedures, functions and triggers, by body. Runs of whitespace are
    -- squeezed so a reindent is not reported as a change.
    UNION ALL
    SELECT CONCAT('9 ', UPPER(LEFT(o.type_desc, 12)), ' ', o.name, ' ',
                  REPLACE(REPLACE(REPLACE(REPLACE(m.definition COLLATE DATABASE_DEFAULT,
                      CHAR(13), ' '), CHAR(10), ' '), CHAR(9), ' '), '  ', ' '))
      FROM sys.objects o
      JOIN sys.sql_modules m ON m.object_id = o.object_id
     WHERE o.schema_id = SCHEMA_ID('dbo')
       AND o.type IN ('V', 'P', 'FN', 'IF', 'TF', 'TR')
)
SELECT line FROM facts ORDER BY line;
