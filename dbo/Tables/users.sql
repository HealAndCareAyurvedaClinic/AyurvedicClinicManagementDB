CREATE TABLE [dbo].[users] (
    [user_id]       INT            IDENTITY (1, 1) NOT NULL,
    [username]      NVARCHAR (100) NOT NULL,
    [password_hash] NVARCHAR (512) NOT NULL,
    [staff_id]      INT            NULL,
    [is_active]     BIT            DEFAULT ((1)) NOT NULL,
    [created_at]    DATETIME2 (0)  DEFAULT (sysutcdatetime()) NOT NULL,
    [last_login_at] DATETIME2 (0)  NULL,
    PRIMARY KEY CLUSTERED ([user_id] ASC),
    -- A login must survive deletion of the linked clinical staff profile.
    CONSTRAINT [FK_users_staff] FOREIGN KEY ([staff_id]) REFERENCES [dbo].[staff] ([staff_id]) ON DELETE SET NULL,
    UNIQUE NONCLUSTERED ([username] ASC)
);
