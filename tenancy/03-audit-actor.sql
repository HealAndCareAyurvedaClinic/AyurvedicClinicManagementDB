/*
    The audit trail records who made a change.

    audit_log.changed_by points at staff, but the person who makes a change is a
    *user*, and not every user is staff — the administrator account is nobody's
    employee. Recording only staff would have left the administrator's changes
    unattributed, which is the opposite of what an audit trail is for.

    So the user becomes the actor, and changed_by stays as the staff member behind
    that user where there is one, which keeps the existing "changes by staff member"
    view working.

    The username is stored alongside the id on purpose. An audit row has to stay
    readable years later, after the account has been renamed or removed.

    Run AFTER 02-rescope-constraints.sql. Idempotent.
*/
SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;
SET XACT_ABORT ON;
GO

IF COL_LENGTH('dbo.audit_log', 'user_id') IS NULL
BEGIN
    ALTER TABLE dbo.audit_log ADD user_id INT NULL;
    PRINT '  audit_log.user_id added';
END
GO

IF COL_LENGTH('dbo.audit_log', 'username') IS NULL
BEGIN
    ALTER TABLE dbo.audit_log ADD username NVARCHAR(100) NULL;
    PRINT '  audit_log.username added';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_audit_log_user')
    ALTER TABLE dbo.audit_log WITH NOCHECK
        ADD CONSTRAINT FK_audit_log_user FOREIGN KEY (user_id)
            REFERENCES dbo.users (user_id) ON DELETE NO ACTION;
GO

-- The two questions asked of an audit trail: what happened to this row, and what has
-- this person been doing. Neither had an index.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_audit_log_tenant_table_record'
               AND object_id = OBJECT_ID('dbo.audit_log'))
    CREATE INDEX IX_audit_log_tenant_table_record
        ON dbo.audit_log (tenant_id, table_name, record_id, changed_at);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_audit_log_tenant_user_changed'
               AND object_id = OBJECT_ID('dbo.audit_log'))
    CREATE INDEX IX_audit_log_tenant_user_changed
        ON dbo.audit_log (tenant_id, user_id, changed_at);
GO

SELECT 'audit_log actor columns : ' +
       CASE WHEN COL_LENGTH('dbo.audit_log','user_id') IS NOT NULL
             AND COL_LENGTH('dbo.audit_log','username') IS NOT NULL
            THEN 'present' ELSE 'MISSING' END;

SELECT 'audit_log indexes       : ' + CAST(COUNT(*) AS VARCHAR)
FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.audit_log') AND name IS NOT NULL;
