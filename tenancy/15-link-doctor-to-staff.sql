/*
    A doctor is a member of staff, and now says so.

    ---------------------------------------------------------------- the problem

    A doctor is a row in dbo.doctors and, if anybody also put them on the roster, a
    second row in dbo.staff with staff_type 'Doctor'. Nothing joins the two, so a doctor
    added to the roster never appears in the doctors list and cannot be booked --
    appointments point at dbo.doctors and the roster is somewhere else entirely.

    Of the eleven columns in dbo.doctors, ten duplicate dbo.staff: doctor_name,
    qualification, specialization, registration_number, phone, email, is_active,
    created_at, tenant_id. Exactly one is its own: consultation_fee.

    ---------------------------------------------------------------- why not merge them

    Merging the tables is the cleaner destination and was tried: it requires repointing
    four foreign keys from doctors(doctor_id) to staff(staff_id), and because those are
    different numbers for the same person, every referencing row has to be remapped in
    the same breath. On a database with appointments that is a careful, one-off piece of
    work, and getting the deployment order wrong takes the API down -- which is what
    happened.

    This does the same job additively instead. dbo.doctors gains a link to the staff
    member it describes. appointments.doctor_id is never touched, no foreign key moves,
    and every step is safe to deploy in any order. The roster becomes the source of
    truth: the API creates the doctors row when a doctor joins the staff, and keeps the
    duplicated columns in step from there.

    ---------------------------------------------------------------- what this does

      1. dbo.doctors gains a nullable staff_id, a foreign key to dbo.staff, and a
         unique index so one staff member cannot have two doctor records.
      2. Existing rows are matched to staff by name within the same clinic and linked.

    It does NOT refuse on an unmatched doctor. A doctor with nobody of that name on the
    roster keeps staff_id NULL and goes on working exactly as before -- the link is an
    improvement where it can be made, not a preconditon for the table to function.
    Ambiguous matches -- two doctors of one name, or two staff of one name, in the same
    clinic -- are left NULL too, because guessing which is which would attach
    appointments to the wrong person.

    Idempotent: re-running adds nothing and relinks nothing that is already linked.

    ---------------------------------------------------------------- one trap

    UQ_doctors_staff_id is a FILTERED index, which SQL Server only permits a session to
    write through when SET QUOTED_IDENTIFIER is ON. EF Core and SqlClient connect with it
    ON, so the API is unaffected. A hand-run script is not: `sqlcmd -Q "UPDATE dbo.doctors
    ..."` defaults it OFF and fails with error 1934 complaining about SET options, which
    reads like a problem with the statement rather than the connection. Any script that
    writes to dbo.doctors needs SET QUOTED_IDENTIFIER ON, as this one has above.

    A filtered index is still the right tool: a plain unique index treats NULLs as equal,
    so the many not-yet-linked rows would collide with each other.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;
SET QUOTED_IDENTIFIER ON;
GO

---------------------------------------------------------------- 1. the column
IF COL_LENGTH('dbo.doctors', 'staff_id') IS NULL
BEGIN
    ALTER TABLE dbo.doctors ADD staff_id INT NULL;
    PRINT '  doctors.staff_id added';
END
ELSE
    PRINT '  doctors.staff_id already present';
GO

-- Separate batch: the column has to exist before anything can reference it.
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_doctors_staff')
BEGIN
    ALTER TABLE dbo.doctors WITH CHECK
        ADD CONSTRAINT FK_doctors_staff FOREIGN KEY (staff_id) REFERENCES dbo.staff (staff_id);
    PRINT '  FK_doctors_staff added';
END

-- Filtered, so the many rows that are not linked yet do not collide on NULL.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UQ_doctors_staff_id' AND object_id = OBJECT_ID('dbo.doctors'))
BEGIN
    CREATE UNIQUE INDEX UQ_doctors_staff_id
        ON dbo.doctors (staff_id) WHERE staff_id IS NOT NULL;
    PRINT '  UQ_doctors_staff_id added (one doctor record per staff member)';
END
GO

---------------------------------------------------------------- 2. link what we can
-- Only where the pairing is unambiguous in BOTH directions: one doctor of that name in
-- the clinic, and one staff member of that name. Anything else stays NULL for a person
-- to resolve, because attaching appointments to the wrong doctor is worse than a gap.
;WITH one_doctor AS (
    SELECT tenant_id, doctor_name
      FROM dbo.doctors
     WHERE staff_id IS NULL
     GROUP BY tenant_id, doctor_name
    HAVING COUNT(*) = 1
), one_staff AS (
    SELECT tenant_id, staff_name
      FROM dbo.staff
     GROUP BY tenant_id, staff_name
    HAVING COUNT(*) = 1
)
UPDATE d
   SET d.staff_id = s.staff_id
  FROM dbo.doctors d
  JOIN one_doctor od ON od.tenant_id = d.tenant_id AND od.doctor_name = d.doctor_name
  JOIN dbo.staff s   ON s.tenant_id  = d.tenant_id AND s.staff_name  = d.doctor_name
  JOIN one_staff os  ON os.tenant_id = s.tenant_id AND os.staff_name = s.staff_name
 WHERE d.staff_id IS NULL
   -- Not already claimed by another doctor record.
   AND NOT EXISTS (SELECT 1 FROM dbo.doctors x WHERE x.staff_id = s.staff_id);

PRINT '  doctors linked to a staff member: ' + CAST(@@ROWCOUNT AS VARCHAR);

DECLARE @unlinked INT = (SELECT COUNT(*) FROM dbo.doctors WHERE staff_id IS NULL);
IF @unlinked > 0
    PRINT '  still unlinked (no unambiguous staff member of that name): ' + CAST(@unlinked AS VARCHAR);
GO
