/*
    A pharmacist is a member of staff.

    The product has a Pharmacist role, a pharmacy module, a dispensing counter and a
    stock ledger, and until now no way to record the person who runs any of it. The
    role existed in dbo.roles from the beginning; the staff table simply never allowed
    the matching type, so a pharmacist could be given a login and could not be put on
    the roster, assigned, or reported on.

    Three lists disagreed about what a member of staff can be:

        this constraint        Doctor, Assistant Doctor, Nurse, Therapist,
                               Receptionist, Admin
        the API's DTOs         the same, without Admin
        dbo.roles              the same, without Admin, plus Pharmacist

    This adds Pharmacist, which is the one every list agrees is a real job.

    Admin is deliberately left alone. It is allowed here and refused by the API, which
    means it cannot be created through the application and is effectively dead — but
    deciding whether an administrator is a member of staff is a product question, not
    a migration's, and dropping a value from a check constraint is the kind of change
    that wants a deliberate decision rather than a quiet tidy-up.

    Idempotent: the constraint is dropped if present and recreated, so re-running
    changes nothing. WITH CHECK, so existing rows are validated rather than trusted —
    none of them can fail, since this only widens what is permitted.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

IF EXISTS (SELECT 1 FROM sys.check_constraints
           WHERE name = 'CK_staff_staff_type'
             AND parent_object_id = OBJECT_ID('dbo.staff'))
BEGIN
    ALTER TABLE dbo.staff DROP CONSTRAINT CK_staff_staff_type;
    PRINT '  CK_staff_staff_type dropped';
END
GO

ALTER TABLE dbo.staff WITH CHECK ADD CONSTRAINT CK_staff_staff_type CHECK
(
    staff_type IN ('Doctor', 'Assistant Doctor', 'Nurse', 'Therapist',
                   'Receptionist', 'Pharmacist', 'Admin')
);
GO

ALTER TABLE dbo.staff CHECK CONSTRAINT CK_staff_staff_type;
GO

PRINT '  CK_staff_staff_type now allows Pharmacist';
GO
