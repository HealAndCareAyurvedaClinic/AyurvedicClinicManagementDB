/*
    Registers the "All Branches" permission.

    Held as an ordinary access right rather than as a flag of its own, so that who may
    see the whole clinic is configured where every other permission is configured, and
    revoked the same way.

    Deliberately granted to NOBODY by default — not even to administrators. Running one
    branch is not the same as being allowed to see another branch's takings, and a
    clinic that wants its branch managers kept apart would find that decision already
    made for them otherwise. Grant it explicitly, per clinic, to the access level that
    should have it.

    To grant it, from inside the clinic's own access-rights administration, or:

        UPDATE dbo.access_level_screens SET is_read = 1
        WHERE screen_id = (SELECT screen_id FROM dbo.screens WHERE screen_name = 'All Branches')
          AND access_level_id = <the level>;

    Idempotent. Safe to re-run.
*/
SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;
GO

DECLARE @name  NVARCHAR(100) = N'All Branches';
DECLARE @route NVARCHAR(200) = N'/branch-comparison';

IF NOT EXISTS (SELECT 1 FROM dbo.menus WHERE menu_name = @name)
BEGIN
    INSERT INTO dbo.menus (menu_name, menu_type, module, menu_route, menu_order, menu_icon)
    VALUES (@name, N'Screen', N'Reports', @route, 10, N'compare_arrows');
    PRINT '  menu "All Branches" added';
END
GO

DECLARE @menuId INT = (SELECT menu_id FROM dbo.menus WHERE menu_name = N'All Branches');

IF NOT EXISTS (SELECT 1 FROM dbo.screens WHERE screen_name = N'All Branches')
BEGIN
    INSERT INTO dbo.screens (screen_name, screen_description, menu_id, screen_route)
    VALUES (N'All Branches',
            N'See the whole clinic at once, and compare its branches side by side',
            @menuId, N'/branch-comparison');
    PRINT '  screen "All Branches" added';
END
GO

------------------------------------------------------------------ report
SELECT 'permission registered : ' +
       CASE WHEN EXISTS (SELECT 1 FROM dbo.screens WHERE screen_name = N'All Branches')
            THEN 'yes' ELSE 'NO' END;

SELECT 'access levels holding it : ' + CAST(COUNT(*) AS VARCHAR) + '   (0 is correct until somebody grants it)'
FROM dbo.access_level_screens als
JOIN dbo.screens s ON s.screen_id = als.screen_id
WHERE s.screen_name = N'All Branches' AND als.is_deleted = 0 AND als.is_read = 1;
