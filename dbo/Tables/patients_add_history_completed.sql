-- One-time patient milestone: has the detailed first-visit history been captured?
-- Gates the Visit/Follow-up module and the doctor-worklist "start" routing.
-- Idempotent.
IF COL_LENGTH('dbo.patients', 'history_completed') IS NULL
    ALTER TABLE dbo.patients ADD history_completed BIT NOT NULL
        CONSTRAINT DF_patients_history_completed DEFAULT (0);

IF COL_LENGTH('dbo.patients', 'history_completed_at') IS NULL
    ALTER TABLE dbo.patients ADD history_completed_at DATETIME2 NULL;
