CREATE TABLE [dbo].[section_fields]
(
    [section_field_id] INT NOT NULL PRIMARY KEY IDENTITY(1,1),
    [screen_id] INT NOT NULL,
    [section_id] INT NOT NULL,
    [field_name] NVARCHAR(255) NOT NULL,
    [field_label] NVARCHAR(MAX) NOT NULL,
    [control_type] NVARCHAR(100) NOT NULL,
    [default_value] NVARCHAR(MAX),
    [placeholder_text] NVARCHAR(MAX),
    [help_text] NVARCHAR(MAX),
    [is_system_required] BIT NOT NULL DEFAULT 0,
    [field_order] INT NOT NULL DEFAULT 0,
    [created_by] INT,
    [created_at] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [updated_by] INT,
    [updated_at] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [is_active] BIT NOT NULL DEFAULT 1,
    [is_deleted] BIT NOT NULL DEFAULT 0,
    FOREIGN KEY ([screen_id]) REFERENCES [dbo].[screens]([screen_id]) ON DELETE NO ACTION,
    FOREIGN KEY ([section_id]) REFERENCES [dbo].[sections]([section_id]) ON DELETE CASCADE,
    UNIQUE ([screen_id], [section_id], [field_name])
)
