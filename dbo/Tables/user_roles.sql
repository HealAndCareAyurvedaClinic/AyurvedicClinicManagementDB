CREATE TABLE [dbo].[user_roles] (
    [user_role_id] INT           IDENTITY (1, 1) NOT NULL,
    [user_id]      INT           NOT NULL,
    [role_id]      INT           NOT NULL,
    [created_at]   DATETIME2 (0) DEFAULT (sysutcdatetime()) NOT NULL,
    PRIMARY KEY CLUSTERED ([user_role_id] ASC),
    CONSTRAINT [FK_user_roles_user] FOREIGN KEY ([user_id]) REFERENCES [dbo].[users] ([user_id]) ON DELETE CASCADE,
    CONSTRAINT [FK_user_roles_role] FOREIGN KEY ([role_id]) REFERENCES [dbo].[roles] ([role_id]) ON DELETE CASCADE,
    UNIQUE NONCLUSTERED ([user_id] ASC, [role_id] ASC)
);
