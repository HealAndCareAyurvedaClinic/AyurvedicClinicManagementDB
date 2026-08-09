CREATE TABLE [dbo].[roles] (
    [role_id]     INT            IDENTITY (1, 1) NOT NULL,
    [role_name]   NVARCHAR (50)  NOT NULL,
    [description] NVARCHAR (255) NULL,
    [created_by]  INT            NULL,
    [created_at]  DATETIME2 (7)  CONSTRAINT [DF_roles_created] DEFAULT (sysutcdatetime()) NOT NULL,
    [updated_by]  INT            NULL,
    [updated_at]  DATETIME2 (7)  NULL,
    [is_active]   BIT            CONSTRAINT [DF_roles_active] DEFAULT ((1)) NOT NULL,
    [is_deleted]  BIT            CONSTRAINT [DF_roles_deleted] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_roles] PRIMARY KEY CLUSTERED ([role_id] ASC),
    CONSTRAINT [UQ_roles_name] UNIQUE NONCLUSTERED ([role_name] ASC)
);
