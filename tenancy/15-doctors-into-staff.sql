/*
    One register of the people who work here.

    A doctor was a row in dbo.doctors and, if anybody also put them on the roster, a
    second row in dbo.staff with staff_type 'Doctor'. Nothing joined the two. The screens
    showed it plainly: a doctor added to the roster never appeared in the doctors list,
    and could not be booked, because appointments point at dbo.doctors and the roster is
    somewhere else entirely.

    The two tables shared eight columns - qualification, specialization,
    registration_number, phone, email, is_active, created_at, tenant_id. What dbo.doctors
    held and dbo.staff did not was one column: consultation_fee. A nullable decimal is an
    attribute, not a subtype, and it does not justify a second table, a second identifier
    for the same person, and two places to change a phone number.

    A therapist was already a staff row, scheduled through therapist_schedules. After this
    a doctor is too, and every practitioner has one shape.

    ---------------------------------------------------------------- what this does

      1. staff gains consultation_fee.
      2. Each doctors row is matched to a staff row by name within the same tenant and
         the fee carried across. A doctor with no matching staff member is REFUSED, not
         skipped - see below.
      3. The four foreign keys that pointed at doctors(doctor_id) are repointed at
         staff(staff_id): appointments, appointment_slots, doctor_schedule,
         panchkarma_sessions.
      4. dbo.doctors is dropped.

    ---------------------------------------------------------------- the dangerous part

    doctor_id and staff_id are different numbers for the same person. In DEV today
    Geetanjali is doctor 1 and staff 2, and Dhruvil is doctor 2 and staff 1 - they cross
    over. Repointing a foreign key does NOT rewrite the values in the referencing column,
    so any existing row would silently come to mean a different doctor.

    This script therefore refuses to run if any of the four tables holds a single row. It
    is written for the window where they are all empty, which is where this database is
    now and will not be for long. Running it against a database with appointments needs a
    deliberate id remap written for that data, not this script.

    Idempotent: if dbo.doctors is already gone there is nothing to do and it says so.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;
SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID('dbo.doctors', 'U') IS NULL
BEGIN
    PRINT '  dbo.doctors is already gone - nothing to do';
END
ELSE
BEGIN
    ---------------------------------------------------------------- refuse to guess
    DECLARE @rows INT =
        (SELECT COUNT(*) FROM dbo.appointments)
      + (SELECT COUNT(*) FROM dbo.appointment_slots)
      + (SELECT COUNT(*) FROM dbo.doctor_schedule)
      + (SELECT COUNT(*) FROM dbo.panchkarma_sessions);

    IF @rows > 0
        THROW 51000, 'Refusing to run: appointments, slots, schedules or sessions already reference doctor_id. doctor_id and staff_id are different numbers for the same person, so repointing the foreign keys would silently change who those rows mean. This needs an id remap written for the actual data.', 1;

    DECLARE @unmatched INT =
        (SELECT COUNT(*) FROM dbo.doctors d
          WHERE NOT EXISTS (SELECT 1 FROM dbo.staff s
                             WHERE s.staff_name = d.doctor_name
                               AND s.tenant_id  = d.tenant_id));

    IF @unmatched > 0
        THROW 51001, 'Refusing to run: some doctors have no staff member of the same name in the same clinic. Add them to the roster first, or the fee and their identity would be lost.', 1;

    ---------------------------------------------------------------- 1. the one real column
    IF COL_LENGTH('dbo.staff', 'consultation_fee') IS NULL
    BEGIN
        ALTER TABLE dbo.staff ADD consultation_fee DECIMAL(10, 2) NULL;
        PRINT '  staff.consultation_fee added';
    END
END
GO

-- Separate batch: the column has to exist before anything can be written to it.
IF OBJECT_ID('dbo.doctors', 'U') IS NOT NULL
BEGIN
    ---------------------------------------------------------------- 2. carry the fee over
    UPDATE s
       SET s.consultation_fee = d.consultation_fee
      FROM dbo.staff s
      JOIN dbo.doctors d
        ON d.doctor_name = s.staff_name
       AND d.tenant_id   = s.tenant_id
     WHERE d.consultation_fee IS NOT NULL;

    PRINT '  fees carried across: ' + CAST(@@ROWCOUNT AS VARCHAR);

    ---------------------------------------------------------------- 3. repoint the keys
    IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_apt_doctor')
        ALTER TABLE dbo.appointments DROP CONSTRAINT FK_apt_doctor;
    ALTER TABLE dbo.appointments WITH CHECK
        ADD CONSTRAINT FK_apt_doctor FOREIGN KEY (doctor_id) REFERENCES dbo.staff (staff_id);

    IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_as_doctor')
        ALTER TABLE dbo.appointment_slots DROP CONSTRAINT FK_as_doctor;
    ALTER TABLE dbo.appointment_slots WITH CHECK
        ADD CONSTRAINT FK_as_doctor FOREIGN KEY (doctor_id) REFERENCES dbo.staff (staff_id);

    IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_ds_doctor')
        ALTER TABLE dbo.doctor_schedule DROP CONSTRAINT FK_ds_doctor;
    ALTER TABLE dbo.doctor_schedule WITH CHECK
        ADD CONSTRAINT FK_ds_doctor FOREIGN KEY (doctor_id) REFERENCES dbo.staff (staff_id);

    IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_panchkarma_sessions_doctor')
        ALTER TABLE dbo.panchkarma_sessions DROP CONSTRAINT FK_panchkarma_sessions_doctor;
    ALTER TABLE dbo.panchkarma_sessions WITH CHECK
        ADD CONSTRAINT FK_panchkarma_sessions_doctor FOREIGN KEY (doctor_id) REFERENCES dbo.staff (staff_id);

    PRINT '  four foreign keys repointed at staff(staff_id)';

    ---------------------------------------------------------------- 4. and it is gone
    DROP TABLE dbo.doctors;
    PRINT '  dbo.doctors dropped';
END
GO
