CREATE TABLE [dbo].[refresh_tokens]
(
    [token_id] INT NOT NULL PRIMARY KEY IDENTITY(1,1),
    [user_id] INT NOT NULL,
    [token] NVARCHAR(MAX) NOT NULL,
    [expires_at] DATETIME2 NOT NULL,
    [created_at] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [is_revoked] BIT NOT NULL DEFAULT 0,
    FOREIGN KEY ([user_id]) REFERENCES [dbo].[users]([user_id]) ON DELETE CASCADE
)
