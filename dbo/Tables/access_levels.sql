CREATE TABLE [dbo].[access_levels]
(
    [access_level_id] INT NOT NULL PRIMARY KEY IDENTITY(1,1),
    [access_level_name] NVARCHAR(255) NOT NULL,
    [access_level_description] NVARCHAR(MAX),
    [created_by] INT,
    [created_at] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [updated_by] INT,
    [updated_at] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [is_active] BIT NOT NULL DEFAULT 1,
    [is_deleted] BIT NOT NULL DEFAULT 0,
    UNIQUE ([access_level_name])
)
