CREATE TABLE [dbo].[nadi_pariksha] (
    [nadi_id]                INT            IDENTITY (1, 1) NOT NULL,
    [patient_id]             INT            NOT NULL,
    [encounter_id]           INT            NOT NULL,
    [right_hand_superficial] NVARCHAR (100) NULL,
    [right_hand_middle]      NVARCHAR (100) NULL,
    [right_hand_deep]        NVARCHAR (100) NULL,
    [left_hand_superficial]  NVARCHAR (100) NULL,
    [left_hand_middle]       NVARCHAR (100) NULL,
    [left_hand_deep]         NVARCHAR (100) NULL,
    [vata_characteristics]   NVARCHAR (MAX) NULL,
    [pitta_characteristics]  NVARCHAR (MAX) NULL,
    [kapha_characteristics]  NVARCHAR (MAX) NULL,
    [gati]                   NVARCHAR (100) NULL,
    [vega]                   NVARCHAR (100) NULL,
    [bala]                   NVARCHAR (100) NULL,
    [created_at]             DATETIME2 (0)  DEFAULT (sysutcdatetime()) NOT NULL,
    [updated_at]             DATETIME2 (0)  DEFAULT (sysutcdatetime()) NOT NULL,
    [created_by]             INT            NULL,
    [updated_by]             INT            NULL,
    PRIMARY KEY CLUSTERED ([nadi_id] ASC),
    CONSTRAINT [FK_nadi_encounter] FOREIGN KEY ([encounter_id]) REFERENCES [dbo].[patient_encounters] ([encounter_id]),
    CONSTRAINT [FK_nadi_patient] FOREIGN KEY ([patient_id]) REFERENCES [dbo].[patients] ([patient_id])
);


GO
CREATE NONCLUSTERED INDEX [IX_nadi_pariksha_encounter]
    ON [dbo].[nadi_pariksha]([encounter_id] ASC);

