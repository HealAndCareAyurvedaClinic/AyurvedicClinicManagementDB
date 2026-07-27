/*
 RBAC seed data for the Heal & Care application.

 Password hashes below are real ASP.NET Core Identity PasswordHasher<T> (v3, PBKDF2-HMACSHA256)
 output, generated once via a throwaway console run against Microsoft.Extensions.Identity.Core —
 not reproducible in T-SQL, so they're pasted here as literals:
   admin     / admin123
   reception / reception123
 Change both passwords after first login in any real deployment.
*/

-- Idempotent: this whole block is skipped if the application row already exists, so
-- re-running this script against an already-seeded database (SSDT post-deploy scripts run
-- on every deploy) doesn't hit duplicate-key errors on applications/users/etc.
IF NOT EXISTS (SELECT 1 FROM [dbo].[applications] WHERE [code] = N'HEAL_AND_CARE')
BEGIN
    DECLARE @applicationId INT;

    INSERT INTO [dbo].[applications] ([code], [name])
    VALUES (N'HEAL_AND_CARE', N'Heal & Care - Ayurvedic Clinic Management');

    SET @applicationId = SCOPE_IDENTITY();

    INSERT INTO [dbo].[permissions] ([application_id], [code], [description])
    VALUES
        (@applicationId, N'PATIENTS_VIEW',     N'View patient records'),
        (@applicationId, N'PATIENTS_MANAGE',   N'Create and edit patient records'),
        (@applicationId, N'STAFF_VIEW',        N'View staff directory'),
        (@applicationId, N'STAFF_MANAGE',      N'Create and edit staff records'),
        (@applicationId, N'STAFF_DEACTIVATE',  N'Deactivate a staff member'),
        (@applicationId, N'BILLS_VIEW',        N'View bills'),
        (@applicationId, N'BILLS_MANAGE',      N'Create and edit bills'),
        (@applicationId, N'INVENTORY_MANAGE',  N'Create and edit inventory stock batches');

    INSERT INTO [dbo].[roles] ([application_id], [name], [description])
    VALUES
        (@applicationId, N'Administrator', N'Full access across all demoed modules'),
        (@applicationId, N'Receptionist',  N'Front-desk access: patients and billing');

    INSERT INTO [dbo].[role_permissions] ([role_id], [permission_id])
    SELECT r.[role_id], p.[permission_id]
    FROM [dbo].[roles] r
    CROSS JOIN [dbo].[permissions] p
    WHERE r.[application_id] = @applicationId
      AND p.[application_id] = @applicationId
      AND r.[name] = N'Administrator';

    INSERT INTO [dbo].[role_permissions] ([role_id], [permission_id])
    SELECT r.[role_id], p.[permission_id]
    FROM [dbo].[roles] r
    CROSS JOIN [dbo].[permissions] p
    WHERE r.[application_id] = @applicationId
      AND p.[application_id] = @applicationId
      AND r.[name] = N'Receptionist'
      AND p.[code] IN (N'PATIENTS_VIEW', N'PATIENTS_MANAGE', N'BILLS_VIEW', N'BILLS_MANAGE');

    INSERT INTO [dbo].[users] ([username], [password_hash])
    VALUES
        (N'admin',     N'AQAAAAIAAYagAAAAEIIZKtvjh0+z7fz4ckn1j9q8rUH/bBolHqSr1kIODgADHEuxchv98S9k8vES+BXiCw=='),
        (N'reception', N'AQAAAAIAAYagAAAAEIQYU94jXY6YQmUMMjSFdTac3vsp8r1O4XkKFy3YixnbwjAHI8ChEj0rz3lI7/5aHw==');

    INSERT INTO [dbo].[user_roles] ([user_id], [role_id])
    SELECT u.[user_id], r.[role_id]
    FROM [dbo].[users] u
    CROSS JOIN [dbo].[roles] r
    WHERE u.[username] = N'admin'
      AND r.[application_id] = @applicationId
      AND r.[name] = N'Administrator';

    INSERT INTO [dbo].[user_roles] ([user_id], [role_id])
    SELECT u.[user_id], r.[role_id]
    FROM [dbo].[users] u
    CROSS JOIN [dbo].[roles] r
    WHERE u.[username] = N'reception'
      AND r.[application_id] = @applicationId
      AND r.[name] = N'Receptionist';
END

/*
 Added for the admin User Management screen: gates the Users/Roles/Permissions admin
 endpoints and the sidebar link to reach them. Independently guarded (not inside the
 HEAL_AND_CARE existence check above) so it still applies to databases that were already
 seeded before this permission was added.
*/
IF NOT EXISTS (
    SELECT 1 FROM [dbo].[permissions] p
    JOIN [dbo].[applications] a ON a.[application_id] = p.[application_id]
    WHERE a.[code] = N'HEAL_AND_CARE' AND p.[code] = N'USERS_MANAGE'
)
BEGIN
    DECLARE @appId INT = (SELECT [application_id] FROM [dbo].[applications] WHERE [code] = N'HEAL_AND_CARE');
    DECLARE @newPermId INT;

    INSERT INTO [dbo].[permissions] ([application_id], [code], [description])
    VALUES (@appId, N'USERS_MANAGE', N'Create users and manage their role/permission access');

    SET @newPermId = SCOPE_IDENTITY();

    INSERT INTO [dbo].[role_permissions] ([role_id], [permission_id])
    SELECT [role_id], @newPermId
    FROM [dbo].[roles]
    WHERE [application_id] = @appId AND [name] = N'Administrator';
END

/*
 Restructures the 5 originally-demoed screens (Patients, Staff, Billing, Inventory, Users)
 from an inconsistent VIEW/MANAGE/DEACTIVATE set into a uniform 3-permission shape per
 screen: READONLY, CREATE, EDIT. Read actions require any one of the three; deactivate/
 delete/activate all fold into EDIT — no separate permission for destructive actions, so
 STAFF_DEACTIVATE goes away entirely rather than being renamed.
 Idempotent: skipped if PATIENTS_READONLY already exists.

 role_permissions.permission_id has no cascade delete by design (see role_permissions.sql —
 avoids SQL Server's multiple-cascade-path restriction), so those rows must be deleted
 explicitly before the old permission rows themselves. user_permissions.permission_id DOES
 cascade, so any direct (non-role) grants a tester made against the old codes via the User
 Management screen are removed along with them — expected, not a bug.
*/
IF NOT EXISTS (
    SELECT 1 FROM [dbo].[permissions] p
    JOIN [dbo].[applications] a ON a.[application_id] = p.[application_id]
    WHERE a.[code] = N'HEAL_AND_CARE' AND p.[code] = N'PATIENTS_READONLY'
)
BEGIN
    DECLARE @migAppId INT = (SELECT [application_id] FROM [dbo].[applications] WHERE [code] = N'HEAL_AND_CARE');

    DELETE rp
    FROM [dbo].[role_permissions] rp
    JOIN [dbo].[permissions] p ON p.[permission_id] = rp.[permission_id]
    WHERE p.[application_id] = @migAppId
      AND p.[code] IN (
        N'PATIENTS_VIEW', N'PATIENTS_MANAGE',
        N'STAFF_VIEW', N'STAFF_MANAGE', N'STAFF_DEACTIVATE',
        N'BILLS_VIEW', N'BILLS_MANAGE',
        N'INVENTORY_MANAGE',
        N'USERS_MANAGE'
      );

    DELETE FROM [dbo].[permissions]
    WHERE [application_id] = @migAppId
      AND [code] IN (
        N'PATIENTS_VIEW', N'PATIENTS_MANAGE',
        N'STAFF_VIEW', N'STAFF_MANAGE', N'STAFF_DEACTIVATE',
        N'BILLS_VIEW', N'BILLS_MANAGE',
        N'INVENTORY_MANAGE',
        N'USERS_MANAGE'
      );

    INSERT INTO [dbo].[permissions] ([application_id], [code], [description])
    VALUES
        (@migAppId, N'PATIENTS_READONLY',  N'View patient records'),
        (@migAppId, N'PATIENTS_CREATE',    N'Create new patient records'),
        (@migAppId, N'PATIENTS_EDIT',      N'Edit, mark history complete, or delete patient records'),
        (@migAppId, N'STAFF_READONLY',     N'View staff directory'),
        (@migAppId, N'STAFF_CREATE',       N'Create new staff records'),
        (@migAppId, N'STAFF_EDIT',         N'Edit, activate/deactivate, or delete staff records'),
        (@migAppId, N'BILLS_READONLY',     N'View bills'),
        (@migAppId, N'BILLS_CREATE',       N'Create new bills'),
        (@migAppId, N'BILLS_EDIT',         N'Edit or delete bills'),
        (@migAppId, N'INVENTORY_READONLY', N'View inventory stock'),
        (@migAppId, N'INVENTORY_CREATE',   N'Add new inventory stock batches'),
        (@migAppId, N'INVENTORY_EDIT',     N'Edit or delete inventory stock batches'),
        (@migAppId, N'USERS_READONLY',     N'View users and their access'),
        (@migAppId, N'USERS_CREATE',       N'Create new users'),
        (@migAppId, N'USERS_EDIT',         N'Edit access, activate/deactivate, or delete users');

    -- Administrator: every permission for this application (matches the original seed's style).
    INSERT INTO [dbo].[role_permissions] ([role_id], [permission_id])
    SELECT r.[role_id], p.[permission_id]
    FROM [dbo].[roles] r
    CROSS JOIN [dbo].[permissions] p
    WHERE r.[application_id] = @migAppId
      AND p.[application_id] = @migAppId
      AND r.[name] = N'Administrator';

    -- Receptionist: Patients + Bills only — same effective scope as before, each old MANAGE
    -- split into CREATE + EDIT.
    INSERT INTO [dbo].[role_permissions] ([role_id], [permission_id])
    SELECT r.[role_id], p.[permission_id]
    FROM [dbo].[roles] r
    CROSS JOIN [dbo].[permissions] p
    WHERE r.[application_id] = @migAppId
      AND p.[application_id] = @migAppId
      AND r.[name] = N'Receptionist'
      AND p.[code] IN (
        N'PATIENTS_READONLY', N'PATIENTS_CREATE', N'PATIENTS_EDIT',
        N'BILLS_READONLY', N'BILLS_CREATE', N'BILLS_EDIT'
      );
END
