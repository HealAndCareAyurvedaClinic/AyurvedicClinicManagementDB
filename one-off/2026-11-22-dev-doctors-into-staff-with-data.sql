/*
    Fold dbo.doctors into dbo.staff on a database that ALREADY HAS APPOINTMENTS.

    Run by hand, once, against DEV. Not a migration, not in deploy/manifest.txt.

    ---------------------------------------------------------------- why this exists

    tenancy/15-doctors-into-staff.sql does this job, but refuses when appointments,
    slots, schedules or sessions hold any rows -- because doctor_id and staff_id are
    different numbers for the same person, and repointing a foreign key does not rewrite
    the values in the referencing column. Its own header says that case "needs a
    deliberate id remap written for that data, not this script". This is that remap.

    DEV reached this state because deploy/baseline-schema.sql was exported before
    migrations 14 and 15 existed, and Bootstrap-AzureDatabase.ps1 finishes with
    Apply-Database -Baseline, which records every manifest script as applied WITHOUT
    running it. So the ledger claims 15 ran, the schema never got it, and the API --
    deployed from code that expects the merged shape -- fails every query that touches
    staff with "Invalid column name 'consultation_fee'" (SQL error 207).

    ---------------------------------------------------------------- what it does

    The same four things as migration 15, plus the remap in the middle:

      1. staff gains consultation_fee.
      2. Each doctors row is matched to a staff row by name within the same tenant and
         the fee carried across.
      3. THE REMAP: every doctor_id in appointments, appointment_slots, doctor_schedule
         and panchkarma_sessions is rewritten to the matched staff_id. The four foreign
         keys are dropped first, because the new values are not valid doctor_ids.
      4. The keys are added back pointing at staff(staff_id), WITH CHECK, and
         dbo.doctors is dropped.

    Afterwards tenancy/15 finds no dbo.doctors and prints "already gone - nothing to
    do", so the ledger entry that already claims it ran becomes true.

    It refuses rather than guesses: a doctor with no staff member of the same name, or a
    referencing row pointing at a doctor that does not exist, stops the whole thing with
    nothing changed.

    Idempotent: if dbo.doctors is already gone it does nothing.
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
    DECLARE @unmatched INT =
        (SELECT COUNT(*) FROM dbo.doctors d
          WHERE NOT EXISTS (SELECT 1 FROM dbo.staff s
                             WHERE s.staff_name = d.doctor_name
                               AND s.tenant_id  = d.tenant_id));

    IF @unmatched > 0
        THROW 51001, 'Refusing to run: some doctors have no staff member of the same name in the same clinic. Add them to the roster first, or the fee and their identity would be lost.', 1;

    -- Two doctors of the same name in one clinic would make the match ambiguous and the
    -- remap arbitrary. Refuse rather than pick one.
    IF EXISTS (SELECT 1 FROM dbo.staff
                GROUP BY tenant_id, staff_name HAVING COUNT(*) > 1)
        THROW 51002, 'Refusing to run: two staff members share a name within one clinic, so matching doctors to staff by name is ambiguous.', 1;

    -- A referencing row pointing at a doctor_id with no doctors row cannot be remapped,
    -- and silently leaving it would point it at an unrelated staff member.
    IF EXISTS (
        SELECT 1 FROM (
            SELECT doctor_id FROM dbo.appointments        WHERE doctor_id IS NOT NULL
            UNION SELECT doctor_id FROM dbo.appointment_slots  WHERE doctor_id IS NOT NULL
            UNION SELECT doctor_id FROM dbo.doctor_schedule    WHERE doctor_id IS NOT NULL
            UNION SELECT doctor_id FROM dbo.panchkarma_sessions WHERE doctor_id IS NOT NULL
        ) r
        WHERE NOT EXISTS (SELECT 1 FROM dbo.doctors d WHERE d.doctor_id = r.doctor_id))
        THROW 51003, 'Refusing to run: a row references a doctor_id that has no row in dbo.doctors, so it cannot be remapped.', 1;

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
    BEGIN TRANSACTION;

    ---------------------------------------------------------------- 2. carry the fee over
    UPDATE s
       SET s.consultation_fee = d.consultation_fee
      FROM dbo.staff s
      JOIN dbo.doctors d
        ON d.doctor_name = s.staff_name
       AND d.tenant_id   = s.tenant_id
     WHERE d.consultation_fee IS NOT NULL;

    PRINT '  fees carried across: ' + CAST(@@ROWCOUNT AS VARCHAR);

    ---------------------------------------------------------------- 3. the remap
    -- The map is built once and held, because dbo.doctors is dropped below and the
    -- four updates must all use the same answer.
    DECLARE @map TABLE (doctor_id INT PRIMARY KEY, staff_id INT NOT NULL);
    INSERT INTO @map (doctor_id, staff_id)
    SELECT d.doctor_id, s.staff_id
      FROM dbo.doctors d
      JOIN dbo.staff s
        ON s.staff_name = d.doctor_name
       AND s.tenant_id  = d.tenant_id;

    -- PRINT takes an expression, not a subquery, so the count is read into a variable.
    DECLARE @matched INT = (SELECT COUNT(*) FROM @map);
    PRINT '  doctors matched to staff: ' + CAST(@matched AS VARCHAR);
    DECLARE @moved VARCHAR(MAX) = '';
    SELECT @moved = @moved + '    doctor ' + CAST(doctor_id AS VARCHAR)
                  + ' -> staff ' + CAST(staff_id AS VARCHAR) + CHAR(13) + CHAR(10)
      FROM @map ORDER BY doctor_id;
    PRINT @moved;

    -- The keys must go before the values change: a staff_id is not a valid doctor_id.
    IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_apt_doctor')
        ALTER TABLE dbo.appointments DROP CONSTRAINT FK_apt_doctor;
    IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_as_doctor')
        ALTER TABLE dbo.appointment_slots DROP CONSTRAINT FK_as_doctor;
    IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_ds_doctor')
        ALTER TABLE dbo.doctor_schedule DROP CONSTRAINT FK_ds_doctor;
    IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_panchkarma_sessions_doctor')
        ALTER TABLE dbo.panchkarma_sessions DROP CONSTRAINT FK_panchkarma_sessions_doctor;

    UPDATE a SET a.doctor_id = m.staff_id
      FROM dbo.appointments a JOIN @map m ON m.doctor_id = a.doctor_id;
    PRINT '  appointments remapped: ' + CAST(@@ROWCOUNT AS VARCHAR);

    UPDATE a SET a.doctor_id = m.staff_id
      FROM dbo.appointment_slots a JOIN @map m ON m.doctor_id = a.doctor_id;
    PRINT '  slots remapped: ' + CAST(@@ROWCOUNT AS VARCHAR);

    UPDATE a SET a.doctor_id = m.staff_id
      FROM dbo.doctor_schedule a JOIN @map m ON m.doctor_id = a.doctor_id;
    PRINT '  schedules remapped: ' + CAST(@@ROWCOUNT AS VARCHAR);

    UPDATE a SET a.doctor_id = m.staff_id
      FROM dbo.panchkarma_sessions a JOIN @map m ON m.doctor_id = a.doctor_id;
    PRINT '  sessions remapped: ' + CAST(@@ROWCOUNT AS VARCHAR);

    ---------------------------------------------------------------- 4. point them at staff
    -- WITH CHECK, so SQL Server validates every remapped row. If the remap were wrong
    -- these would fail and the transaction would roll back.
    ALTER TABLE dbo.appointments WITH CHECK
        ADD CONSTRAINT FK_apt_doctor FOREIGN KEY (doctor_id) REFERENCES dbo.staff (staff_id);
    ALTER TABLE dbo.appointment_slots WITH CHECK
        ADD CONSTRAINT FK_as_doctor FOREIGN KEY (doctor_id) REFERENCES dbo.staff (staff_id);
    ALTER TABLE dbo.doctor_schedule WITH CHECK
        ADD CONSTRAINT FK_ds_doctor FOREIGN KEY (doctor_id) REFERENCES dbo.staff (staff_id);
    ALTER TABLE dbo.panchkarma_sessions WITH CHECK
        ADD CONSTRAINT FK_panchkarma_sessions_doctor FOREIGN KEY (doctor_id) REFERENCES dbo.staff (staff_id);

    PRINT '  four foreign keys repointed at staff(staff_id)';

    DROP TABLE dbo.doctors;
    PRINT '  dbo.doctors dropped';

    COMMIT TRANSACTION;
    PRINT '  done - tenancy/15 will now find nothing to do, as its ledger entry claims';
END
GO
