CREATE TABLE [dbo].[user_roles] (
    [user_role_id] INT           IDENTITY (1, 1) NOT NULL,
    [user_id]      INT           NOT NULL,
    [role_id]      INT           NOT NULL,
    [created_by]   INT           NULL,
    [created_at]   DATETIME2 (7) CONSTRAINT [DF_user_roles_created] DEFAULT (sysutcdatetime()) NOT NULL,
    [updated_by]   INT           NULL,
    [updated_at]   DATETIME2 (7) NULL,
    [is_active]    BIT           CONSTRAINT [DF_user_roles_active] DEFAULT ((1)) NOT NULL,
    [is_deleted]   BIT           CONSTRAINT [DF_user_roles_deleted] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_user_roles] PRIMARY KEY CLUSTERED ([user_role_id] ASC),
    CONSTRAINT [UQ_user_roles] UNIQUE NONCLUSTERED ([user_id] ASC, [role_id] ASC),
    CONSTRAINT [FK_user_roles_user] FOREIGN KEY ([user_id]) REFERENCES [dbo].[users] ([user_id]),
    CONSTRAINT [FK_user_roles_role] FOREIGN KEY ([role_id]) REFERENCES [dbo].[roles] ([role_id])
);
