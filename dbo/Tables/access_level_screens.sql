CREATE TABLE [dbo].[access_level_screens]
(
    [access_level_screen_id] INT NOT NULL PRIMARY KEY IDENTITY(1,1),
    [access_level_id] INT NOT NULL,
    [screen_id] INT NOT NULL,
    [is_view] BIT NOT NULL DEFAULT 0,
    [is_read] BIT NOT NULL DEFAULT 0,
    [is_write] BIT NOT NULL DEFAULT 0,
    [is_delete] BIT NOT NULL DEFAULT 0,
    [created_by] INT,
    [created_at] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [updated_by] INT,
    [updated_at] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [is_active] BIT NOT NULL DEFAULT 1,
    [is_deleted] BIT NOT NULL DEFAULT 0,
    FOREIGN KEY ([access_level_id]) REFERENCES [dbo].[access_levels]([access_level_id]) ON DELETE CASCADE,
    FOREIGN KEY ([screen_id]) REFERENCES [dbo].[screens]([screen_id]) ON DELETE CASCADE,
    UNIQUE ([access_level_id], [screen_id])
)
