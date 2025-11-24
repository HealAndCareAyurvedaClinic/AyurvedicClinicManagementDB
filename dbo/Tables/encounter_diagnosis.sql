CREATE TABLE [dbo].[encounter_diagnosis] (
    [diagnosis_id]        INT            IDENTITY (1, 1) NOT NULL,
    [encounter_id]        INT            NOT NULL,
    [patient_id]          INT            NOT NULL,
    [roga_name]           NVARCHAR (255) NOT NULL,
    [ayurvedic_diagnosis] NVARCHAR (MAX) NULL,
    [modern_diagnosis]    NVARCHAR (MAX) NULL,
    [diagnosis_type]      NVARCHAR (30)  NULL,
    [dosha_involved]      NVARCHAR (100) NULL,
    [dushya]              NVARCHAR (100) NULL,
    [srotas]              NVARCHAR (100) NULL,
    [avastha]             NVARCHAR (100) NULL,
    [notes]               NVARCHAR (MAX) NULL,
    [diagnosis_date]      DATE           NULL,
    PRIMARY KEY CLUSTERED ([diagnosis_id] ASC),
    CHECK ([diagnosis_type]=N'Final' OR [diagnosis_type]=N'Provisional' OR [diagnosis_type]=N'Differential' OR [diagnosis_type]=N'Secondary' OR [diagnosis_type]=N'Primary'),
    CONSTRAINT [FK_diagnosis_encounter] FOREIGN KEY ([encounter_id]) REFERENCES [dbo].[patient_encounters] ([encounter_id]),
    CONSTRAINT [FK_diagnosis_patient] FOREIGN KEY ([patient_id]) REFERENCES [dbo].[patients] ([patient_id])
);


GO
CREATE NONCLUSTERED INDEX [IX_encounter_diagnosis_encounter]
    ON [dbo].[encounter_diagnosis]([encounter_id] ASC);

