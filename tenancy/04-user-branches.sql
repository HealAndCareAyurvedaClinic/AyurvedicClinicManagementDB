/*
    Which branches a person actually works at.

    Until now a branch was only checked against the clinic: anyone signed in could
    act at any of their clinic's branches. That is fine while a clinic has one
    branch and wrong the moment it has two — the Pune receptionist would be able to
    book, dispense and take payment against Mumbai's day book.

    A person can work at more than one branch, so this is a table rather than a
    column on users. One of them is their default: where they land when they have
    not said otherwise.

    Backfill assigns every existing user to every existing branch of their clinic.
    That is exactly today's behaviour, so nobody loses access on the day this ships;
    narrowing it is a decision for each clinic to make, not a migration to impose.

    Run AFTER 03-audit-actor.sql. Idempotent.
*/
SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;
SET XACT_ABORT ON;
GO

IF OBJECT_ID('dbo.user_branches') IS NULL
BEGIN
    CREATE TABLE dbo.user_branches
    (
        user_branch_id  INT IDENTITY(1,1) NOT NULL,
        tenant_id       INT           NOT NULL,
        user_id         INT           NOT NULL,
        branch_id       INT           NOT NULL,
        is_default      BIT           NOT NULL CONSTRAINT DF_user_branches_is_default DEFAULT (0),
        is_active       BIT           NOT NULL CONSTRAINT DF_user_branches_is_active  DEFAULT (1),
        is_deleted      BIT           NOT NULL CONSTRAINT DF_user_branches_is_deleted DEFAULT (0),
        created_at      DATETIME2(7)  NOT NULL CONSTRAINT DF_user_branches_created_at DEFAULT (SYSUTCDATETIME()),
        updated_at      DATETIME2(7)  NULL,

        CONSTRAINT PK_user_branches PRIMARY KEY CLUSTERED (user_branch_id),
        CONSTRAINT UQ_user_branches_user_branch UNIQUE (user_id, branch_id),
        CONSTRAINT FK_user_branches_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id),
        CONSTRAINT FK_user_branches_user   FOREIGN KEY (user_id)   REFERENCES dbo.users (user_id)   ON DELETE CASCADE,
        CONSTRAINT FK_user_branches_branch FOREIGN KEY (branch_id) REFERENCES dbo.branches (branch_id) ON DELETE NO ACTION
    );

    PRINT '  dbo.user_branches created';
END
GO

-- Signing in reads this on every request, so it is indexed for that question.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_user_branches_user'
               AND object_id = OBJECT_ID('dbo.user_branches'))
    CREATE INDEX IX_user_branches_user ON dbo.user_branches (user_id, is_active, is_deleted)
        INCLUDE (branch_id, is_default);
GO

------------------------------------------------------------------ backfill
-- Every existing user gets every branch their clinic currently has.
INSERT INTO dbo.user_branches (tenant_id, user_id, branch_id, is_default)
SELECT u.tenant_id, u.user_id, b.branch_id, 0
FROM dbo.users u
JOIN dbo.branches b ON b.tenant_id = u.tenant_id AND b.is_deleted = 0
WHERE u.is_deleted = 0
  AND NOT EXISTS (SELECT 1 FROM dbo.user_branches ub
                  WHERE ub.user_id = u.user_id AND ub.branch_id = b.branch_id);
GO

-- Everyone needs somewhere to land. The clinic's primary branch is that place;
-- failing a primary, the lowest-numbered branch they hold.
UPDATE ub
SET    is_default = 1
FROM   dbo.user_branches ub
WHERE  ub.is_deleted = 0
  AND  NOT EXISTS (SELECT 1 FROM dbo.user_branches d
                   WHERE d.user_id = ub.user_id AND d.is_default = 1 AND d.is_deleted = 0)
  AND  ub.branch_id = (SELECT TOP 1 b.branch_id
                       FROM dbo.branches b
                       JOIN dbo.user_branches x ON x.branch_id = b.branch_id AND x.user_id = ub.user_id
                       WHERE b.is_deleted = 0
                       ORDER BY b.is_primary DESC, b.branch_id);
GO

------------------------------------------------------------------ report
SELECT 'user/branch assignments : ' + CAST(COUNT(*) AS VARCHAR) FROM dbo.user_branches WHERE is_deleted = 0;

SELECT 'users with no default   : ' + CAST(COUNT(*) AS VARCHAR) + '   (expected 0)'
FROM dbo.users u
WHERE u.is_deleted = 0
  AND NOT EXISTS (SELECT 1 FROM dbo.user_branches ub
                  WHERE ub.user_id = u.user_id AND ub.is_default = 1 AND ub.is_deleted = 0);

SELECT 'users with more than one default : ' + CAST(COUNT(*) AS VARCHAR) + '   (expected 0)'
FROM (SELECT user_id FROM dbo.user_branches WHERE is_default = 1 AND is_deleted = 0
      GROUP BY user_id HAVING COUNT(*) > 1) AS bad;
