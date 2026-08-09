CREATE TABLE [dbo].[users]
(
    [user_id] INT NOT NULL PRIMARY KEY IDENTITY(1,1),
    [username] NVARCHAR(MAX) NOT NULL,
    [email] NVARCHAR(MAX) NOT NULL,
    [password_hash] NVARCHAR(MAX) NOT NULL,
    [first_name] NVARCHAR(MAX),
    [last_name] NVARCHAR(MAX),
    [staff_id] INT,
    [last_login] DATETIME2,
    [created_by] INT,
    [created_at] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [updated_by] INT,
    [updated_at] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [is_active] BIT NOT NULL DEFAULT 1,
    [is_deleted] BIT NOT NULL DEFAULT 0,
    UNIQUE ([username]),
    UNIQUE ([email])
)
