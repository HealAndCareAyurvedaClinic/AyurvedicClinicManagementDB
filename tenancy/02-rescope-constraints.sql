/*
    Multi-tenancy: rescope the unique constraints, and index for the queries
    the application actually runs.

    Of the 32 unique constraints in the database, 17 genuinely assume a single
    clinic and are rescoped here. The rest are already safe:

      - screens, sections and section_fields are the shared product catalogue,
        so they stay global on purpose;
      - the junction tables - user_roles, role_access_groups, access_level_*,
        appointment_therapies and the rest - are keyed on parent ids which are
        already unique across the whole database, so they cannot collide.

    Run AFTER 01-add-tenant-and-branch.sql. Idempotent.
*/
SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;   -- required: staff carries a filtered index
SET XACT_ABORT ON;
GO

------------------------------------------------------------------ helper
-- Unique keys were mostly created without names, so they carry generated ones
-- like UQ__users__A9D10534. They are found by their columns rather than by name.
IF OBJECT_ID('tempdb..#drop_unique') IS NOT NULL DROP PROCEDURE #drop_unique;
GO
CREATE PROCEDURE #drop_unique @table SYSNAME, @cols NVARCHAR(500)
AS
BEGIN
    DECLARE @name SYSNAME, @sql NVARCHAR(MAX);

    SELECT TOP 1 @name = i.name
    FROM sys.indexes i
    WHERE i.object_id = OBJECT_ID('dbo.' + @table)
      AND i.is_unique = 1 AND i.is_primary_key = 0 AND i.name IS NOT NULL
      AND @cols = STUFF((SELECT ',' + c.name
                        FROM sys.index_columns ic
                        JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
                        WHERE ic.object_id = i.object_id AND ic.index_id = i.index_id
                          AND ic.is_included_column = 0
                        ORDER BY ic.key_ordinal FOR XML PATH('')), 1, 1, '');

    IF @name IS NULL RETURN;   -- already rescoped

    IF EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = @name AND parent_object_id = OBJECT_ID('dbo.' + @table))
        SET @sql = N'ALTER TABLE dbo.' + QUOTENAME(@table) + N' DROP CONSTRAINT ' + QUOTENAME(@name);
    ELSE
        SET @sql = N'DROP INDEX ' + QUOTENAME(@name) + N' ON dbo.' + QUOTENAME(@table);

    EXEC sp_executesql @sql;
    PRINT '  dropped ' + @name + ' on ' + @table;
END
GO

------------------------------------------------------------------ rescope
-- access_groups: every clinic names its own access groups
EXEC #drop_unique 'access_groups', 'access_group_name';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UQ_access_groups_access_group_name' AND object_id = OBJECT_ID('dbo.access_groups'))
    ALTER TABLE dbo.access_groups ADD CONSTRAINT UQ_access_groups_access_group_name UNIQUE (tenant_id, access_group_name);

-- access_levels: every clinic names its own access levels
EXEC #drop_unique 'access_levels', 'access_level_name';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UQ_access_levels_access_level_name' AND object_id = OBJECT_ID('dbo.access_levels'))
    ALTER TABLE dbo.access_levels ADD CONSTRAINT UQ_access_levels_access_level_name UNIQUE (tenant_id, access_level_name);

-- roles: every clinic has a Receptionist
EXEC #drop_unique 'roles', 'role_name';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UQ_roles_role_name' AND object_id = OBJECT_ID('dbo.roles'))
    ALTER TABLE dbo.roles ADD CONSTRAINT UQ_roles_role_name UNIQUE (tenant_id, role_name);

-- users: every clinic wants an admin (decision D6)
EXEC #drop_unique 'users', 'username';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UQ_users_username' AND object_id = OBJECT_ID('dbo.users'))
    ALTER TABLE dbo.users ADD CONSTRAINT UQ_users_username UNIQUE (tenant_id, username);

-- users: one person may hold a login at two clinics
EXEC #drop_unique 'users', 'email';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UQ_users_email' AND object_id = OBJECT_ID('dbo.users'))
    ALTER TABLE dbo.users ADD CONSTRAINT UQ_users_email UNIQUE (tenant_id, email);

-- patients: each clinic runs its own registration series
EXEC #drop_unique 'patients', 'registration_number';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UQ_patients_registration_number' AND object_id = OBJECT_ID('dbo.patients'))
    ALTER TABLE dbo.patients ADD CONSTRAINT UQ_patients_registration_number UNIQUE (tenant_id, registration_number);

-- doctors: a council number belongs to the person, not to our system
EXEC #drop_unique 'doctors', 'registration_number';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UQ_doctors_registration_number' AND object_id = OBJECT_ID('dbo.doctors'))
    ALTER TABLE dbo.doctors ADD CONSTRAINT UQ_doctors_registration_number UNIQUE (tenant_id, registration_number);

-- panchkarma_therapies: both clinics offer Abhyanga
EXEC #drop_unique 'panchkarma_therapies', 'therapy_name';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UQ_panchkarma_therapies_therapy_name' AND object_id = OBJECT_ID('dbo.panchkarma_therapies'))
    ALTER TABLE dbo.panchkarma_therapies ADD CONSTRAINT UQ_panchkarma_therapies_therapy_name UNIQUE (tenant_id, therapy_name);

-- patient_encounters: each clinic numbers its own visits
EXEC #drop_unique 'patient_encounters', 'encounter_sequence';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UQ_patient_encounters_encounter_sequence' AND object_id = OBJECT_ID('dbo.patient_encounters'))
    ALTER TABLE dbo.patient_encounters ADD CONSTRAINT UQ_patient_encounters_encounter_sequence UNIQUE (tenant_id, encounter_sequence);

-- bills: one numbering series per clinic, across branches (your decision)
EXEC #drop_unique 'bills', 'bill_number';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UQ_bills_bill_number' AND object_id = OBJECT_ID('dbo.bills'))
    ALTER TABLE dbo.bills ADD CONSTRAINT UQ_bills_bill_number UNIQUE (tenant_id, bill_number);

-- payments: follows the bill series
EXEC #drop_unique 'payments', 'payment_number';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UQ_payments_payment_number' AND object_id = OBJECT_ID('dbo.payments'))
    ALTER TABLE dbo.payments ADD CONSTRAINT UQ_payments_payment_number UNIQUE (tenant_id, payment_number);

-- purchase_orders: follows the bill series
EXEC #drop_unique 'purchase_orders', 'po_number';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UQ_purchase_orders_po_number' AND object_id = OBJECT_ID('dbo.purchase_orders'))
    ALTER TABLE dbo.purchase_orders ADD CONSTRAINT UQ_purchase_orders_po_number UNIQUE (tenant_id, po_number);

-- inventory: the same batch genuinely sits on two branches shelves
EXEC #drop_unique 'inventory', 'medicine_id,batch_number';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UQ_inventory_medicine_id_batch_number' AND object_id = OBJECT_ID('dbo.inventory'))
    ALTER TABLE dbo.inventory ADD CONSTRAINT UQ_inventory_medicine_id_batch_number UNIQUE (branch_id, medicine_id, batch_number);

-- panchkarma_rooms: both branches have a Therapy Room 1
EXEC #drop_unique 'panchkarma_rooms', 'room_name';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UQ_panchkarma_rooms_room_name' AND object_id = OBJECT_ID('dbo.panchkarma_rooms'))
    ALTER TABLE dbo.panchkarma_rooms ADD CONSTRAINT UQ_panchkarma_rooms_room_name UNIQUE (branch_id, room_name);

-- appointment_slots: a doctor may hold clinics at two branches
EXEC #drop_unique 'appointment_slots', 'doctor_id,slot_date,slot_time';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UQ_appointment_slots_doctor_id_slot_date_slot_time' AND object_id = OBJECT_ID('dbo.appointment_slots'))
    ALTER TABLE dbo.appointment_slots ADD CONSTRAINT UQ_appointment_slots_doctor_id_slot_date_slot_time UNIQUE (branch_id, doctor_id, slot_date, slot_time);

-- therapist_slots: a therapist may work at two branches
EXEC #drop_unique 'therapist_slots', 'therapist_id,slot_date,slot_time';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UQ_therapist_slots_therapist_id_slot_date_slot_time' AND object_id = OBJECT_ID('dbo.therapist_slots'))
    ALTER TABLE dbo.therapist_slots ADD CONSTRAINT UQ_therapist_slots_therapist_id_slot_date_slot_time UNIQUE (branch_id, therapist_id, slot_date, slot_time);

------------------------------------------------------------------ filtered
-- staff: unique only among staff who have a council number, now per clinic
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_staff_registration_number' AND object_id = OBJECT_ID('dbo.staff')
           AND NOT EXISTS (SELECT 1 FROM sys.index_columns ic
                           JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
                           WHERE ic.object_id = sys.indexes.object_id AND ic.index_id = sys.indexes.index_id
                             AND c.name = 'tenant_id'))
    DROP INDEX UX_staff_registration_number ON dbo.staff;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_staff_registration_number' AND object_id = OBJECT_ID('dbo.staff'))
    CREATE UNIQUE NONCLUSTERED INDEX UX_staff_registration_number ON dbo.staff (tenant_id, registration_number) WHERE ([registration_number] IS NOT NULL);

------------------------------------------------------------------ query indexes
-- the dashboard and worklist read a branch day at a time
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_appointments_tenant_branch_appointmentdate_appointmenttime' AND object_id = OBJECT_ID('dbo.appointments'))
    CREATE INDEX IX_appointments_tenant_branch_appointmentdate_appointmenttime ON dbo.appointments (tenant_id, branch_id, appointment_date, appointment_time);

-- a patient's appointment history
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_appointments_tenant_patient' AND object_id = OBJECT_ID('dbo.appointments'))
    CREATE INDEX IX_appointments_tenant_patient ON dbo.appointments (tenant_id, patient_id);

-- status filters on the lists
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_appointments_tenant_branch_appointmentstatus' AND object_id = OBJECT_ID('dbo.appointments'))
    CREATE INDEX IX_appointments_tenant_branch_appointmentstatus ON dbo.appointments (tenant_id, branch_id, appointment_status);

-- the day book
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_bills_tenant_branch_billdate' AND object_id = OBJECT_ID('dbo.bills'))
    CREATE INDEX IX_bills_tenant_branch_billdate ON dbo.bills (tenant_id, branch_id, bill_date);

-- bill_items had no index at all
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_bill_items_bill' AND object_id = OBJECT_ID('dbo.bill_items'))
    CREATE INDEX IX_bill_items_bill ON dbo.bill_items (bill_id);

-- the day book
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_payments_tenant_branch_paymentdate' AND object_id = OBJECT_ID('dbo.payments'))
    CREATE INDEX IX_payments_tenant_branch_paymentdate ON dbo.payments (tenant_id, branch_id, payment_date);

-- stock lookup while dispensing
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_inventory_tenant_branch_medicine' AND object_id = OBJECT_ID('dbo.inventory'))
    CREATE INDEX IX_inventory_tenant_branch_medicine ON dbo.inventory (tenant_id, branch_id, medicine_id);

-- the visit picker
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_patient_encounters_tenant_patient' AND object_id = OBJECT_ID('dbo.patient_encounters'))
    CREATE INDEX IX_patient_encounters_tenant_patient ON dbo.patient_encounters (tenant_id, patient_id);

-- search by phone number
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_patients_tenant_phone' AND object_id = OBJECT_ID('dbo.patients'))
    CREATE INDEX IX_patients_tenant_phone ON dbo.patients (tenant_id, phone);

GO
DROP PROCEDURE #drop_unique;
GO

------------------------------------------------------------------ report
SELECT 'unique keys now carrying tenant_id : ' + CAST(COUNT(DISTINCT i.object_id) AS VARCHAR)
FROM sys.indexes i
JOIN sys.index_columns ic ON ic.object_id = i.object_id AND ic.index_id = i.index_id
JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
WHERE i.is_unique = 1 AND i.is_primary_key = 0 AND c.name = 'tenant_id';

SELECT 'unique keys now carrying branch_id : ' + CAST(COUNT(DISTINCT i.object_id) AS VARCHAR)
FROM sys.indexes i
JOIN sys.index_columns ic ON ic.object_id = i.object_id AND ic.index_id = i.index_id
JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
WHERE i.is_unique = 1 AND i.is_primary_key = 0 AND c.name = 'branch_id';

SELECT 'appointments non-key indexes      : ' + CAST(COUNT(*) AS VARCHAR) + '   (was 0 - backlog S7)'
FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.appointments') AND is_primary_key = 0 AND name IS NOT NULL;
