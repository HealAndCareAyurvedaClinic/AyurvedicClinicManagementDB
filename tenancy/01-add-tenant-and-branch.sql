/*
    Multi-tenancy and multi-branch: schema.

    Adds tenant_id to every table that holds clinic data, and branch_id to the
    subset that belongs to a place. Existing rows are backfilled to the first
    tenant and its main branch, then the columns are made mandatory.

    The split follows one rule: the patient belongs to the clinic, the visit
    belongs to the branch. A patient registered at one branch is seen at another
    with their history intact; stock and money are not shared, because they are
    physically somewhere.

      4 tables stay shared      - the product's own menu and screen catalogue
      27 tables take tenant_id
      44 tables take tenant_id and branch_id
      71 of 75 carry a tenant in total

    Idempotent: every step checks before it acts, so it can be re-run.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

------------------------------------------------------------------ tenants and branches
IF OBJECT_ID('dbo.tenants', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.tenants (
        tenant_id       INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_tenants PRIMARY KEY,
        tenant_name     NVARCHAR(200) NOT NULL CONSTRAINT UQ_tenants_name UNIQUE,
        -- Identifies the clinic in its own web address, and is how a sign-in knows
        -- which tenant it belongs to before any user exists in the request.
        subdomain       NVARCHAR(63)  NOT NULL CONSTRAINT UQ_tenants_subdomain UNIQUE,
        legal_name      NVARCHAR(255) NULL,
        contact_email   NVARCHAR(255) NULL,
        contact_phone   NVARCHAR(20)  NULL,
        -- Bill and receipt numbering is one series per clinic, so the counter lives here.
        bill_number_prefix NVARCHAR(10) NULL,
        is_active       BIT NOT NULL CONSTRAINT DF_tenants_active DEFAULT (1),
        is_deleted      BIT NOT NULL CONSTRAINT DF_tenants_deleted DEFAULT (0),
        created_at      DATETIME2 NOT NULL CONSTRAINT DF_tenants_created DEFAULT (SYSUTCDATETIME()),
        updated_at      DATETIME2 NULL,
        CONSTRAINT CK_tenants_subdomain CHECK (subdomain NOT LIKE '%[^a-z0-9-]%')
    );
END
GO

IF OBJECT_ID('dbo.branches', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.branches (
        branch_id     INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_branches PRIMARY KEY,
        tenant_id     INT NOT NULL,
        branch_name   NVARCHAR(200) NOT NULL,
        branch_code   NVARCHAR(20)  NULL,
        address_line1 NVARCHAR(MAX) NULL,
        city          NVARCHAR(100) NULL,
        state         NVARCHAR(100) NULL,
        pincode       NVARCHAR(10)  NULL,
        phone         NVARCHAR(20)  NULL,
        -- Exactly one branch per tenant is the default for a user who has no explicit branch.
        is_primary    BIT NOT NULL CONSTRAINT DF_branches_primary DEFAULT (0),
        is_active     BIT NOT NULL CONSTRAINT DF_branches_active DEFAULT (1),
        is_deleted    BIT NOT NULL CONSTRAINT DF_branches_deleted DEFAULT (0),
        created_at    DATETIME2 NOT NULL CONSTRAINT DF_branches_created DEFAULT (SYSUTCDATETIME()),
        updated_at    DATETIME2 NULL,
        CONSTRAINT FK_branches_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id),
        -- Two clinics may both have a "Kothrud" branch; one clinic may not.
        CONSTRAINT UQ_branches_name UNIQUE (tenant_id, branch_name)
    );
    CREATE INDEX IX_branches_tenant ON dbo.branches (tenant_id, is_active);
END
GO

------------------------------------------------------------------ the first tenant
IF NOT EXISTS (SELECT 1 FROM dbo.tenants WHERE subdomain = 'healandcare')
    INSERT INTO dbo.tenants (tenant_name, subdomain, legal_name, bill_number_prefix)
    VALUES (N'Heal & Care', 'healandcare', N'Heal & Care Ayurveda Clinic', N'HC');
GO

DECLARE @tenant INT = (SELECT tenant_id FROM dbo.tenants WHERE subdomain = 'healandcare');

IF NOT EXISTS (SELECT 1 FROM dbo.branches WHERE tenant_id = @tenant AND branch_name = N'Main Branch')
    INSERT INTO dbo.branches (tenant_id, branch_name, branch_code, city, state, is_primary)
    VALUES (@tenant, N'Main Branch', N'MAIN', N'Pune', N'Maharashtra', 1);
GO

------------------------------------------------------------------ columns, backfill, constraints
DECLARE @tenant INT = (SELECT tenant_id FROM dbo.tenants WHERE subdomain = 'healandcare');
DECLARE @branch INT = (SELECT TOP 1 branch_id FROM dbo.branches WHERE tenant_id = @tenant AND is_primary = 1);
DECLARE @sql NVARCHAR(MAX);

--================================================ clinic-wide tables
-- patients
IF COL_LENGTH('dbo.patients', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.patients ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.patients SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.patients ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.patients ADD CONSTRAINT FK_patients_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_patients_tenant ON dbo.patients (tenant_id)');
END

-- addictions
IF COL_LENGTH('dbo.addictions', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.addictions ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.addictions SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.addictions ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.addictions ADD CONSTRAINT FK_addictions_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_addictions_tenant ON dbo.addictions (tenant_id)');
END

-- allergies
IF COL_LENGTH('dbo.allergies', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.allergies ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.allergies SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.allergies ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.allergies ADD CONSTRAINT FK_allergies_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_allergies_tenant ON dbo.allergies (tenant_id)');
END

-- current_medications
IF COL_LENGTH('dbo.current_medications', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.current_medications ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.current_medications SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.current_medications ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.current_medications ADD CONSTRAINT FK_current_medications_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_current_medications_tenant ON dbo.current_medications (tenant_id)');
END

-- family_medical_history
IF COL_LENGTH('dbo.family_medical_history', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.family_medical_history ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.family_medical_history SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.family_medical_history ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.family_medical_history ADD CONSTRAINT FK_family_medical_history_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_family_medical_history_tenant ON dbo.family_medical_history (tenant_id)');
END

-- past_medical_history
IF COL_LENGTH('dbo.past_medical_history', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.past_medical_history ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.past_medical_history SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.past_medical_history ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.past_medical_history ADD CONSTRAINT FK_past_medical_history_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_past_medical_history_tenant ON dbo.past_medical_history (tenant_id)');
END

-- reproductive_history
IF COL_LENGTH('dbo.reproductive_history', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.reproductive_history ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.reproductive_history SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.reproductive_history ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.reproductive_history ADD CONSTRAINT FK_reproductive_history_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_reproductive_history_tenant ON dbo.reproductive_history (tenant_id)');
END

-- patient_occupation
IF COL_LENGTH('dbo.patient_occupation', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.patient_occupation ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.patient_occupation SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.patient_occupation ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.patient_occupation ADD CONSTRAINT FK_patient_occupation_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_patient_occupation_tenant ON dbo.patient_occupation (tenant_id)');
END

-- habbits
IF COL_LENGTH('dbo.habbits', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.habbits ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.habbits SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.habbits ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.habbits ADD CONSTRAINT FK_habbits_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_habbits_tenant ON dbo.habbits (tenant_id)');
END

-- medicines_master
IF COL_LENGTH('dbo.medicines_master', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.medicines_master ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.medicines_master SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.medicines_master ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.medicines_master ADD CONSTRAINT FK_medicines_master_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_medicines_master_tenant ON dbo.medicines_master (tenant_id)');
END

-- suppliers
IF COL_LENGTH('dbo.suppliers', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.suppliers ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.suppliers SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.suppliers ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.suppliers ADD CONSTRAINT FK_suppliers_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_suppliers_tenant ON dbo.suppliers (tenant_id)');
END

-- panchkarma_therapies
IF COL_LENGTH('dbo.panchkarma_therapies', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.panchkarma_therapies ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.panchkarma_therapies SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.panchkarma_therapies ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.panchkarma_therapies ADD CONSTRAINT FK_panchkarma_therapies_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_panchkarma_therapies_tenant ON dbo.panchkarma_therapies (tenant_id)');
END

-- staff
IF COL_LENGTH('dbo.staff', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.staff ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.staff SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.staff ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.staff ADD CONSTRAINT FK_staff_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_staff_tenant ON dbo.staff (tenant_id)');
END

-- doctors
IF COL_LENGTH('dbo.doctors', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.doctors ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.doctors SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.doctors ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.doctors ADD CONSTRAINT FK_doctors_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_doctors_tenant ON dbo.doctors (tenant_id)');
END

-- users
IF COL_LENGTH('dbo.users', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.users ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.users SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.users ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.users ADD CONSTRAINT FK_users_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_users_tenant ON dbo.users (tenant_id)');
END

-- refresh_tokens
IF COL_LENGTH('dbo.refresh_tokens', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.refresh_tokens ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.refresh_tokens SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.refresh_tokens ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.refresh_tokens ADD CONSTRAINT FK_refresh_tokens_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_refresh_tokens_tenant ON dbo.refresh_tokens (tenant_id)');
END

-- user_roles
IF COL_LENGTH('dbo.user_roles', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.user_roles ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.user_roles SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.user_roles ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.user_roles ADD CONSTRAINT FK_user_roles_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_user_roles_tenant ON dbo.user_roles (tenant_id)');
END

-- roles
IF COL_LENGTH('dbo.roles', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.roles ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.roles SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.roles ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.roles ADD CONSTRAINT FK_roles_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_roles_tenant ON dbo.roles (tenant_id)');
END

-- role_access_groups
IF COL_LENGTH('dbo.role_access_groups', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.role_access_groups ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.role_access_groups SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.role_access_groups ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.role_access_groups ADD CONSTRAINT FK_role_access_groups_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_role_access_groups_tenant ON dbo.role_access_groups (tenant_id)');
END

-- access_groups
IF COL_LENGTH('dbo.access_groups', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.access_groups ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.access_groups SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.access_groups ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.access_groups ADD CONSTRAINT FK_access_groups_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_access_groups_tenant ON dbo.access_groups (tenant_id)');
END

-- access_levels
IF COL_LENGTH('dbo.access_levels', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.access_levels ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.access_levels SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.access_levels ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.access_levels ADD CONSTRAINT FK_access_levels_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_access_levels_tenant ON dbo.access_levels (tenant_id)');
END

-- access_group_access_levels
IF COL_LENGTH('dbo.access_group_access_levels', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.access_group_access_levels ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.access_group_access_levels SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.access_group_access_levels ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.access_group_access_levels ADD CONSTRAINT FK_access_group_access_levels_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_access_group_access_levels_tenant ON dbo.access_group_access_levels (tenant_id)');
END

-- access_level_menus
IF COL_LENGTH('dbo.access_level_menus', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.access_level_menus ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.access_level_menus SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.access_level_menus ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.access_level_menus ADD CONSTRAINT FK_access_level_menus_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_access_level_menus_tenant ON dbo.access_level_menus (tenant_id)');
END

-- access_level_screens
IF COL_LENGTH('dbo.access_level_screens', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.access_level_screens ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.access_level_screens SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.access_level_screens ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.access_level_screens ADD CONSTRAINT FK_access_level_screens_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_access_level_screens_tenant ON dbo.access_level_screens (tenant_id)');
END

-- access_level_sections
IF COL_LENGTH('dbo.access_level_sections', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.access_level_sections ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.access_level_sections SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.access_level_sections ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.access_level_sections ADD CONSTRAINT FK_access_level_sections_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_access_level_sections_tenant ON dbo.access_level_sections (tenant_id)');
END

-- access_level_section_fields
IF COL_LENGTH('dbo.access_level_section_fields', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.access_level_section_fields ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.access_level_section_fields SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.access_level_section_fields ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.access_level_section_fields ADD CONSTRAINT FK_access_level_section_fields_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_access_level_section_fields_tenant ON dbo.access_level_section_fields (tenant_id)');
END

-- audit_log
IF COL_LENGTH('dbo.audit_log', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.audit_log ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.audit_log SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.audit_log ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.audit_log ADD CONSTRAINT FK_audit_log_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_audit_log_tenant ON dbo.audit_log (tenant_id)');
END

--================================================ branch tables
-- appointments
IF COL_LENGTH('dbo.appointments', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.appointments ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.appointments SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.appointments ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.appointments ADD CONSTRAINT FK_appointments_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_appointments_tenant ON dbo.appointments (tenant_id)');
END
IF COL_LENGTH('dbo.appointments', 'branch_id') IS NULL
BEGIN
    ALTER TABLE dbo.appointments ADD branch_id INT NULL;
    EXEC('UPDATE dbo.appointments SET branch_id = ' + @branch + ' WHERE branch_id IS NULL');
    EXEC('ALTER TABLE dbo.appointments ALTER COLUMN branch_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.appointments ADD CONSTRAINT FK_appointments_branch FOREIGN KEY (branch_id) REFERENCES dbo.branches (branch_id)');
    EXEC('CREATE INDEX IX_appointments_branch ON dbo.appointments (tenant_id, branch_id)');
END

-- appointment_history
IF COL_LENGTH('dbo.appointment_history', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.appointment_history ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.appointment_history SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.appointment_history ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.appointment_history ADD CONSTRAINT FK_appointment_history_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_appointment_history_tenant ON dbo.appointment_history (tenant_id)');
END
IF COL_LENGTH('dbo.appointment_history', 'branch_id') IS NULL
BEGIN
    ALTER TABLE dbo.appointment_history ADD branch_id INT NULL;
    EXEC('UPDATE dbo.appointment_history SET branch_id = ' + @branch + ' WHERE branch_id IS NULL');
    EXEC('ALTER TABLE dbo.appointment_history ALTER COLUMN branch_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.appointment_history ADD CONSTRAINT FK_appointment_history_branch FOREIGN KEY (branch_id) REFERENCES dbo.branches (branch_id)');
    EXEC('CREATE INDEX IX_appointment_history_branch ON dbo.appointment_history (tenant_id, branch_id)');
END

-- appointment_reminders
IF COL_LENGTH('dbo.appointment_reminders', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.appointment_reminders ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.appointment_reminders SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.appointment_reminders ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.appointment_reminders ADD CONSTRAINT FK_appointment_reminders_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_appointment_reminders_tenant ON dbo.appointment_reminders (tenant_id)');
END
IF COL_LENGTH('dbo.appointment_reminders', 'branch_id') IS NULL
BEGIN
    ALTER TABLE dbo.appointment_reminders ADD branch_id INT NULL;
    EXEC('UPDATE dbo.appointment_reminders SET branch_id = ' + @branch + ' WHERE branch_id IS NULL');
    EXEC('ALTER TABLE dbo.appointment_reminders ALTER COLUMN branch_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.appointment_reminders ADD CONSTRAINT FK_appointment_reminders_branch FOREIGN KEY (branch_id) REFERENCES dbo.branches (branch_id)');
    EXEC('CREATE INDEX IX_appointment_reminders_branch ON dbo.appointment_reminders (tenant_id, branch_id)');
END

-- appointment_slots
IF COL_LENGTH('dbo.appointment_slots', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.appointment_slots ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.appointment_slots SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.appointment_slots ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.appointment_slots ADD CONSTRAINT FK_appointment_slots_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_appointment_slots_tenant ON dbo.appointment_slots (tenant_id)');
END
IF COL_LENGTH('dbo.appointment_slots', 'branch_id') IS NULL
BEGIN
    ALTER TABLE dbo.appointment_slots ADD branch_id INT NULL;
    EXEC('UPDATE dbo.appointment_slots SET branch_id = ' + @branch + ' WHERE branch_id IS NULL');
    EXEC('ALTER TABLE dbo.appointment_slots ALTER COLUMN branch_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.appointment_slots ADD CONSTRAINT FK_appointment_slots_branch FOREIGN KEY (branch_id) REFERENCES dbo.branches (branch_id)');
    EXEC('CREATE INDEX IX_appointment_slots_branch ON dbo.appointment_slots (tenant_id, branch_id)');
END

-- appointment_therapies
IF COL_LENGTH('dbo.appointment_therapies', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.appointment_therapies ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.appointment_therapies SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.appointment_therapies ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.appointment_therapies ADD CONSTRAINT FK_appointment_therapies_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_appointment_therapies_tenant ON dbo.appointment_therapies (tenant_id)');
END
IF COL_LENGTH('dbo.appointment_therapies', 'branch_id') IS NULL
BEGIN
    ALTER TABLE dbo.appointment_therapies ADD branch_id INT NULL;
    EXEC('UPDATE dbo.appointment_therapies SET branch_id = ' + @branch + ' WHERE branch_id IS NULL');
    EXEC('ALTER TABLE dbo.appointment_therapies ALTER COLUMN branch_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.appointment_therapies ADD CONSTRAINT FK_appointment_therapies_branch FOREIGN KEY (branch_id) REFERENCES dbo.branches (branch_id)');
    EXEC('CREATE INDEX IX_appointment_therapies_branch ON dbo.appointment_therapies (tenant_id, branch_id)');
END

-- appointment_therapists
IF COL_LENGTH('dbo.appointment_therapists', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.appointment_therapists ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.appointment_therapists SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.appointment_therapists ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.appointment_therapists ADD CONSTRAINT FK_appointment_therapists_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_appointment_therapists_tenant ON dbo.appointment_therapists (tenant_id)');
END
IF COL_LENGTH('dbo.appointment_therapists', 'branch_id') IS NULL
BEGIN
    ALTER TABLE dbo.appointment_therapists ADD branch_id INT NULL;
    EXEC('UPDATE dbo.appointment_therapists SET branch_id = ' + @branch + ' WHERE branch_id IS NULL');
    EXEC('ALTER TABLE dbo.appointment_therapists ALTER COLUMN branch_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.appointment_therapists ADD CONSTRAINT FK_appointment_therapists_branch FOREIGN KEY (branch_id) REFERENCES dbo.branches (branch_id)');
    EXEC('CREATE INDEX IX_appointment_therapists_branch ON dbo.appointment_therapists (tenant_id, branch_id)');
END

-- doctor_schedule
IF COL_LENGTH('dbo.doctor_schedule', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.doctor_schedule ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.doctor_schedule SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.doctor_schedule ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.doctor_schedule ADD CONSTRAINT FK_doctor_schedule_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_doctor_schedule_tenant ON dbo.doctor_schedule (tenant_id)');
END
IF COL_LENGTH('dbo.doctor_schedule', 'branch_id') IS NULL
BEGIN
    ALTER TABLE dbo.doctor_schedule ADD branch_id INT NULL;
    EXEC('UPDATE dbo.doctor_schedule SET branch_id = ' + @branch + ' WHERE branch_id IS NULL');
    EXEC('ALTER TABLE dbo.doctor_schedule ALTER COLUMN branch_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.doctor_schedule ADD CONSTRAINT FK_doctor_schedule_branch FOREIGN KEY (branch_id) REFERENCES dbo.branches (branch_id)');
    EXEC('CREATE INDEX IX_doctor_schedule_branch ON dbo.doctor_schedule (tenant_id, branch_id)');
END

-- therapist_schedule
IF COL_LENGTH('dbo.therapist_schedule', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.therapist_schedule ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.therapist_schedule SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.therapist_schedule ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.therapist_schedule ADD CONSTRAINT FK_therapist_schedule_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_therapist_schedule_tenant ON dbo.therapist_schedule (tenant_id)');
END
IF COL_LENGTH('dbo.therapist_schedule', 'branch_id') IS NULL
BEGIN
    ALTER TABLE dbo.therapist_schedule ADD branch_id INT NULL;
    EXEC('UPDATE dbo.therapist_schedule SET branch_id = ' + @branch + ' WHERE branch_id IS NULL');
    EXEC('ALTER TABLE dbo.therapist_schedule ALTER COLUMN branch_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.therapist_schedule ADD CONSTRAINT FK_therapist_schedule_branch FOREIGN KEY (branch_id) REFERENCES dbo.branches (branch_id)');
    EXEC('CREATE INDEX IX_therapist_schedule_branch ON dbo.therapist_schedule (tenant_id, branch_id)');
END

-- therapist_slots
IF COL_LENGTH('dbo.therapist_slots', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.therapist_slots ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.therapist_slots SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.therapist_slots ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.therapist_slots ADD CONSTRAINT FK_therapist_slots_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_therapist_slots_tenant ON dbo.therapist_slots (tenant_id)');
END
IF COL_LENGTH('dbo.therapist_slots', 'branch_id') IS NULL
BEGIN
    ALTER TABLE dbo.therapist_slots ADD branch_id INT NULL;
    EXEC('UPDATE dbo.therapist_slots SET branch_id = ' + @branch + ' WHERE branch_id IS NULL');
    EXEC('ALTER TABLE dbo.therapist_slots ALTER COLUMN branch_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.therapist_slots ADD CONSTRAINT FK_therapist_slots_branch FOREIGN KEY (branch_id) REFERENCES dbo.branches (branch_id)');
    EXEC('CREATE INDEX IX_therapist_slots_branch ON dbo.therapist_slots (tenant_id, branch_id)');
END

-- panchkarma_rooms
IF COL_LENGTH('dbo.panchkarma_rooms', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.panchkarma_rooms ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.panchkarma_rooms SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.panchkarma_rooms ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.panchkarma_rooms ADD CONSTRAINT FK_panchkarma_rooms_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_panchkarma_rooms_tenant ON dbo.panchkarma_rooms (tenant_id)');
END
IF COL_LENGTH('dbo.panchkarma_rooms', 'branch_id') IS NULL
BEGIN
    ALTER TABLE dbo.panchkarma_rooms ADD branch_id INT NULL;
    EXEC('UPDATE dbo.panchkarma_rooms SET branch_id = ' + @branch + ' WHERE branch_id IS NULL');
    EXEC('ALTER TABLE dbo.panchkarma_rooms ALTER COLUMN branch_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.panchkarma_rooms ADD CONSTRAINT FK_panchkarma_rooms_branch FOREIGN KEY (branch_id) REFERENCES dbo.branches (branch_id)');
    EXEC('CREATE INDEX IX_panchkarma_rooms_branch ON dbo.panchkarma_rooms (tenant_id, branch_id)');
END

-- panchkarma_sessions
IF COL_LENGTH('dbo.panchkarma_sessions', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.panchkarma_sessions ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.panchkarma_sessions SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.panchkarma_sessions ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.panchkarma_sessions ADD CONSTRAINT FK_panchkarma_sessions_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_panchkarma_sessions_tenant ON dbo.panchkarma_sessions (tenant_id)');
END
IF COL_LENGTH('dbo.panchkarma_sessions', 'branch_id') IS NULL
BEGIN
    ALTER TABLE dbo.panchkarma_sessions ADD branch_id INT NULL;
    EXEC('UPDATE dbo.panchkarma_sessions SET branch_id = ' + @branch + ' WHERE branch_id IS NULL');
    EXEC('ALTER TABLE dbo.panchkarma_sessions ALTER COLUMN branch_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.panchkarma_sessions ADD CONSTRAINT FK_panchkarma_sessions_branch FOREIGN KEY (branch_id) REFERENCES dbo.branches (branch_id)');
    EXEC('CREATE INDEX IX_panchkarma_sessions_branch ON dbo.panchkarma_sessions (tenant_id, branch_id)');
END

-- patient_encounters
IF COL_LENGTH('dbo.patient_encounters', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.patient_encounters ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.patient_encounters SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.patient_encounters ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.patient_encounters ADD CONSTRAINT FK_patient_encounters_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_patient_encounters_tenant ON dbo.patient_encounters (tenant_id)');
END
IF COL_LENGTH('dbo.patient_encounters', 'branch_id') IS NULL
BEGIN
    ALTER TABLE dbo.patient_encounters ADD branch_id INT NULL;
    EXEC('UPDATE dbo.patient_encounters SET branch_id = ' + @branch + ' WHERE branch_id IS NULL');
    EXEC('ALTER TABLE dbo.patient_encounters ALTER COLUMN branch_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.patient_encounters ADD CONSTRAINT FK_patient_encounters_branch FOREIGN KEY (branch_id) REFERENCES dbo.branches (branch_id)');
    EXEC('CREATE INDEX IX_patient_encounters_branch ON dbo.patient_encounters (tenant_id, branch_id)');
END

-- visit_vitals
IF COL_LENGTH('dbo.visit_vitals', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.visit_vitals ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.visit_vitals SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.visit_vitals ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.visit_vitals ADD CONSTRAINT FK_visit_vitals_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_visit_vitals_tenant ON dbo.visit_vitals (tenant_id)');
END
IF COL_LENGTH('dbo.visit_vitals', 'branch_id') IS NULL
BEGIN
    ALTER TABLE dbo.visit_vitals ADD branch_id INT NULL;
    EXEC('UPDATE dbo.visit_vitals SET branch_id = ' + @branch + ' WHERE branch_id IS NULL');
    EXEC('ALTER TABLE dbo.visit_vitals ALTER COLUMN branch_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.visit_vitals ADD CONSTRAINT FK_visit_vitals_branch FOREIGN KEY (branch_id) REFERENCES dbo.branches (branch_id)');
    EXEC('CREATE INDEX IX_visit_vitals_branch ON dbo.visit_vitals (tenant_id, branch_id)');
END

-- visit_complaints
IF COL_LENGTH('dbo.visit_complaints', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.visit_complaints ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.visit_complaints SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.visit_complaints ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.visit_complaints ADD CONSTRAINT FK_visit_complaints_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_visit_complaints_tenant ON dbo.visit_complaints (tenant_id)');
END
IF COL_LENGTH('dbo.visit_complaints', 'branch_id') IS NULL
BEGIN
    ALTER TABLE dbo.visit_complaints ADD branch_id INT NULL;
    EXEC('UPDATE dbo.visit_complaints SET branch_id = ' + @branch + ' WHERE branch_id IS NULL');
    EXEC('ALTER TABLE dbo.visit_complaints ALTER COLUMN branch_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.visit_complaints ADD CONSTRAINT FK_visit_complaints_branch FOREIGN KEY (branch_id) REFERENCES dbo.branches (branch_id)');
    EXEC('CREATE INDEX IX_visit_complaints_branch ON dbo.visit_complaints (tenant_id, branch_id)');
END

-- daily_routine
IF COL_LENGTH('dbo.daily_routine', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.daily_routine ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.daily_routine SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.daily_routine ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.daily_routine ADD CONSTRAINT FK_daily_routine_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_daily_routine_tenant ON dbo.daily_routine (tenant_id)');
END
IF COL_LENGTH('dbo.daily_routine', 'branch_id') IS NULL
BEGIN
    ALTER TABLE dbo.daily_routine ADD branch_id INT NULL;
    EXEC('UPDATE dbo.daily_routine SET branch_id = ' + @branch + ' WHERE branch_id IS NULL');
    EXEC('ALTER TABLE dbo.daily_routine ALTER COLUMN branch_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.daily_routine ADD CONSTRAINT FK_daily_routine_branch FOREIGN KEY (branch_id) REFERENCES dbo.branches (branch_id)');
    EXEC('CREATE INDEX IX_daily_routine_branch ON dbo.daily_routine (tenant_id, branch_id)');
END

-- dietary_habits
IF COL_LENGTH('dbo.dietary_habits', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.dietary_habits ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.dietary_habits SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.dietary_habits ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.dietary_habits ADD CONSTRAINT FK_dietary_habits_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_dietary_habits_tenant ON dbo.dietary_habits (tenant_id)');
END
IF COL_LENGTH('dbo.dietary_habits', 'branch_id') IS NULL
BEGIN
    ALTER TABLE dbo.dietary_habits ADD branch_id INT NULL;
    EXEC('UPDATE dbo.dietary_habits SET branch_id = ' + @branch + ' WHERE branch_id IS NULL');
    EXEC('ALTER TABLE dbo.dietary_habits ALTER COLUMN branch_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.dietary_habits ADD CONSTRAINT FK_dietary_habits_branch FOREIGN KEY (branch_id) REFERENCES dbo.branches (branch_id)');
    EXEC('CREATE INDEX IX_dietary_habits_branch ON dbo.dietary_habits (tenant_id, branch_id)');
END

-- bowel_habits
IF COL_LENGTH('dbo.bowel_habits', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.bowel_habits ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.bowel_habits SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.bowel_habits ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.bowel_habits ADD CONSTRAINT FK_bowel_habits_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_bowel_habits_tenant ON dbo.bowel_habits (tenant_id)');
END
IF COL_LENGTH('dbo.bowel_habits', 'branch_id') IS NULL
BEGIN
    ALTER TABLE dbo.bowel_habits ADD branch_id INT NULL;
    EXEC('UPDATE dbo.bowel_habits SET branch_id = ' + @branch + ' WHERE branch_id IS NULL');
    EXEC('ALTER TABLE dbo.bowel_habits ALTER COLUMN branch_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.bowel_habits ADD CONSTRAINT FK_bowel_habits_branch FOREIGN KEY (branch_id) REFERENCES dbo.branches (branch_id)');
    EXEC('CREATE INDEX IX_bowel_habits_branch ON dbo.bowel_habits (tenant_id, branch_id)');
END

-- urinary_habits
IF COL_LENGTH('dbo.urinary_habits', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.urinary_habits ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.urinary_habits SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.urinary_habits ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.urinary_habits ADD CONSTRAINT FK_urinary_habits_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_urinary_habits_tenant ON dbo.urinary_habits (tenant_id)');
END
IF COL_LENGTH('dbo.urinary_habits', 'branch_id') IS NULL
BEGIN
    ALTER TABLE dbo.urinary_habits ADD branch_id INT NULL;
    EXEC('UPDATE dbo.urinary_habits SET branch_id = ' + @branch + ' WHERE branch_id IS NULL');
    EXEC('ALTER TABLE dbo.urinary_habits ALTER COLUMN branch_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.urinary_habits ADD CONSTRAINT FK_urinary_habits_branch FOREIGN KEY (branch_id) REFERENCES dbo.branches (branch_id)');
    EXEC('CREATE INDEX IX_urinary_habits_branch ON dbo.urinary_habits (tenant_id, branch_id)');
END

-- perspiration
IF COL_LENGTH('dbo.perspiration', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.perspiration ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.perspiration SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.perspiration ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.perspiration ADD CONSTRAINT FK_perspiration_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_perspiration_tenant ON dbo.perspiration (tenant_id)');
END
IF COL_LENGTH('dbo.perspiration', 'branch_id') IS NULL
BEGIN
    ALTER TABLE dbo.perspiration ADD branch_id INT NULL;
    EXEC('UPDATE dbo.perspiration SET branch_id = ' + @branch + ' WHERE branch_id IS NULL');
    EXEC('ALTER TABLE dbo.perspiration ALTER COLUMN branch_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.perspiration ADD CONSTRAINT FK_perspiration_branch FOREIGN KEY (branch_id) REFERENCES dbo.branches (branch_id)');
    EXEC('CREATE INDEX IX_perspiration_branch ON dbo.perspiration (tenant_id, branch_id)');
END

-- sleep_patterns
IF COL_LENGTH('dbo.sleep_patterns', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.sleep_patterns ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.sleep_patterns SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.sleep_patterns ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.sleep_patterns ADD CONSTRAINT FK_sleep_patterns_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_sleep_patterns_tenant ON dbo.sleep_patterns (tenant_id)');
END
IF COL_LENGTH('dbo.sleep_patterns', 'branch_id') IS NULL
BEGIN
    ALTER TABLE dbo.sleep_patterns ADD branch_id INT NULL;
    EXEC('UPDATE dbo.sleep_patterns SET branch_id = ' + @branch + ' WHERE branch_id IS NULL');
    EXEC('ALTER TABLE dbo.sleep_patterns ALTER COLUMN branch_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.sleep_patterns ADD CONSTRAINT FK_sleep_patterns_branch FOREIGN KEY (branch_id) REFERENCES dbo.branches (branch_id)');
    EXEC('CREATE INDEX IX_sleep_patterns_branch ON dbo.sleep_patterns (tenant_id, branch_id)');
END

-- sensory_details
IF COL_LENGTH('dbo.sensory_details', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.sensory_details ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.sensory_details SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.sensory_details ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.sensory_details ADD CONSTRAINT FK_sensory_details_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_sensory_details_tenant ON dbo.sensory_details (tenant_id)');
END
IF COL_LENGTH('dbo.sensory_details', 'branch_id') IS NULL
BEGIN
    ALTER TABLE dbo.sensory_details ADD branch_id INT NULL;
    EXEC('UPDATE dbo.sensory_details SET branch_id = ' + @branch + ' WHERE branch_id IS NULL');
    EXEC('ALTER TABLE dbo.sensory_details ALTER COLUMN branch_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.sensory_details ADD CONSTRAINT FK_sensory_details_branch FOREIGN KEY (branch_id) REFERENCES dbo.branches (branch_id)');
    EXEC('CREATE INDEX IX_sensory_details_branch ON dbo.sensory_details (tenant_id, branch_id)');
END

-- mental_health
IF COL_LENGTH('dbo.mental_health', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.mental_health ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.mental_health SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.mental_health ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.mental_health ADD CONSTRAINT FK_mental_health_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_mental_health_tenant ON dbo.mental_health (tenant_id)');
END
IF COL_LENGTH('dbo.mental_health', 'branch_id') IS NULL
BEGIN
    ALTER TABLE dbo.mental_health ADD branch_id INT NULL;
    EXEC('UPDATE dbo.mental_health SET branch_id = ' + @branch + ' WHERE branch_id IS NULL');
    EXEC('ALTER TABLE dbo.mental_health ALTER COLUMN branch_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.mental_health ADD CONSTRAINT FK_mental_health_branch FOREIGN KEY (branch_id) REFERENCES dbo.branches (branch_id)');
    EXEC('CREATE INDEX IX_mental_health_branch ON dbo.mental_health (tenant_id, branch_id)');
END

-- ayurvedic_examination
IF COL_LENGTH('dbo.ayurvedic_examination', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.ayurvedic_examination ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.ayurvedic_examination SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.ayurvedic_examination ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.ayurvedic_examination ADD CONSTRAINT FK_ayurvedic_examination_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_ayurvedic_examination_tenant ON dbo.ayurvedic_examination (tenant_id)');
END
IF COL_LENGTH('dbo.ayurvedic_examination', 'branch_id') IS NULL
BEGIN
    ALTER TABLE dbo.ayurvedic_examination ADD branch_id INT NULL;
    EXEC('UPDATE dbo.ayurvedic_examination SET branch_id = ' + @branch + ' WHERE branch_id IS NULL');
    EXEC('ALTER TABLE dbo.ayurvedic_examination ALTER COLUMN branch_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.ayurvedic_examination ADD CONSTRAINT FK_ayurvedic_examination_branch FOREIGN KEY (branch_id) REFERENCES dbo.branches (branch_id)');
    EXEC('CREATE INDEX IX_ayurvedic_examination_branch ON dbo.ayurvedic_examination (tenant_id, branch_id)');
END

-- nadi_pariksha
IF COL_LENGTH('dbo.nadi_pariksha', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.nadi_pariksha ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.nadi_pariksha SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.nadi_pariksha ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.nadi_pariksha ADD CONSTRAINT FK_nadi_pariksha_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_nadi_pariksha_tenant ON dbo.nadi_pariksha (tenant_id)');
END
IF COL_LENGTH('dbo.nadi_pariksha', 'branch_id') IS NULL
BEGIN
    ALTER TABLE dbo.nadi_pariksha ADD branch_id INT NULL;
    EXEC('UPDATE dbo.nadi_pariksha SET branch_id = ' + @branch + ' WHERE branch_id IS NULL');
    EXEC('ALTER TABLE dbo.nadi_pariksha ALTER COLUMN branch_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.nadi_pariksha ADD CONSTRAINT FK_nadi_pariksha_branch FOREIGN KEY (branch_id) REFERENCES dbo.branches (branch_id)');
    EXEC('CREATE INDEX IX_nadi_pariksha_branch ON dbo.nadi_pariksha (tenant_id, branch_id)');
END

-- ashtavidha_pariksha
IF COL_LENGTH('dbo.ashtavidha_pariksha', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.ashtavidha_pariksha ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.ashtavidha_pariksha SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.ashtavidha_pariksha ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.ashtavidha_pariksha ADD CONSTRAINT FK_ashtavidha_pariksha_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_ashtavidha_pariksha_tenant ON dbo.ashtavidha_pariksha (tenant_id)');
END
IF COL_LENGTH('dbo.ashtavidha_pariksha', 'branch_id') IS NULL
BEGIN
    ALTER TABLE dbo.ashtavidha_pariksha ADD branch_id INT NULL;
    EXEC('UPDATE dbo.ashtavidha_pariksha SET branch_id = ' + @branch + ' WHERE branch_id IS NULL');
    EXEC('ALTER TABLE dbo.ashtavidha_pariksha ALTER COLUMN branch_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.ashtavidha_pariksha ADD CONSTRAINT FK_ashtavidha_pariksha_branch FOREIGN KEY (branch_id) REFERENCES dbo.branches (branch_id)');
    EXEC('CREATE INDEX IX_ashtavidha_pariksha_branch ON dbo.ashtavidha_pariksha (tenant_id, branch_id)');
END

-- physical_examination
IF COL_LENGTH('dbo.physical_examination', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.physical_examination ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.physical_examination SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.physical_examination ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.physical_examination ADD CONSTRAINT FK_physical_examination_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_physical_examination_tenant ON dbo.physical_examination (tenant_id)');
END
IF COL_LENGTH('dbo.physical_examination', 'branch_id') IS NULL
BEGIN
    ALTER TABLE dbo.physical_examination ADD branch_id INT NULL;
    EXEC('UPDATE dbo.physical_examination SET branch_id = ' + @branch + ' WHERE branch_id IS NULL');
    EXEC('ALTER TABLE dbo.physical_examination ALTER COLUMN branch_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.physical_examination ADD CONSTRAINT FK_physical_examination_branch FOREIGN KEY (branch_id) REFERENCES dbo.branches (branch_id)');
    EXEC('CREATE INDEX IX_physical_examination_branch ON dbo.physical_examination (tenant_id, branch_id)');
END

-- encounter_diagnosis
IF COL_LENGTH('dbo.encounter_diagnosis', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.encounter_diagnosis ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.encounter_diagnosis SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.encounter_diagnosis ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.encounter_diagnosis ADD CONSTRAINT FK_encounter_diagnosis_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_encounter_diagnosis_tenant ON dbo.encounter_diagnosis (tenant_id)');
END
IF COL_LENGTH('dbo.encounter_diagnosis', 'branch_id') IS NULL
BEGIN
    ALTER TABLE dbo.encounter_diagnosis ADD branch_id INT NULL;
    EXEC('UPDATE dbo.encounter_diagnosis SET branch_id = ' + @branch + ' WHERE branch_id IS NULL');
    EXEC('ALTER TABLE dbo.encounter_diagnosis ALTER COLUMN branch_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.encounter_diagnosis ADD CONSTRAINT FK_encounter_diagnosis_branch FOREIGN KEY (branch_id) REFERENCES dbo.branches (branch_id)');
    EXEC('CREATE INDEX IX_encounter_diagnosis_branch ON dbo.encounter_diagnosis (tenant_id, branch_id)');
END

-- encounter_notes
IF COL_LENGTH('dbo.encounter_notes', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.encounter_notes ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.encounter_notes SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.encounter_notes ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.encounter_notes ADD CONSTRAINT FK_encounter_notes_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_encounter_notes_tenant ON dbo.encounter_notes (tenant_id)');
END
IF COL_LENGTH('dbo.encounter_notes', 'branch_id') IS NULL
BEGIN
    ALTER TABLE dbo.encounter_notes ADD branch_id INT NULL;
    EXEC('UPDATE dbo.encounter_notes SET branch_id = ' + @branch + ' WHERE branch_id IS NULL');
    EXEC('ALTER TABLE dbo.encounter_notes ALTER COLUMN branch_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.encounter_notes ADD CONSTRAINT FK_encounter_notes_branch FOREIGN KEY (branch_id) REFERENCES dbo.branches (branch_id)');
    EXEC('CREATE INDEX IX_encounter_notes_branch ON dbo.encounter_notes (tenant_id, branch_id)');
END

-- encounter_prescriptions
IF COL_LENGTH('dbo.encounter_prescriptions', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.encounter_prescriptions ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.encounter_prescriptions SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.encounter_prescriptions ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.encounter_prescriptions ADD CONSTRAINT FK_encounter_prescriptions_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_encounter_prescriptions_tenant ON dbo.encounter_prescriptions (tenant_id)');
END
IF COL_LENGTH('dbo.encounter_prescriptions', 'branch_id') IS NULL
BEGIN
    ALTER TABLE dbo.encounter_prescriptions ADD branch_id INT NULL;
    EXEC('UPDATE dbo.encounter_prescriptions SET branch_id = ' + @branch + ' WHERE branch_id IS NULL');
    EXEC('ALTER TABLE dbo.encounter_prescriptions ALTER COLUMN branch_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.encounter_prescriptions ADD CONSTRAINT FK_encounter_prescriptions_branch FOREIGN KEY (branch_id) REFERENCES dbo.branches (branch_id)');
    EXEC('CREATE INDEX IX_encounter_prescriptions_branch ON dbo.encounter_prescriptions (tenant_id, branch_id)');
END

-- encounter_treatment_plan
IF COL_LENGTH('dbo.encounter_treatment_plan', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.encounter_treatment_plan ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.encounter_treatment_plan SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.encounter_treatment_plan ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.encounter_treatment_plan ADD CONSTRAINT FK_encounter_treatment_plan_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_encounter_treatment_plan_tenant ON dbo.encounter_treatment_plan (tenant_id)');
END
IF COL_LENGTH('dbo.encounter_treatment_plan', 'branch_id') IS NULL
BEGIN
    ALTER TABLE dbo.encounter_treatment_plan ADD branch_id INT NULL;
    EXEC('UPDATE dbo.encounter_treatment_plan SET branch_id = ' + @branch + ' WHERE branch_id IS NULL');
    EXEC('ALTER TABLE dbo.encounter_treatment_plan ALTER COLUMN branch_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.encounter_treatment_plan ADD CONSTRAINT FK_encounter_treatment_plan_branch FOREIGN KEY (branch_id) REFERENCES dbo.branches (branch_id)');
    EXEC('CREATE INDEX IX_encounter_treatment_plan_branch ON dbo.encounter_treatment_plan (tenant_id, branch_id)');
END

-- panchkarma_procedures
IF COL_LENGTH('dbo.panchkarma_procedures', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.panchkarma_procedures ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.panchkarma_procedures SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.panchkarma_procedures ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.panchkarma_procedures ADD CONSTRAINT FK_panchkarma_procedures_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_panchkarma_procedures_tenant ON dbo.panchkarma_procedures (tenant_id)');
END
IF COL_LENGTH('dbo.panchkarma_procedures', 'branch_id') IS NULL
BEGIN
    ALTER TABLE dbo.panchkarma_procedures ADD branch_id INT NULL;
    EXEC('UPDATE dbo.panchkarma_procedures SET branch_id = ' + @branch + ' WHERE branch_id IS NULL');
    EXEC('ALTER TABLE dbo.panchkarma_procedures ALTER COLUMN branch_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.panchkarma_procedures ADD CONSTRAINT FK_panchkarma_procedures_branch FOREIGN KEY (branch_id) REFERENCES dbo.branches (branch_id)');
    EXEC('CREATE INDEX IX_panchkarma_procedures_branch ON dbo.panchkarma_procedures (tenant_id, branch_id)');
END

-- follow_up_schedule
IF COL_LENGTH('dbo.follow_up_schedule', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.follow_up_schedule ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.follow_up_schedule SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.follow_up_schedule ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.follow_up_schedule ADD CONSTRAINT FK_follow_up_schedule_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_follow_up_schedule_tenant ON dbo.follow_up_schedule (tenant_id)');
END
IF COL_LENGTH('dbo.follow_up_schedule', 'branch_id') IS NULL
BEGIN
    ALTER TABLE dbo.follow_up_schedule ADD branch_id INT NULL;
    EXEC('UPDATE dbo.follow_up_schedule SET branch_id = ' + @branch + ' WHERE branch_id IS NULL');
    EXEC('ALTER TABLE dbo.follow_up_schedule ALTER COLUMN branch_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.follow_up_schedule ADD CONSTRAINT FK_follow_up_schedule_branch FOREIGN KEY (branch_id) REFERENCES dbo.branches (branch_id)');
    EXEC('CREATE INDEX IX_follow_up_schedule_branch ON dbo.follow_up_schedule (tenant_id, branch_id)');
END

-- investigations
IF COL_LENGTH('dbo.investigations', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.investigations ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.investigations SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.investigations ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.investigations ADD CONSTRAINT FK_investigations_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_investigations_tenant ON dbo.investigations (tenant_id)');
END
IF COL_LENGTH('dbo.investigations', 'branch_id') IS NULL
BEGIN
    ALTER TABLE dbo.investigations ADD branch_id INT NULL;
    EXEC('UPDATE dbo.investigations SET branch_id = ' + @branch + ' WHERE branch_id IS NULL');
    EXEC('ALTER TABLE dbo.investigations ALTER COLUMN branch_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.investigations ADD CONSTRAINT FK_investigations_branch FOREIGN KEY (branch_id) REFERENCES dbo.branches (branch_id)');
    EXEC('CREATE INDEX IX_investigations_branch ON dbo.investigations (tenant_id, branch_id)');
END

-- investigation_reports
IF COL_LENGTH('dbo.investigation_reports', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.investigation_reports ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.investigation_reports SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.investigation_reports ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.investigation_reports ADD CONSTRAINT FK_investigation_reports_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_investigation_reports_tenant ON dbo.investigation_reports (tenant_id)');
END
IF COL_LENGTH('dbo.investigation_reports', 'branch_id') IS NULL
BEGIN
    ALTER TABLE dbo.investigation_reports ADD branch_id INT NULL;
    EXEC('UPDATE dbo.investigation_reports SET branch_id = ' + @branch + ' WHERE branch_id IS NULL');
    EXEC('ALTER TABLE dbo.investigation_reports ALTER COLUMN branch_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.investigation_reports ADD CONSTRAINT FK_investigation_reports_branch FOREIGN KEY (branch_id) REFERENCES dbo.branches (branch_id)');
    EXEC('CREATE INDEX IX_investigation_reports_branch ON dbo.investigation_reports (tenant_id, branch_id)');
END

-- investigation_report_files
IF COL_LENGTH('dbo.investigation_report_files', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.investigation_report_files ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.investigation_report_files SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.investigation_report_files ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.investigation_report_files ADD CONSTRAINT FK_investigation_report_files_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_investigation_report_files_tenant ON dbo.investigation_report_files (tenant_id)');
END
IF COL_LENGTH('dbo.investigation_report_files', 'branch_id') IS NULL
BEGIN
    ALTER TABLE dbo.investigation_report_files ADD branch_id INT NULL;
    EXEC('UPDATE dbo.investigation_report_files SET branch_id = ' + @branch + ' WHERE branch_id IS NULL');
    EXEC('ALTER TABLE dbo.investigation_report_files ALTER COLUMN branch_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.investigation_report_files ADD CONSTRAINT FK_investigation_report_files_branch FOREIGN KEY (branch_id) REFERENCES dbo.branches (branch_id)');
    EXEC('CREATE INDEX IX_investigation_report_files_branch ON dbo.investigation_report_files (tenant_id, branch_id)');
END

-- inventory
IF COL_LENGTH('dbo.inventory', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.inventory ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.inventory SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.inventory ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.inventory ADD CONSTRAINT FK_inventory_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_inventory_tenant ON dbo.inventory (tenant_id)');
END
IF COL_LENGTH('dbo.inventory', 'branch_id') IS NULL
BEGIN
    ALTER TABLE dbo.inventory ADD branch_id INT NULL;
    EXEC('UPDATE dbo.inventory SET branch_id = ' + @branch + ' WHERE branch_id IS NULL');
    EXEC('ALTER TABLE dbo.inventory ALTER COLUMN branch_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.inventory ADD CONSTRAINT FK_inventory_branch FOREIGN KEY (branch_id) REFERENCES dbo.branches (branch_id)');
    EXEC('CREATE INDEX IX_inventory_branch ON dbo.inventory (tenant_id, branch_id)');
END

-- stock_transactions
IF COL_LENGTH('dbo.stock_transactions', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.stock_transactions ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.stock_transactions SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.stock_transactions ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.stock_transactions ADD CONSTRAINT FK_stock_transactions_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_stock_transactions_tenant ON dbo.stock_transactions (tenant_id)');
END
IF COL_LENGTH('dbo.stock_transactions', 'branch_id') IS NULL
BEGIN
    ALTER TABLE dbo.stock_transactions ADD branch_id INT NULL;
    EXEC('UPDATE dbo.stock_transactions SET branch_id = ' + @branch + ' WHERE branch_id IS NULL');
    EXEC('ALTER TABLE dbo.stock_transactions ALTER COLUMN branch_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.stock_transactions ADD CONSTRAINT FK_stock_transactions_branch FOREIGN KEY (branch_id) REFERENCES dbo.branches (branch_id)');
    EXEC('CREATE INDEX IX_stock_transactions_branch ON dbo.stock_transactions (tenant_id, branch_id)');
END

-- stock_alerts
IF COL_LENGTH('dbo.stock_alerts', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.stock_alerts ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.stock_alerts SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.stock_alerts ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.stock_alerts ADD CONSTRAINT FK_stock_alerts_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_stock_alerts_tenant ON dbo.stock_alerts (tenant_id)');
END
IF COL_LENGTH('dbo.stock_alerts', 'branch_id') IS NULL
BEGIN
    ALTER TABLE dbo.stock_alerts ADD branch_id INT NULL;
    EXEC('UPDATE dbo.stock_alerts SET branch_id = ' + @branch + ' WHERE branch_id IS NULL');
    EXEC('ALTER TABLE dbo.stock_alerts ALTER COLUMN branch_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.stock_alerts ADD CONSTRAINT FK_stock_alerts_branch FOREIGN KEY (branch_id) REFERENCES dbo.branches (branch_id)');
    EXEC('CREATE INDEX IX_stock_alerts_branch ON dbo.stock_alerts (tenant_id, branch_id)');
END

-- purchase_orders
IF COL_LENGTH('dbo.purchase_orders', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.purchase_orders ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.purchase_orders SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.purchase_orders ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.purchase_orders ADD CONSTRAINT FK_purchase_orders_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_purchase_orders_tenant ON dbo.purchase_orders (tenant_id)');
END
IF COL_LENGTH('dbo.purchase_orders', 'branch_id') IS NULL
BEGIN
    ALTER TABLE dbo.purchase_orders ADD branch_id INT NULL;
    EXEC('UPDATE dbo.purchase_orders SET branch_id = ' + @branch + ' WHERE branch_id IS NULL');
    EXEC('ALTER TABLE dbo.purchase_orders ALTER COLUMN branch_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.purchase_orders ADD CONSTRAINT FK_purchase_orders_branch FOREIGN KEY (branch_id) REFERENCES dbo.branches (branch_id)');
    EXEC('CREATE INDEX IX_purchase_orders_branch ON dbo.purchase_orders (tenant_id, branch_id)');
END

-- purchase_order_items
IF COL_LENGTH('dbo.purchase_order_items', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.purchase_order_items ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.purchase_order_items SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.purchase_order_items ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.purchase_order_items ADD CONSTRAINT FK_purchase_order_items_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_purchase_order_items_tenant ON dbo.purchase_order_items (tenant_id)');
END
IF COL_LENGTH('dbo.purchase_order_items', 'branch_id') IS NULL
BEGIN
    ALTER TABLE dbo.purchase_order_items ADD branch_id INT NULL;
    EXEC('UPDATE dbo.purchase_order_items SET branch_id = ' + @branch + ' WHERE branch_id IS NULL');
    EXEC('ALTER TABLE dbo.purchase_order_items ALTER COLUMN branch_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.purchase_order_items ADD CONSTRAINT FK_purchase_order_items_branch FOREIGN KEY (branch_id) REFERENCES dbo.branches (branch_id)');
    EXEC('CREATE INDEX IX_purchase_order_items_branch ON dbo.purchase_order_items (tenant_id, branch_id)');
END

-- bills
IF COL_LENGTH('dbo.bills', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.bills ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.bills SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.bills ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.bills ADD CONSTRAINT FK_bills_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_bills_tenant ON dbo.bills (tenant_id)');
END
IF COL_LENGTH('dbo.bills', 'branch_id') IS NULL
BEGIN
    ALTER TABLE dbo.bills ADD branch_id INT NULL;
    EXEC('UPDATE dbo.bills SET branch_id = ' + @branch + ' WHERE branch_id IS NULL');
    EXEC('ALTER TABLE dbo.bills ALTER COLUMN branch_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.bills ADD CONSTRAINT FK_bills_branch FOREIGN KEY (branch_id) REFERENCES dbo.branches (branch_id)');
    EXEC('CREATE INDEX IX_bills_branch ON dbo.bills (tenant_id, branch_id)');
END

-- bill_items
IF COL_LENGTH('dbo.bill_items', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.bill_items ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.bill_items SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.bill_items ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.bill_items ADD CONSTRAINT FK_bill_items_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_bill_items_tenant ON dbo.bill_items (tenant_id)');
END
IF COL_LENGTH('dbo.bill_items', 'branch_id') IS NULL
BEGIN
    ALTER TABLE dbo.bill_items ADD branch_id INT NULL;
    EXEC('UPDATE dbo.bill_items SET branch_id = ' + @branch + ' WHERE branch_id IS NULL');
    EXEC('ALTER TABLE dbo.bill_items ALTER COLUMN branch_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.bill_items ADD CONSTRAINT FK_bill_items_branch FOREIGN KEY (branch_id) REFERENCES dbo.branches (branch_id)');
    EXEC('CREATE INDEX IX_bill_items_branch ON dbo.bill_items (tenant_id, branch_id)');
END

-- payments
IF COL_LENGTH('dbo.payments', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.payments ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.payments SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.payments ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.payments ADD CONSTRAINT FK_payments_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_payments_tenant ON dbo.payments (tenant_id)');
END
IF COL_LENGTH('dbo.payments', 'branch_id') IS NULL
BEGIN
    ALTER TABLE dbo.payments ADD branch_id INT NULL;
    EXEC('UPDATE dbo.payments SET branch_id = ' + @branch + ' WHERE branch_id IS NULL');
    EXEC('ALTER TABLE dbo.payments ALTER COLUMN branch_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.payments ADD CONSTRAINT FK_payments_branch FOREIGN KEY (branch_id) REFERENCES dbo.branches (branch_id)');
    EXEC('CREATE INDEX IX_payments_branch ON dbo.payments (tenant_id, branch_id)');
END

-- refunds
IF COL_LENGTH('dbo.refunds', 'tenant_id') IS NULL
BEGIN
    ALTER TABLE dbo.refunds ADD tenant_id INT NULL;
    EXEC('UPDATE dbo.refunds SET tenant_id = ' + @tenant + ' WHERE tenant_id IS NULL');
    EXEC('ALTER TABLE dbo.refunds ALTER COLUMN tenant_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.refunds ADD CONSTRAINT FK_refunds_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants (tenant_id)');
    EXEC('CREATE INDEX IX_refunds_tenant ON dbo.refunds (tenant_id)');
END
IF COL_LENGTH('dbo.refunds', 'branch_id') IS NULL
BEGIN
    ALTER TABLE dbo.refunds ADD branch_id INT NULL;
    EXEC('UPDATE dbo.refunds SET branch_id = ' + @branch + ' WHERE branch_id IS NULL');
    EXEC('ALTER TABLE dbo.refunds ALTER COLUMN branch_id INT NOT NULL');
    EXEC('ALTER TABLE dbo.refunds ADD CONSTRAINT FK_refunds_branch FOREIGN KEY (branch_id) REFERENCES dbo.branches (branch_id)');
    EXEC('CREATE INDEX IX_refunds_branch ON dbo.refunds (tenant_id, branch_id)');
END

--================================================ audit: optional branch
IF COL_LENGTH('dbo.audit_log', 'branch_id') IS NULL
BEGIN
    ALTER TABLE dbo.audit_log ADD branch_id INT NULL;
    EXEC('UPDATE dbo.audit_log SET branch_id = ' + @branch + ' WHERE branch_id IS NULL');
    EXEC('ALTER TABLE dbo.audit_log ADD CONSTRAINT FK_audit_log_branch FOREIGN KEY (branch_id) REFERENCES dbo.branches (branch_id)');
    EXEC('CREATE INDEX IX_audit_log_branch ON dbo.audit_log (tenant_id, branch_id)');
END

GO

------------------------------------------------------------------ report
SELECT 'tenants                : ' + CAST(COUNT(*) AS VARCHAR) FROM dbo.tenants;
SELECT 'branches               : ' + CAST(COUNT(*) AS VARCHAR) FROM dbo.branches;
SELECT 'tables with tenant_id  : ' + CAST(COUNT(*) AS VARCHAR) + '   (expected 71)'
FROM sys.columns c JOIN sys.tables t ON t.object_id = c.object_id WHERE c.name = 'tenant_id' AND t.name NOT IN ('tenants', 'branches');
SELECT 'tables with branch_id   : ' + CAST(COUNT(*) AS VARCHAR) + '   (expected 45)'
FROM sys.columns c JOIN sys.tables t ON t.object_id = c.object_id WHERE c.name = 'branch_id' AND t.name NOT IN ('tenants', 'branches');
SELECT 'rows still unassigned  : ' + CAST(
    (SELECT COUNT(*) FROM dbo.patients WHERE tenant_id IS NULL)
  + (SELECT COUNT(*) FROM dbo.appointments WHERE tenant_id IS NULL OR branch_id IS NULL)
  + (SELECT COUNT(*) FROM dbo.bills WHERE tenant_id IS NULL OR branch_id IS NULL) AS VARCHAR) + '   (expected 0)';
