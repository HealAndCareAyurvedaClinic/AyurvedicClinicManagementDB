CREATE TABLE [dbo].[visit_vitals] (
    [vital_id]                 INT            IDENTITY (1, 1) NOT NULL,
    [encounter_id]             INT            NOT NULL,
    [patient_id]               INT            NOT NULL,
    [height]                   DECIMAL (5, 2) NULL,
    [weight]                   DECIMAL (5, 2) NULL,
    [bmi]                      DECIMAL (4, 2) NULL,
    [temperature]              DECIMAL (4, 2) NULL,
    [pulse_rate]               INT            NULL,
    [blood_pressure_systolic]  INT            NULL,
    [blood_pressure_diastolic] INT            NULL,
    [respiratory_rate]         INT            NULL,
    [oxygen_saturation]        DECIMAL (5, 2) NULL,
    [recorded_at]              DATETIME2 (0)  DEFAULT (sysutcdatetime()) NOT NULL,
    [created_at]               DATETIME2 (0)  DEFAULT (sysutcdatetime()) NOT NULL,
    [updated_at]               DATETIME2 (0)  DEFAULT (sysutcdatetime()) NOT NULL,
    [created_by]               INT            NULL,
    [updated_by]               INT            NULL,
    PRIMARY KEY CLUSTERED ([vital_id] ASC),
    CONSTRAINT [FK_vitals_encounter] FOREIGN KEY ([encounter_id]) REFERENCES [dbo].[patient_encounters] ([encounter_id]),
    CONSTRAINT [FK_vitals_patient] FOREIGN KEY ([patient_id]) REFERENCES [dbo].[patients] ([patient_id])
);


GO
CREATE NONCLUSTERED INDEX [IX_visit_vitals_encounter]
    ON [dbo].[visit_vitals]([encounter_id] ASC);

