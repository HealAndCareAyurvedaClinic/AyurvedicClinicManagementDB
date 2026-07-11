-- Allergies: patient-scoped satellite table (mirrors past_medical_history conventions).
-- The DB schema is managed outside the repo (db-first, no EF migrations); this script
-- is the source of record for the allergies table. Idempotent.
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'allergies' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.allergies (
        allergy_id   INT IDENTITY(1,1) NOT NULL,
        patient_id   INT              NOT NULL,
        allergy_name NVARCHAR(255)    NOT NULL,
        allergy_type NVARCHAR(100)    NULL,
        reaction     NVARCHAR(500)    NULL,
        severity     NVARCHAR(50)     NULL,
        onset_date   DATE             NULL,
        notes        NVARCHAR(MAX)    NULL,
        is_active    BIT              NOT NULL CONSTRAINT DF_allergies_is_active DEFAULT (1),
        created_at   DATETIME2        NOT NULL CONSTRAINT DF_allergies_created_at DEFAULT (SYSUTCDATETIME()),
        updated_at   DATETIME2        NOT NULL CONSTRAINT DF_allergies_updated_at DEFAULT (SYSUTCDATETIME()),
        created_by   INT              NULL,
        updated_by   INT              NULL,
        CONSTRAINT PK_allergies PRIMARY KEY (allergy_id),
        CONSTRAINT FK_allergies_patients FOREIGN KEY (patient_id) REFERENCES dbo.patients (patient_id)
    );

    CREATE INDEX IX_allergies_patient_id ON dbo.allergies (patient_id);
END
