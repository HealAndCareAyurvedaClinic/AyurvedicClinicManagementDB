CREATE TABLE [dbo].[role_access_groups]
(
    [role_access_group_id] INT NOT NULL PRIMARY KEY IDENTITY(1,1),
    [role_id] INT NOT NULL,
    [access_group_id] INT NOT NULL,
    [created_by] INT,
    [created_at] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [updated_by] INT,
    [updated_at] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [is_active] BIT NOT NULL DEFAULT 1,
    [is_deleted] BIT NOT NULL DEFAULT 0,
    FOREIGN KEY ([role_id]) REFERENCES [dbo].[roles]([role_id]) ON DELETE CASCADE,
    FOREIGN KEY ([access_group_id]) REFERENCES [dbo].[access_groups]([access_group_id]) ON DELETE CASCADE,
    UNIQUE ([role_id], [access_group_id])
)
