CREATE TABLE [dbo].[roles] (
    [role_id]        INT            IDENTITY (1, 1) NOT NULL,
    [application_id] INT            NOT NULL,
    [name]           NVARCHAR (100) NOT NULL,
    [description]    NVARCHAR (255) NULL,
    [created_at]     DATETIME2 (0)  DEFAULT (sysutcdatetime()) NOT NULL,
    PRIMARY KEY CLUSTERED ([role_id] ASC),
    CONSTRAINT [FK_roles_application] FOREIGN KEY ([application_id]) REFERENCES [dbo].[applications] ([application_id]) ON DELETE CASCADE,
    UNIQUE NONCLUSTERED ([application_id] ASC, [name] ASC)
);
