-- Align patients.marital_status CHECK constraint with the API DTO regex, which
-- accepts 'Single' (^(Married|Unmarried|Single|Divorced|Widowed)$). The original DB
-- CHECK only allowed Married|Unmarried|Divorced|Widowed, so a UI value of 'Single'
-- passed API validation but failed at INSERT with SQL error 547.
-- Idempotent: drops the old (auto-named) constraint if present, adds a cleanly-named one.
IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK__patients__marita__4CA06362' AND parent_object_id = OBJECT_ID('dbo.patients'))
    ALTER TABLE dbo.patients DROP CONSTRAINT CK__patients__marita__4CA06362;

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_patients_marital_status' AND parent_object_id = OBJECT_ID('dbo.patients'))
    ALTER TABLE dbo.patients WITH CHECK ADD CONSTRAINT CK_patients_marital_status
        CHECK (marital_status IN (N'Married', N'Unmarried', N'Single', N'Divorced', N'Widowed'));
