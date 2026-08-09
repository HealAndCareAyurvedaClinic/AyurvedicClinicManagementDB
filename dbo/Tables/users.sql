CREATE TABLE [dbo].[users] (
    [user_id]       INT            IDENTITY (1, 1) NOT NULL,
    [username]      NVARCHAR (255) NOT NULL,
    [email]         NVARCHAR (255) NOT NULL,
    -- PBKDF2-SHA256: 16-byte salt + 20-byte subkey, base64 encoded.
    [password_hash] NVARCHAR (500) NOT NULL,
    [first_name]    NVARCHAR (255) NOT NULL,
    [last_name]     NVARCHAR (255) NULL,
    [created_by]    INT            NULL,
    [created_at]    DATETIME2 (7)  CONSTRAINT [DF_users_created] DEFAULT (sysutcdatetime()) NOT NULL,
    [updated_by]    INT            NULL,
    [updated_at]    DATETIME2 (7)  NULL,
    [is_active]     BIT            CONSTRAINT [DF_users_active] DEFAULT ((1)) NOT NULL,
    [is_deleted]    BIT            CONSTRAINT [DF_users_deleted] DEFAULT ((0)) NOT NULL,
    [last_login]    DATETIME2 (7)  NULL,
    -- The clinic staff member this login belongs to, where there is one.
    [staff_id]      INT            NULL,
    CONSTRAINT [PK_users] PRIMARY KEY CLUSTERED ([user_id] ASC),
    CONSTRAINT [UQ_users_username] UNIQUE NONCLUSTERED ([username] ASC),
    CONSTRAINT [UQ_users_email] UNIQUE NONCLUSTERED ([email] ASC),
    CONSTRAINT [FK_users_staff] FOREIGN KEY ([staff_id]) REFERENCES [dbo].[staff] ([staff_id])
);
