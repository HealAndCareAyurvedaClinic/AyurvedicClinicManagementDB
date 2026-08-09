CREATE TABLE [dbo].[sections]
(
    [section_id] INT NOT NULL PRIMARY KEY IDENTITY(1,1),
    [section_name] NVARCHAR(255) NOT NULL,
    [section_description] NVARCHAR(MAX),
    [screen_id] INT NOT NULL,
    [created_by] INT,
    [created_at] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [updated_by] INT,
    [updated_at] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [is_active] BIT NOT NULL DEFAULT 1,
    [is_deleted] BIT NOT NULL DEFAULT 0,
    FOREIGN KEY ([screen_id]) REFERENCES [dbo].[screens]([screen_id]) ON DELETE CASCADE,
    UNIQUE ([section_name], [screen_id])
)
