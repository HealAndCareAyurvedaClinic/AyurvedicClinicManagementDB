/*
    Register the Bulk Import / Export screen with the access-rights model.

    The sidebar denies by default, so without a menu row and a grant the screen
    would be invisible to everyone including an administrator.

    Granted to Admin only. A bulk import rewrites the catalogue and the stock
    figures in one action; that is an administrative act, not day-to-day
    dispensing, so it is deliberately not given to the clinical or front-desk
    roles. Idempotent.
*/
SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;

DECLARE @route NVARCHAR(200) = N'/pharmacy-import-export';
DECLARE @menuName NVARCHAR(255) = N'Bulk Import / Export';

------------------------------------------------------------------ menu
IF NOT EXISTS (SELECT 1 FROM dbo.menus WHERE menu_name = @menuName)
    INSERT INTO dbo.menus (menu_name, menu_type, module, menu_route, menu_order, menu_icon)
    VALUES (@menuName, N'Screen', N'Pharmacy', @route, 60, N'swap_vert');

DECLARE @menuId INT = (SELECT menu_id FROM dbo.menus WHERE menu_name = @menuName);

------------------------------------------------------------------ screen
-- The screen row is what the API's X-Form-Name check resolves against, so the
-- endpoints can be gated the same way the rest of the app is.
IF NOT EXISTS (SELECT 1 FROM dbo.screens WHERE screen_name = @menuName)
    INSERT INTO dbo.screens (screen_name, screen_description, menu_id, screen_route)
    VALUES (@menuName, N'Bulk import and export of medicines and inventory', @menuId, @route);

DECLARE @screenId INT = (SELECT screen_id FROM dbo.screens WHERE screen_name = @menuName);

------------------------------------------------------------------ grant to Admin only
DECLARE @fullLevel INT = (SELECT access_level_id FROM dbo.access_levels WHERE access_level_name = N'Full System Access');

IF @fullLevel IS NULL
BEGIN
    RAISERROR('Access level "Full System Access" not found - run seed-role-access-baseline.sql first', 16, 1);
    RETURN;
END

IF NOT EXISTS (SELECT 1 FROM dbo.access_level_menus WHERE access_level_id = @fullLevel AND menu_id = @menuId)
    INSERT INTO dbo.access_level_menus (access_level_id, menu_id, is_view) VALUES (@fullLevel, @menuId, 1);

MERGE dbo.access_level_screens AS t
USING (SELECT @fullLevel AS lvl, @screenId AS scr) AS s
ON t.access_level_id = s.lvl AND t.screen_id = s.scr
WHEN MATCHED THEN UPDATE SET is_view = 1, is_read = 1, is_write = 1, is_delete = 1, is_active = 1, is_deleted = 0
WHEN NOT MATCHED THEN INSERT (access_level_id, screen_id, is_view, is_read, is_write, is_delete)
                      VALUES (s.lvl, s.scr, 1, 1, 1, 1);

------------------------------------------------------------------ report
SELECT 'menu   : ' + m.menu_name + '  (' + m.menu_route + ')' FROM dbo.menus m WHERE m.menu_id = @menuId;
SELECT 'screen : ' + s.screen_name FROM dbo.screens s WHERE s.screen_id = @screenId;
SELECT 'granted to: ' + STRING_AGG(r.role_name, ', ')
FROM dbo.access_level_menus alm
JOIN dbo.access_group_access_levels agal ON agal.access_level_id = alm.access_level_id
JOIN dbo.role_access_groups rag ON rag.access_group_id = agal.access_group_id
JOIN dbo.roles r ON r.role_id = rag.role_id
WHERE alm.menu_id = @menuId;
