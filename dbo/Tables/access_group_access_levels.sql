CREATE TABLE [dbo].[access_group_access_levels]
(
    [access_group_access_level_id] INT NOT NULL PRIMARY KEY IDENTITY(1,1),
    [access_group_id] INT NOT NULL,
    [access_level_id] INT NOT NULL,
    [created_by] INT,
    [created_at] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [updated_by] INT,
    [updated_at] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [is_active] BIT NOT NULL DEFAULT 1,
    [is_deleted] BIT NOT NULL DEFAULT 0,
    FOREIGN KEY ([access_group_id]) REFERENCES [dbo].[access_groups]([access_group_id]) ON DELETE CASCADE,
    FOREIGN KEY ([access_level_id]) REFERENCES [dbo].[access_levels]([access_level_id]) ON DELETE CASCADE,
    UNIQUE ([access_group_id], [access_level_id])
)
