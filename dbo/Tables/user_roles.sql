CREATE TABLE [dbo].[user_roles]
(
    [user_role_id] INT NOT NULL PRIMARY KEY IDENTITY(1,1),
    [user_id] INT NOT NULL,
    [role_id] INT NOT NULL,
    [created_by] INT,
    [created_at] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [updated_by] INT,
    [updated_at] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [is_active] BIT NOT NULL DEFAULT 1,
    [is_deleted] BIT NOT NULL DEFAULT 0,
    FOREIGN KEY ([user_id]) REFERENCES [dbo].[users]([user_id]) ON DELETE CASCADE,
    FOREIGN KEY ([role_id]) REFERENCES [dbo].[roles]([role_id]) ON DELETE CASCADE,
    UNIQUE ([user_id], [role_id])
)
