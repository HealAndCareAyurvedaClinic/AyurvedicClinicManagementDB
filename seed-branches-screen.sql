/*
    Registers the Branches screen so branch administration can be governed by access
    rights like everything else.

    The screen has to exist before the guard on the controller can reason about it —
    an unregistered screen is refused rather than waved through, which is the right
    default and also means this script is not optional.

    Menus and screens are shared product data, so this inserts no tenant_id. What is
    per-clinic is the grant, which is added to whichever access levels already reach
    the administrative screens — so an administrator gets branch administration and
    nobody else silently does.

    Idempotent. Safe to re-run.
*/
SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;
GO

DECLARE @name  NVARCHAR(100) = N'Branches';
DECLARE @route NVARCHAR(200) = N'/branches';

------------------------------------------------------------------ menu
IF NOT EXISTS (SELECT 1 FROM dbo.menus WHERE menu_name = @name)
BEGIN
    INSERT INTO dbo.menus (menu_name, menu_type, module, menu_route, menu_order, menu_icon)
    VALUES (@name, N'Screen', N'Administration', @route, 20, N'store');
    PRINT '  menu "Branches" added';
END
GO

------------------------------------------------------------------ screen
DECLARE @name NVARCHAR(100) = N'Branches';
DECLARE @menuId INT = (SELECT menu_id FROM dbo.menus WHERE menu_name = @name);

IF NOT EXISTS (SELECT 1 FROM dbo.screens WHERE screen_name = @name)
BEGIN
    INSERT INTO dbo.screens (screen_name, screen_description, menu_id, screen_route)
    VALUES (@name, N'Open branches, close them, and say who works where', @menuId, N'/branches');
    PRINT '  screen "Branches" added';
END
GO

------------------------------------------------------------------ grants
-- Given to the access levels that already reach the other administrative screens.
-- Deliberately not given to every level: who may open a branch is a decision, and
-- inheriting it from "has some access" would be an accident.
DECLARE @screenId INT = (SELECT screen_id FROM dbo.screens WHERE screen_name = N'Branches');
DECLARE @menuId   INT = (SELECT menu_id   FROM dbo.menus   WHERE menu_name   = N'Branches');

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
       CASE WHEN EXISTS (SELECT 1 FROM dbo.screens WHERE screen_name = N'Branches')
            THEN 'yes' ELSE 'NO' END;

SELECT 'access levels granted branch administration : ' + CAST(COUNT(*) AS VARCHAR)
FROM dbo.access_level_screens als
JOIN dbo.screens s ON s.screen_id = als.screen_id
WHERE s.screen_name = N'Branches' AND als.is_deleted = 0;
