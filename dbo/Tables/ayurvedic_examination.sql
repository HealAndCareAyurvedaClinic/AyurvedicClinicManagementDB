CREATE TABLE [dbo].[ayurvedic_examination] (
    [exam_id]                 INT            IDENTITY (1, 1) NOT NULL,
    [patient_id]              INT            NOT NULL,
    [encounter_id]            INT            NOT NULL,
    [prakriti]                NVARCHAR (100) NULL,
    [vikriti]                 NVARCHAR (100) NULL,
    [sara]                    NVARCHAR (100) NULL,
    [samhanana]               NVARCHAR (100) NULL,
    [pramana]                 NVARCHAR (100) NULL,
    [satmya]                  NVARCHAR (MAX) NULL,
    [satva]                   NVARCHAR (100) NULL,
    [aharashakti_jarana]      NVARCHAR (100) NULL,
    [aharashakti_abhyavarana] NVARCHAR (100) NULL,
    [vyayamashakti]           NVARCHAR (100) NULL,
    [vaya]                    NVARCHAR (50)  NULL,
    [desha]                   NVARCHAR (100) NULL,
    [kala]                    NVARCHAR (100) NULL,
    [recorded_at]             DATETIME2 (0)  DEFAULT (sysutcdatetime()) NOT NULL,
    PRIMARY KEY CLUSTERED ([exam_id] ASC),
    CONSTRAINT [FK_ayur_exam_encounter] FOREIGN KEY ([encounter_id]) REFERENCES [dbo].[patient_encounters] ([encounter_id]),
    CONSTRAINT [FK_ayur_exam_patient] FOREIGN KEY ([patient_id]) REFERENCES [dbo].[patients] ([patient_id])
);


GO
CREATE NONCLUSTERED INDEX [IX_ayurvedic_examination_encounter]
    ON [dbo].[ayurvedic_examination]([encounter_id] ASC);

