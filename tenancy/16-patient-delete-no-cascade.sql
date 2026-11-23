/*
    Deleting a patient must never destroy their clinical record.

    ---------------------------------------------------------------- the problem

    37 foreign keys reference dbo.patients. Thirty-one are NO ACTION, so a hard
    delete of any patient who has ever been seen is refused -- correctly. Bills,
    payments and encounters have to outlive the patient row for as long as the
    clinic is required to keep them.

    Six were ON DELETE CASCADE:

        FK_apt_patient  appointments
        FK_ep_patient   encounter_prescriptions
        FK_etp_patient  encounter_treatment_plan
        FK_fus_patient  follow_up_schedule
        FK_inv_patient  investigations
        FK_pkp_patient  panchkarma_procedures

    That mix is the dangerous part. For a patient whose thirty-one blocking tables
    happen to be empty -- registered, appointment booked, never consulted -- the
    delete was not refused. It succeeded, and took the appointment, any
    prescriptions, the treatment plan, the follow-up schedule, the investigations
    and the panchakarma procedures with it, silently and with no audit trail.
    DELETE /api/Patients/{id} was wired to the Delete button on the patient list,
    so any user could reach it.

    A patient is now removed by setting is_active = false (see
    PatientService.DeletePatientAsync), which never deletes a row. This migration
    closes the same hole in the database, so that a hand-run DELETE, a future
    endpoint or anything else cannot reopen it.

    ---------------------------------------------------------------- what this does

    Drops each of the six and recreates it identically except for the delete rule,
    which becomes NO ACTION. Nothing else about the constraint changes: same name,
    same columns, same target.

    WITH NOCHECK on the recreate, deliberately. These are existing, already-valid
    relationships -- the rows satisfied the same constraint a moment ago, under the
    same columns. Re-validating 37 tables' worth of data would take a long table
    lock on a live database to prove something that cannot have changed in between.
    The constraint is then marked not-trusted, which affects only the optimiser's
    freedom to skip joins, not correctness.

    Idempotent: a constraint already set to NO ACTION is left exactly as it is, so
    re-running does nothing and drops nothing.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

DECLARE @fixes TABLE (
    fk_name     sysname,
    child_table sysname,
    child_col   sysname
);

INSERT INTO @fixes (fk_name, child_table, child_col)
VALUES ('FK_apt_patient', 'appointments',             'patient_id'),
       ('FK_ep_patient',  'encounter_prescriptions',  'patient_id'),
       ('FK_etp_patient', 'encounter_treatment_plan', 'patient_id'),
       ('FK_fus_patient', 'follow_up_schedule',       'patient_id'),
       ('FK_inv_patient', 'investigations',           'patient_id'),
       ('FK_pkp_patient', 'panchkarma_procedures',    'patient_id');

DECLARE @fk sysname, @child sysname, @col sysname, @sql nvarchar(max), @changed INT = 0;

DECLARE fix_cursor CURSOR LOCAL FAST_FORWARD FOR
    SELECT fk_name, child_table, child_col FROM @fixes;

OPEN fix_cursor;
FETCH NEXT FROM fix_cursor INTO @fk, @child, @col;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Only act on one that still cascades. delete_referential_action: 0 = NO ACTION,
    -- 1 = CASCADE. A constraint already at 0 is left untouched, which is what makes
    -- this safe to re-run.
    IF EXISTS (SELECT 1
                 FROM sys.foreign_keys
                WHERE name = @fk
                  AND referenced_object_id = OBJECT_ID('dbo.patients')
                  AND delete_referential_action = 1)
    BEGIN
        SET @sql = 'ALTER TABLE dbo.' + QUOTENAME(@child)
                 + ' DROP CONSTRAINT ' + QUOTENAME(@fk) + ';';
        EXEC sp_executesql @sql;

        SET @sql = 'ALTER TABLE dbo.' + QUOTENAME(@child)
                 + ' WITH NOCHECK ADD CONSTRAINT ' + QUOTENAME(@fk)
                 + ' FOREIGN KEY (' + QUOTENAME(@col) + ')'
                 + ' REFERENCES dbo.patients (patient_id);';
        EXEC sp_executesql @sql;

        PRINT '  ' + @child + '.' + @fk + ': ON DELETE CASCADE -> NO ACTION';
        SET @changed = @changed + 1;
    END
    ELSE IF EXISTS (SELECT 1 FROM sys.foreign_keys
                     WHERE name = @fk AND referenced_object_id = OBJECT_ID('dbo.patients'))
        PRINT '  ' + @child + '.' + @fk + ': already NO ACTION';
    ELSE
        PRINT '  ' + @child + '.' + @fk + ': not present, skipped';

    FETCH NEXT FROM fix_cursor INTO @fk, @child, @col;
END

CLOSE fix_cursor;
DEALLOCATE fix_cursor;

PRINT '  cascade rules removed: ' + CAST(@changed AS VARCHAR);
GO

---------------------------------------------------------------- prove it
-- Refuse rather than report success if any path from patients still cascades. A
-- single one left behind would mean a delete can still destroy clinical rows, and
-- that is the whole point of this migration.
DECLARE @cascading INT = (
    SELECT COUNT(*)
      FROM sys.foreign_keys
     WHERE referenced_object_id = OBJECT_ID('dbo.patients')
       AND delete_referential_action = 1
);

IF @cascading > 0
BEGIN
    DECLARE @msg nvarchar(400) =
        CAST(@cascading AS nvarchar(10))
        + ' foreign key(s) referencing dbo.patients still cascade on delete.';
    THROW 51016, @msg, 1;
END

PRINT '  verified: no foreign key referencing dbo.patients cascades on delete';
GO
