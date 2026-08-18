-- ============================================================================
-- seed-role-access-baseline.sql
--
-- Makes the access-rights data usable for driving navigation, and adds a
-- worked example of a restricted role.
--
-- Runs after seed-access-rights-data.sql. Idempotent, and it narrows as well as
-- widens, so re-running after editing the intended sets brings the database back
-- in line rather than only ever adding.
--
-- Intentionally EXCLUDED: users and user_roles. Which person holds which role is
-- local data; this file only defines what a role can do.
--
-- Two problems it fixes:
--
--   1. "Full Access" granted exactly one menu (Doctors), so an administrator
--      resolved to FEWER rights than a restricted role. Any navigation driven
--      from access rights would have hidden almost everything from the people
--      who need it most.
--
--   2. The four Panchakarma routes had no menu rows at all, so they could not be
--      governed in either direction.
-- ============================================================================
SET NOCOUNT ON;
GO

------------------------------------------------------------------ missing menus
MERGE dbo.menus AS t
USING (VALUES
    (N'Panchakarma Queue',     N'Panchakarma', N'/panchakarma-worklist'),
    (N'Panchakarma Therapies', N'Panchakarma', N'/panchakarma-therapies'),
    (N'Panchakarma Rooms',     N'Panchakarma', N'/panchakarma-rooms'),
    (N'Therapist Schedules',   N'Panchakarma', N'/therapist-schedules')
) AS s (menu_name, module, menu_route)
ON t.menu_name = s.menu_name
WHEN NOT MATCHED THEN
    INSERT (menu_name, menu_type, module, menu_route, menu_order)
    VALUES (s.menu_name, N'Screen', s.module, s.menu_route, 0);

------------------------------------------------------------------ full access
IF NOT EXISTS (SELECT 1 FROM dbo.access_levels WHERE access_level_name = 'Full System Access')
    INSERT INTO dbo.access_levels (access_level_name, access_level_description)
    VALUES ('Full System Access', 'Every menu and every screen, full CRUD');

DECLARE @fullLevel INT = (SELECT access_level_id FROM dbo.access_levels WHERE access_level_name = 'Full System Access');
DECLARE @fullGroup INT = (SELECT access_group_id FROM dbo.access_groups WHERE access_group_name = 'Full Access');

IF @fullGroup IS NULL
BEGIN
    RAISERROR('Access group "Full Access" not found - run seed-access-rights-data.sql first', 16, 1);
    RETURN;
END

IF NOT EXISTS (SELECT 1 FROM dbo.access_group_access_levels
               WHERE access_group_id = @fullGroup AND access_level_id = @fullLevel)
    INSERT INTO dbo.access_group_access_levels (access_group_id, access_level_id)
    VALUES (@fullGroup, @fullLevel);

MERGE dbo.access_level_menus AS t
USING (SELECT menu_id FROM dbo.menus WHERE is_deleted = 0) AS s
ON t.access_level_id = @fullLevel AND t.menu_id = s.menu_id
WHEN MATCHED THEN UPDATE SET is_view = 1, is_active = 1, is_deleted = 0
WHEN NOT MATCHED THEN INSERT (access_level_id, menu_id, is_view) VALUES (@fullLevel, s.menu_id, 1);

MERGE dbo.access_level_screens AS t
USING (SELECT screen_id FROM dbo.screens WHERE is_deleted = 0) AS s
ON t.access_level_id = @fullLevel AND t.screen_id = s.screen_id
WHEN MATCHED THEN UPDATE SET is_view = 1, is_read = 1, is_write = 1, is_delete = 1,
                             is_active = 1, is_deleted = 0
WHEN NOT MATCHED THEN INSERT (access_level_id, screen_id, is_view, is_read, is_write, is_delete)
                      VALUES (@fullLevel, s.screen_id, 1, 1, 1, 1);

------------------------------------------------------------------ assistant doctor
-- A worked example of a restricted role: patient-facing clinical work, but no
-- finance, no administration, no pharmacy stock handling, and no Panchakarma
-- configuration - therapies, rooms and therapist diaries are set up by an
-- administrator, not by an assistant.
--
-- A dedicated group rather than reusing "Clinical Access": that group is wired
-- to "Doctor Screen Full Access", which carries delete on the Doctors screen. An
-- assistant should read the doctor list, not delete from it, and widening the
-- shared group would silently change what it means for everyone mapped to it.
IF NOT EXISTS (SELECT 1 FROM dbo.roles WHERE role_name = 'Assistant Doctor')
    INSERT INTO dbo.roles (role_name, description)
    VALUES ('Assistant Doctor', 'Supports the consulting doctor');

IF NOT EXISTS (SELECT 1 FROM dbo.access_groups WHERE access_group_name = 'Assistant Doctor Access')
    INSERT INTO dbo.access_groups (access_group_name, access_group_description)
    VALUES ('Assistant Doctor Access', 'Clinical work without administrative or financial screens');

IF NOT EXISTS (SELECT 1 FROM dbo.access_levels WHERE access_level_name = 'Assistant Doctor Clinical')
    INSERT INTO dbo.access_levels (access_level_name, access_level_description)
    VALUES ('Assistant Doctor Clinical', 'Read/write on patients and appointments, read-only on doctors and medicines');

DECLARE @adRole  INT = (SELECT role_id FROM dbo.roles WHERE role_name = 'Assistant Doctor');
DECLARE @adGroup INT = (SELECT access_group_id FROM dbo.access_groups WHERE access_group_name = 'Assistant Doctor Access');
DECLARE @adLevel INT = (SELECT access_level_id FROM dbo.access_levels WHERE access_level_name = 'Assistant Doctor Clinical');

IF NOT EXISTS (SELECT 1 FROM dbo.access_group_access_levels
               WHERE access_group_id = @adGroup AND access_level_id = @adLevel)
    INSERT INTO dbo.access_group_access_levels (access_group_id, access_level_id) VALUES (@adGroup, @adLevel);

IF NOT EXISTS (SELECT 1 FROM dbo.role_access_groups WHERE role_id = @adRole AND access_group_id = @adGroup)
    INSERT INTO dbo.role_access_groups (role_id, access_group_id) VALUES (@adRole, @adGroup);

-- screens
DECLARE @adScreens TABLE (screen_name NVARCHAR(255), is_view BIT, is_read BIT, is_write BIT, is_delete BIT);
INSERT INTO @adScreens VALUES
    ('Patients',     1, 1, 1, 0),
    ('Appointments', 1, 1, 1, 0),
    ('Doctors',      1, 1, 0, 0),
    ('Medicines',    1, 1, 0, 0);

MERGE dbo.access_level_screens AS t
USING (SELECT s.screen_id, g.is_view, g.is_read, g.is_write, g.is_delete
       FROM @adScreens g JOIN dbo.screens s ON s.screen_name = g.screen_name) AS src
ON t.access_level_id = @adLevel AND t.screen_id = src.screen_id
WHEN MATCHED THEN UPDATE SET is_view = src.is_view, is_read = src.is_read,
                             is_write = src.is_write, is_delete = src.is_delete,
                             updated_at = GETUTCDATE()
WHEN NOT MATCHED THEN INSERT (access_level_id, screen_id, is_view, is_read, is_write, is_delete)
                      VALUES (@adLevel, src.screen_id, src.is_view, src.is_read, src.is_write, src.is_delete);

-- menus
DECLARE @adMenus TABLE (menu_name NVARCHAR(255));
INSERT INTO @adMenus VALUES
    (N'Dashboard'), (N'Patients'), (N'Register Patient'), (N'Appointments'),
    (N'Doctor Worklist'), (N'Doctors'), (N'Slots & Schedules'), (N'Reminders'),
    (N'Medicines'), (N'Panchakarma Queue');

DELETE alm
FROM dbo.access_level_menus alm
JOIN dbo.menus m ON m.menu_id = alm.menu_id
WHERE alm.access_level_id = @adLevel
  AND m.menu_name NOT IN (SELECT menu_name FROM @adMenus);

MERGE dbo.access_level_menus AS t
USING (SELECT m.menu_id FROM dbo.menus m JOIN @adMenus a ON a.menu_name = m.menu_name) AS s
ON t.access_level_id = @adLevel AND t.menu_id = s.menu_id
WHEN MATCHED THEN UPDATE SET is_view = 1, is_active = 1, is_deleted = 0
WHEN NOT MATCHED THEN INSERT (access_level_id, menu_id, is_view) VALUES (@adLevel, s.menu_id, 1);

------------------------------------------------------------------ report
SELECT 'total menus            : ' + CAST(COUNT(*) AS VARCHAR) FROM dbo.menus WHERE is_deleted = 0;
SELECT 'Full System Access     : ' + CAST(COUNT(*) AS VARCHAR) + ' menus'
FROM dbo.access_level_menus WHERE access_level_id = @fullLevel;
SELECT 'Assistant Doctor       : ' + CAST(COUNT(*) AS VARCHAR) + ' menus'
FROM dbo.access_level_menus WHERE access_level_id = @adLevel;
GO
