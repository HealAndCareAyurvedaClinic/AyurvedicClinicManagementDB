/*
    Registers the Settings screen, where a clinic sets its own letterhead.

    The sidebar has carried a "Settings" link since long before this, pointing at
    /settings, which no route answered and no screen registered -- so it was a dead
    link that took anyone who clicked it nowhere. The screen exists now, and an
    unregistered screen is refused by the access-rights guard rather than waved
    through, which makes this script a precondition for the link working at all
    rather than a nicety.

    Menus and screens are shared product data, so this inserts no tenant_id. What is
    per-clinic is the grant, which goes to whichever access levels already reach the
    administrative screens -- so an administrator gets it and a receptionist does not.
    Who may change the clinic's licence number and the address printed on every
    prescription is an administrative decision, not something to inherit from "has
    some access".

    Idempotent. Safe to re-run.
*/
SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;
GO

DECLARE @name  NVARCHAR(100) = N'Settings';
DECLARE @route NVARCHAR(200) = N'/settings';

------------------------------------------------------------------ menu
IF NOT EXISTS (SELECT 1 FROM dbo.menus WHERE menu_name = @name)
BEGIN
    INSERT INTO dbo.menus (menu_name, menu_type, module, menu_route, menu_order, menu_icon)
    VALUES (@name, N'Screen', N'Administration', @route, 90, N'settings');
    PRINT '  menu "Settings" added';
END
GO

------------------------------------------------------------------ screen
DECLARE @name NVARCHAR(100) = N'Settings';
DECLARE @menuId INT = (SELECT menu_id FROM dbo.menus WHERE menu_name = @name);

IF NOT EXISTS (SELECT 1 FROM dbo.screens WHERE screen_name = @name)
BEGIN
    INSERT INTO dbo.screens (screen_name, screen_description, menu_id, screen_route)
    VALUES (@name, N'Set the clinic logo, address and prescription layout', @menuId, N'/settings');
    PRINT '  screen "Settings" added';
END
GO

------------------------------------------------------------------ grants
DECLARE @screenId INT = (SELECT screen_id FROM dbo.screens WHERE screen_name = N'Settings');
DECLARE @menuId   INT = (SELECT menu_id   FROM dbo.menus   WHERE menu_name   = N'Settings');

;WITH administrative AS (
    SELECT DISTINCT als.access_level_id, als.tenant_id
    FROM dbo.access_level_screens als
    JOIN dbo.screens s ON s.screen_id = als.screen_id
    WHERE s.screen_name IN (N'Manage Access Rights', N'Users', N'Roles')
      AND als.is_deleted = 0 AND als.is_write = 1
)
INSERT INTO dbo.access_level_screens
    (tenant_id, access_level_id, screen_id, is_view, is_read, is_write, is_delete)
SELECT a.tenant_id, a.access_level_id, @screenId, 1, 1, 1, 1
FROM administrative a
WHERE NOT EXISTS (SELECT 1 FROM dbo.access_level_screens x
                  WHERE x.access_level_id = a.access_level_id AND x.screen_id = @screenId);

;WITH administrative AS (
    SELECT DISTINCT als.access_level_id, als.tenant_id
    FROM dbo.access_level_screens als
    JOIN dbo.screens s ON s.screen_id = als.screen_id
    WHERE s.screen_name IN (N'Manage Access Rights', N'Users', N'Roles')
      AND als.is_deleted = 0 AND als.is_write = 1
)
INSERT INTO dbo.access_level_menus (tenant_id, access_level_id, menu_id, is_view)
SELECT a.tenant_id, a.access_level_id, @menuId, 1
FROM administrative a
WHERE NOT EXISTS (SELECT 1 FROM dbo.access_level_menus x
                  WHERE x.access_level_id = a.access_level_id AND x.menu_id = @menuId);
GO

------------------------------------------------------------------ report
SELECT 'screen registered : ' +
       CASE WHEN EXISTS (SELECT 1 FROM dbo.screens WHERE screen_name = N'Settings')
            THEN 'yes' ELSE 'NO' END;

SELECT 'access levels granted settings : ' + CAST(COUNT(*) AS VARCHAR)
FROM dbo.access_level_screens als
JOIN dbo.screens s ON s.screen_id = als.screen_id
WHERE s.screen_name = N'Settings' AND als.is_deleted = 0;
