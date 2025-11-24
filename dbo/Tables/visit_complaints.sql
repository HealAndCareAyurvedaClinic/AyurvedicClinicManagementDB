CREATE TABLE [dbo].[visit_complaints] (
    [complaint_id]          INT            IDENTITY (1, 1) NOT NULL,
    [encounter_id]          INT            NOT NULL,
    [patient_id]            INT            NOT NULL,
    [symptoms_text]         NVARCHAR (MAX) NOT NULL,
    [complaint_text]        NVARCHAR (MAX) NOT NULL,
    [duration]              NVARCHAR (100) NULL,
    [physical_feelings]     NVARCHAR (100) NULL,
    [non_physical_feelings] NVARCHAR (100) NULL,
    [severity]              NVARCHAR (10)  NULL,
    [chronicity]            NVARCHAR (10)  NULL,
    [aggravating_factors]   NVARCHAR (MAX) NULL,
    [relieving_factors]     NVARCHAR (MAX) NULL,
    [additional_notes]      NVARCHAR (MAX) NULL,
    [recorded_at]           DATETIME2 (0)  DEFAULT (sysutcdatetime()) NOT NULL,
    [created_at]            DATETIME2 (0)  DEFAULT (sysutcdatetime()) NOT NULL,
    [updated_at]            DATETIME2 (0)  DEFAULT (sysutcdatetime()) NOT NULL,
    [created_by]            INT            NULL,
    [updated_by]            INT            NULL,
    PRIMARY KEY CLUSTERED ([complaint_id] ASC),
    CHECK ([chronicity]=N'Subacute' OR [chronicity]=N'Chronic' OR [chronicity]=N'Acute'),
    CHECK ([severity]=N'Severe' OR [severity]=N'Moderate' OR [severity]=N'Mild'),
    CONSTRAINT [FK_complaints_encounter] FOREIGN KEY ([encounter_id]) REFERENCES [dbo].[patient_encounters] ([encounter_id]),
    CONSTRAINT [FK_complaints_patient] FOREIGN KEY ([patient_id]) REFERENCES [dbo].[patients] ([patient_id])
);


GO
CREATE NONCLUSTERED INDEX [IX_visit_complaints_encounter]
    ON [dbo].[visit_complaints]([encounter_id] ASC);

