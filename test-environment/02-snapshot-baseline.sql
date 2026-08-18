/*
    Take the snapshot that "reset" restores from.

    Run this ONCE after seeding the baseline, and again whenever the baseline is
    deliberately changed - a new medicine everyone needs, an extra login. Do not
    run it after a test cycle, or the cycle's leftovers become the new baseline.

    Run from the master database.
*/
SET NOCOUNT ON;

DECLARE @db SYSNAME = N'AyurvedicClinicMgmt_Test';
DECLARE @path NVARCHAR(300) = CAST(SERVERPROPERTY('InstanceDefaultBackupPath') AS NVARCHAR(300));
-- The server does not always report a trailing separator.
IF RIGHT(@path, 1) NOT IN (N'\', N'/') SET @path = @path + N'\';
DECLARE @file NVARCHAR(400) = @path + N'test-baseline.bak';

IF DB_ID(@db) IS NULL
BEGIN
    RAISERROR('The test database does not exist. Create it first (see README).', 16, 1);
    RETURN;
END

DECLARE @sql NVARCHAR(MAX) = N'
BACKUP DATABASE ' + QUOTENAME(@db) + N' TO DISK = @f
WITH INIT, FORMAT, COPY_ONLY, COMPRESSION,
     NAME = ''Manual test baseline'',
     DESCRIPTION = ''Known starting state for a manual test cycle'';';

EXEC sp_executesql @sql, N'@f NVARCHAR(400)', @f = @file;

SELECT 'snapshot written to: ' + @file;
SELECT 'patients in the snapshot: ' + CAST(COUNT(*) AS VARCHAR)
FROM AyurvedicClinicMgmt_Test.dbo.patients;
