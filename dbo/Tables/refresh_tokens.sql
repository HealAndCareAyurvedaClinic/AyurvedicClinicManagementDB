CREATE TABLE [dbo].[refresh_tokens] (
    [token_id]   INT            IDENTITY (1, 1) NOT NULL,
    [user_id]    INT            NOT NULL,
    [token]      NVARCHAR (500) NOT NULL,
    [expires_at] DATETIME2 (7)  NOT NULL,
    [created_at] DATETIME2 (7)  CONSTRAINT [DF_refresh_tokens_created] DEFAULT (sysutcdatetime()) NOT NULL,
    -- Access tokens are stateless and cannot be recalled; revoking the refresh
    -- token here is what actually ends a session.
    [is_revoked] BIT            CONSTRAINT [DF_refresh_tokens_revoked] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_refresh_tokens] PRIMARY KEY CLUSTERED ([token_id] ASC),
    CONSTRAINT [FK_refresh_tokens_user] FOREIGN KEY ([user_id]) REFERENCES [dbo].[users] ([user_id])
);


GO
CREATE NONCLUSTERED INDEX [IX_refresh_tokens_token]
    ON [dbo].[refresh_tokens]([token] ASC);
