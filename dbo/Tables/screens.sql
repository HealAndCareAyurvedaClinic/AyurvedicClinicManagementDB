CREATE TABLE [dbo].[screens]
(
    [screen_id] INT NOT NULL PRIMARY KEY IDENTITY(1,1),
    [screen_name] NVARCHAR(255) NOT NULL,
    [screen_description] NVARCHAR(MAX),
    [menu_id] INT NULL,
    [screen_url] NVARCHAR(MAX),
    [screen_route] NVARCHAR(MAX),
    [created_by] INT,
    [created_at] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [updated_by] INT,
    [updated_at] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [is_active] BIT NOT NULL DEFAULT 1,
    [is_deleted] BIT NOT NULL DEFAULT 0,
    FOREIGN KEY ([menu_id]) REFERENCES [dbo].[menus]([menu_id]) ON DELETE CASCADE,
    UNIQUE ([screen_name])
)
