CREATE TABLE [dbo].[roles]
(
    [role_id] INT NOT NULL PRIMARY KEY IDENTITY(1,1),
    [role_name] NVARCHAR(MAX) NOT NULL,
    [description] NVARCHAR(MAX),
    [created_by] INT,
    [created_at] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [updated_by] INT,
    [updated_at] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [is_active] BIT NOT NULL DEFAULT 1,
    [is_deleted] BIT NOT NULL DEFAULT 0,
    UNIQUE ([role_name])
)
