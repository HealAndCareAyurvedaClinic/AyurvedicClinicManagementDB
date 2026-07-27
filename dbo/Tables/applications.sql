CREATE TABLE [dbo].[applications] (
    [application_id] INT            IDENTITY (1, 1) NOT NULL,
    [code]           NVARCHAR (50)  NOT NULL,
    [name]           NVARCHAR (255) NOT NULL,
    [is_active]      BIT            DEFAULT ((1)) NOT NULL,
    [created_at]     DATETIME2 (0)  DEFAULT (sysutcdatetime()) NOT NULL,
    PRIMARY KEY CLUSTERED ([application_id] ASC),
    UNIQUE NONCLUSTERED ([code] ASC)
);
