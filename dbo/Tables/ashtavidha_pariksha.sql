CREATE TABLE [dbo].[ashtavidha_pariksha] (
    [ashta_id]     INT            IDENTITY (1, 1) NOT NULL,
    [patient_id]   INT            NOT NULL,
    [encounter_id] INT            NOT NULL,
    [nadi]         NVARCHAR (100) NULL,
    [mutra]        NVARCHAR (100) NULL,
    [mala]         NVARCHAR (100) NULL,
    [jihva]        NVARCHAR (100) NULL,
    [shabda]       NVARCHAR (100) NULL,
    [sparsha]      NVARCHAR (100) NULL,
    [drik]         NVARCHAR (100) NULL,
    [akriti]       NVARCHAR (100) NULL,
    [recorded_at]  DATETIME2 (0)  DEFAULT (sysutcdatetime()) NOT NULL,
    PRIMARY KEY CLUSTERED ([ashta_id] ASC),
    CONSTRAINT [FK_ashta_encounter] FOREIGN KEY ([encounter_id]) REFERENCES [dbo].[patient_encounters] ([encounter_id]),
    CONSTRAINT [FK_ashta_patient] FOREIGN KEY ([patient_id]) REFERENCES [dbo].[patients] ([patient_id])
);


GO
CREATE NONCLUSTERED INDEX [IX_ashtavidha_pariksha_encounter]
    ON [dbo].[ashtavidha_pariksha]([encounter_id] ASC);

