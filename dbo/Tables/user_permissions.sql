CREATE TABLE [dbo].[user_permissions] (
    [user_permission_id] INT           IDENTITY (1, 1) NOT NULL,
    [user_id]             INT           NOT NULL,
    [permission_id]       INT           NOT NULL,
    [created_at]          DATETIME2 (0) DEFAULT (sysutcdatetime()) NOT NULL,
    PRIMARY KEY CLUSTERED ([user_permission_id] ASC),
    -- Direct grant/override on top of whatever the user's roles already provide;
    -- effective permissions = union(role permissions) + (these direct grants).
    CONSTRAINT [FK_user_permissions_user] FOREIGN KEY ([user_id]) REFERENCES [dbo].[users] ([user_id]) ON DELETE CASCADE,
    CONSTRAINT [FK_user_permissions_permission] FOREIGN KEY ([permission_id]) REFERENCES [dbo].[permissions] ([permission_id]) ON DELETE CASCADE,
    UNIQUE NONCLUSTERED ([user_id] ASC, [permission_id] ASC)
);
