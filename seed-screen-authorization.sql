/*
    Register the screens the new server-side authorisation checks against, and
    grant them.

    The RequiresScreen attribute refuses anything it cannot reason about, so a
    screen that is not registered denies everyone - including an administrator.
    Every screen named by the attribute must therefore exist here.

    Idempotent.
*/
SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;

DECLARE @screens TABLE (screen_name NVARCHAR(255), menu_route NVARCHAR(200), descr NVARCHAR(500));
INSERT INTO @screens VALUES
    (N'Manage Users',         N'/manage-users',         N'User accounts and their role mapping'),
    (N'Manage Roles',         N'/manage-roles',         N'Roles available in the system'),
    (N'Manage Access Rights', N'/manage-access-rights', N'Access groups, levels and their grants'),
    (N'Audit Logs',           N'/audit-logs',           N'Record of changes made in the system'),
    (N'Payments',             N'/payments',             N'Payments taken against bills'),
    (N'Refunds',              N'/refunds',              N'Refunds issued against payments');

-- Create any that are missing, attached to their menu where one exists.
MERGE dbo.screens AS t
USING (SELECT s.screen_name, s.descr, m.menu_id
       FROM @screens s LEFT JOIN dbo.menus m ON m.menu_route = s.menu_route AND m.is_deleted = 0) AS src
ON t.screen_name = src.screen_name
WHEN NOT MATCHED THEN
    INSERT (screen_name, screen_description, menu_id, screen_route)
    VALUES (src.screen_name, src.descr, src.menu_id,
            (SELECT menu_route FROM @screens x WHERE x.screen_name = src.screen_name));

------------------------------------------------------------------ grants
-- Administration and audit: administrators only.
DECLARE @adminOnly TABLE (screen_name NVARCHAR(255));
INSERT INTO @adminOnly VALUES
    (N'Manage Users'), (N'Manage Roles'), (N'Manage Access Rights'), (N'Audit Logs');

-- Money: administrators, plus the front desk who actually take it.
DECLARE @money TABLE (screen_name NVARCHAR(255));
INSERT INTO @money VALUES (N'Payments'), (N'Refunds'), (N'Billing Counter');

DECLARE @full INT = (SELECT access_level_id FROM dbo.access_levels WHERE access_level_name = N'Full System Access');
DECLARE @desk INT = (SELECT access_level_id FROM dbo.access_levels WHERE access_level_name = N'Front Desk');

IF @full IS NULL
BEGIN
    RAISERROR('Access level "Full System Access" not found - run seed-role-access-baseline.sql first', 16, 1);
    RETURN;
END

-- Administrator: full CRUD on everything named above.
MERGE dbo.access_level_screens AS t
USING (SELECT @full AS lvl, sc.screen_id
       FROM dbo.screens sc
       WHERE sc.screen_name IN (SELECT screen_name FROM @adminOnly)
          OR sc.screen_name IN (SELECT screen_name FROM @money)) AS s
ON t.access_level_id = s.lvl AND t.screen_id = s.screen_id
WHEN MATCHED THEN UPDATE SET is_view = 1, is_read = 1, is_write = 1, is_delete = 1, is_active = 1, is_deleted = 0
WHEN NOT MATCHED THEN INSERT (access_level_id, screen_id, is_view, is_read, is_write, is_delete)
                      VALUES (s.lvl, s.screen_id, 1, 1, 1, 1);

-- Front desk: take payments and issue refunds, but not delete them.
IF @desk IS NOT NULL
MERGE dbo.access_level_screens AS t
USING (SELECT @desk AS lvl, sc.screen_id
       FROM dbo.screens sc WHERE sc.screen_name IN (SELECT screen_name FROM @money)) AS s
ON t.access_level_id = s.lvl AND t.screen_id = s.screen_id
WHEN MATCHED THEN UPDATE SET is_view = 1, is_read = 1, is_write = 1, is_delete = 0, is_active = 1, is_deleted = 0
WHEN NOT MATCHED THEN INSERT (access_level_id, screen_id, is_view, is_read, is_write, is_delete)
                      VALUES (s.lvl, s.screen_id, 1, 1, 1, 0);

------------------------------------------------------------------ report
SELECT 'screen: ' + sc.screen_name + '  ->  ' + STRING_AGG(al.access_level_name, ', ')
FROM dbo.screens sc
LEFT JOIN dbo.access_level_screens als ON als.screen_id = sc.screen_id AND als.is_active = 1
LEFT JOIN dbo.access_levels al ON al.access_level_id = als.access_level_id
WHERE sc.screen_name IN (SELECT screen_name FROM @adminOnly)
   OR sc.screen_name IN (SELECT screen_name FROM @money)
   OR sc.screen_name IN (N'Staff', N'Suppliers', N'Bulk Import / Export')
GROUP BY sc.screen_name
ORDER BY sc.screen_name;
