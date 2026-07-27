CREATE TABLE [dbo].[role_permissions] (
    [role_permission_id] INT           IDENTITY (1, 1) NOT NULL,
    [role_id]             INT           NOT NULL,
    [permission_id]       INT           NOT NULL,
    [created_at]          DATETIME2 (0) DEFAULT (sysutcdatetime()) NOT NULL,
    PRIMARY KEY CLUSTERED ([role_permission_id] ASC),
    -- Deleting a role cleans up its permission bundle automatically.
    CONSTRAINT [FK_role_permissions_role] FOREIGN KEY ([role_id]) REFERENCES [dbo].[roles] ([role_id]) ON DELETE CASCADE,
    -- NO ACTION (not CASCADE): permissions and roles both cascade from applications, so
    -- cascading here too would give SQL Server two convergent delete paths into this table.
    -- Retiring a permission code is a rarer, deliberate admin action handled at the app layer.
    CONSTRAINT [FK_role_permissions_permission] FOREIGN KEY ([permission_id]) REFERENCES [dbo].[permissions] ([permission_id]),
    UNIQUE NONCLUSTERED ([role_id] ASC, [permission_id] ASC)
);
