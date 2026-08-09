CREATE TABLE [dbo].[access_level_menus]
(
    [access_level_menu_id] INT NOT NULL PRIMARY KEY IDENTITY(1,1),
    [access_level_id] INT NOT NULL,
    [menu_id] INT NOT NULL,
    [is_view] BIT NOT NULL DEFAULT 1,
    [created_by] INT,
    [created_at] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [updated_by] INT,
    [updated_at] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [is_active] BIT NOT NULL DEFAULT 1,
    [is_deleted] BIT NOT NULL DEFAULT 0,
    FOREIGN KEY ([access_level_id]) REFERENCES [dbo].[access_levels]([access_level_id]) ON DELETE CASCADE,
    FOREIGN KEY ([menu_id]) REFERENCES [dbo].[menus]([menu_id]) ON DELETE CASCADE,
    UNIQUE ([access_level_id], [menu_id])
)
