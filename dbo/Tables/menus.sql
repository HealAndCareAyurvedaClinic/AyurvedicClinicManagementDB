CREATE TABLE [dbo].[menus]
(
    [menu_id] INT NOT NULL PRIMARY KEY IDENTITY(1,1),
    [menu_name] NVARCHAR(MAX) NOT NULL,
    [menu_description] NVARCHAR(MAX),
    [menu_type] NVARCHAR(50) NOT NULL,
    [module] NVARCHAR(100),
    [parent_menu_id] INT NULL,
    [menu_order] INT NOT NULL DEFAULT 0,
    [menu_icon] NVARCHAR(MAX),
    [menu_url] NVARCHAR(MAX),
    [menu_route] NVARCHAR(MAX),
    [created_by] INT,
    [created_at] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [updated_by] INT,
    [updated_at] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [is_active] BIT NOT NULL DEFAULT 1,
    [is_deleted] BIT NOT NULL DEFAULT 0,
    -- NO ACTION here (not SET NULL as originally drafted): SQL Server rejects
    -- SET NULL on a self-referencing FK ("may cause cycles or multiple cascade paths").
    FOREIGN KEY ([parent_menu_id]) REFERENCES [dbo].[menus]([menu_id]) ON DELETE NO ACTION
)
