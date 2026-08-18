/*
    What a clinic is paying for.

    The point of this is to stop commercial arrangements being written into code.
    Without it, "this clinic may have three branches" ends up as a condition
    somewhere naming that clinic, and every commercial change becomes a deployment.

    Plans are shared, not per-clinic. They are the product's price list, the same
    rows for every customer, so subscription_plans carries no tenant_id — like
    menus and screens. What is per-clinic is which plan a clinic is on.

    tenants.plan_id is NULLABLE, and null means "no plan assigned". That is the
    honest state of the clinic already running: it predates any commercial
    arrangement. Null must therefore mean unrestricted, not unusable — a clinic
    that has been open for months must not stop working the day this ships.

    That leniency is a debt, not a design. Once entitlement is actually enforced,
    every clinic needs a plan, and null becomes a hole rather than a courtesy. The
    ADR records it as the thing to resolve before enforcement lands.

    The limit columns are populated but read by nothing yet. Enforcing them is a
    separate story; they are here because a limit's natural home is the plan, and
    scattering them later would mean revisiting every caller.

    No plan definitions are seeded. What the plans are and what they cost is a
    commercial decision, and inventing prices here would put fiction in the
    database.

    Run AFTER 07-tenant-lifecycle.sql. Idempotent.
*/
SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;
SET XACT_ABORT ON;
GO

------------------------------------------------------------------ the price list
IF OBJECT_ID('dbo.subscription_plans') IS NULL
BEGIN
    CREATE TABLE dbo.subscription_plans
    (
        plan_id          INT IDENTITY(1,1) NOT NULL,

        -- What code refers to when it has to name a plan. Stable; the display name
        -- can be changed for marketing without breaking anything.
        plan_code        NVARCHAR(40)  NOT NULL,
        plan_name        NVARCHAR(120) NOT NULL,
        description      NVARCHAR(400) NULL,

        -- Commercial terms. Null price means "not published" — an agreed rate that
        -- is not on the price list.
        monthly_price    DECIMAL(18,2) NULL,
        currency         NVARCHAR(3)   NULL,

        -- Limits. NULL means unlimited, which is deliberate: a new limit added later
        -- defaults to unlimited and so cannot silently restrict an existing customer.
        max_branches     INT           NULL,
        max_users        INT           NULL,

        is_active        BIT           NOT NULL CONSTRAINT DF_subscription_plans_active  DEFAULT (1),
        is_deleted       BIT           NOT NULL CONSTRAINT DF_subscription_plans_deleted DEFAULT (0),
        created_at       DATETIME2(7)  NOT NULL CONSTRAINT DF_subscription_plans_created DEFAULT (SYSUTCDATETIME()),
        updated_at       DATETIME2(7)  NULL,

        CONSTRAINT PK_subscription_plans PRIMARY KEY CLUSTERED (plan_id),
        CONSTRAINT UQ_subscription_plans_code UNIQUE (plan_code),
        CONSTRAINT CK_subscription_plans_limits
            CHECK ((max_branches IS NULL OR max_branches > 0)
               AND (max_users    IS NULL OR max_users    > 0)),
        CONSTRAINT CK_subscription_plans_price
            CHECK (monthly_price IS NULL OR monthly_price >= 0)
    );

    PRINT '  dbo.subscription_plans created';
END
GO

------------------------------------------------------------------ the reference
IF COL_LENGTH('dbo.tenants', 'plan_id') IS NULL
BEGIN
    ALTER TABLE dbo.tenants ADD plan_id INT NULL;
    PRINT '  tenants.plan_id added (null = no plan assigned)';
END
GO

IF COL_LENGTH('dbo.tenants', 'plan_started_at') IS NULL
    ALTER TABLE dbo.tenants ADD plan_started_at DATETIME2(7) NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_tenants_plan')
    ALTER TABLE dbo.tenants ADD CONSTRAINT FK_tenants_plan
        FOREIGN KEY (plan_id) REFERENCES dbo.subscription_plans (plan_id) ON DELETE NO ACTION;
GO

-- "Who is on this plan" is asked whenever a plan is changed or withdrawn.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_tenants_plan'
               AND object_id = OBJECT_ID('dbo.tenants'))
    CREATE INDEX IX_tenants_plan ON dbo.tenants (plan_id) INCLUDE (tenant_name, status);
GO

------------------------------------------------------------------ report
SELECT 'subscription_plans defined : ' + CAST(COUNT(*) AS VARCHAR) + '   (none seeded on purpose)'
FROM dbo.subscription_plans;

SELECT 'clinics with no plan       : ' + CAST(COUNT(*) AS VARCHAR) + '   (null = unrestricted, for now)'
FROM dbo.tenants WHERE plan_id IS NULL AND is_deleted = 0;
