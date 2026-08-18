/*
    Reset the test database to the baseline. This is the button to press between
    test cycles.

    Everything created since the snapshot is discarded: patients registered by
    test cases, bills, appointments, stock movements, defect reproductions. That
    is the point - cycle two must not run on cycle one's leftovers.

    Stop the API first, or it will hold a connection and the restore will wait.
    The rollback below closes connections anyway, but an API that was mid-request
    is better restarted afterwards.

    Run from the master database. Takes a few seconds.
*/
SET NOCOUNT ON;

DECLARE @db SYSNAME = N'AyurvedicClinicMgmt_Test';
DECLARE @path NVARCHAR(300) = CAST(SERVERPROPERTY('InstanceDefaultBackupPath') AS NVARCHAR(300));
-- The server does not always report a trailing separator.
IF RIGHT(@path, 1) NOT IN (N'\', N'/') SET @path = @path + N'\';
DECLARE @file NVARCHAR(400) = @path + N'test-baseline.bak';

IF DB_ID(@db) IS NULL
BEGIN
    RAISERROR('The test database does not exist. Create it and seed it first (see README).', 16, 1);
    RETURN;
END

-- Refuse rather than restore over the wrong database.
IF @db NOT LIKE '%[_]Test'
BEGIN
    RAISERROR('REFUSED: reset only runs against a database whose name ends in _Test.', 16, 1);
    RETURN;
END

PRINT 'Closing connections to ' + @db + ' ...';
DECLARE @sql NVARCHAR(MAX) =
    N'ALTER DATABASE ' + QUOTENAME(@db) + N' SET SINGLE_USER WITH ROLLBACK IMMEDIATE;';
EXEC sp_executesql @sql;

PRINT 'Restoring the baseline ...';
SET @sql = N'RESTORE DATABASE ' + QUOTENAME(@db) + N' FROM DISK = @f WITH REPLACE, RECOVERY;';
BEGIN TRY
    EXEC sp_executesql @sql, N'@f NVARCHAR(400)', @f = @file;
END TRY
BEGIN CATCH
    -- Never leave the database in single-user mode, or nobody can reach it.
    SET @sql = N'ALTER DATABASE ' + QUOTENAME(@db) + N' SET MULTI_USER;';
    EXEC sp_executesql @sql;
    THROW;
END CATCH

SET @sql = N'ALTER DATABASE ' + QUOTENAME(@db) + N' SET MULTI_USER;';
EXEC sp_executesql @sql;

------------------------------------------------------------------ confirm
SELECT 'reset complete   : ' + @db;
SELECT 'patients         : ' + CAST(COUNT(*) AS VARCHAR) + '   (baseline is 5)'
FROM AyurvedicClinicMgmt_Test.dbo.patients;
SELECT 'logins           : ' + CAST(COUNT(*) AS VARCHAR) + '   (baseline is 6)'
FROM AyurvedicClinicMgmt_Test.dbo.users;
SELECT 'bills / payments : ' + CAST((SELECT COUNT(*) FROM AyurvedicClinicMgmt_Test.dbo.bills) AS VARCHAR)
     + ' / ' + CAST((SELECT COUNT(*) FROM AyurvedicClinicMgmt_Test.dbo.payments) AS VARCHAR)
     + '   (baseline is 0 / 0)';
SELECT 'left over from a test run: ' + CAST(COUNT(*) AS VARCHAR) + '   (should be 0)'
FROM AyurvedicClinicMgmt_Test.dbo.patients
WHERE registration_number NOT LIKE 'REG-T-%';
