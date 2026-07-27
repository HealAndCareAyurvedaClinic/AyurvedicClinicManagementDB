CREATE TABLE [dbo].[permissions] (
    [permission_id]  INT            IDENTITY (1, 1) NOT NULL,
    [application_id] INT            NOT NULL,
    [code]           NVARCHAR (100) NOT NULL,
    [description]    NVARCHAR (255) NULL,
    [created_at]     DATETIME2 (0)  DEFAULT (sysutcdatetime()) NOT NULL,
    PRIMARY KEY CLUSTERED ([permission_id] ASC),
    CONSTRAINT [FK_permissions_application] FOREIGN KEY ([application_id]) REFERENCES [dbo].[applications] ([application_id]) ON DELETE CASCADE,
    UNIQUE NONCLUSTERED ([application_id] ASC, [code] ASC)
);
