CREATE TABLE [dbo].[sensory_details] (
    [sensory_id]          INT            IDENTITY (1, 1) NOT NULL,
    [patient_id]          INT            NOT NULL,
    [encounter_id]        INT            NOT NULL,
    [tv_watching_hours]   DECIMAL (4, 2) NULL,
    [computer_work_hours] DECIMAL (4, 2) NULL,
    [mobile_usage_hours]  DECIMAL (4, 2) NULL,
    [reading_hours]       DECIMAL (4, 2) NULL,
    [eye_strain]          NVARCHAR (3)   NULL,
    [headache_frequency]  NVARCHAR (50)  NULL,
    [created_at]          DATETIME2 (0)  DEFAULT (sysutcdatetime()) NOT NULL,
    [updated_at]          DATETIME2 (0)  DEFAULT (sysutcdatetime()) NOT NULL,
    [created_by]          INT            NULL,
    [updated_by]          INT            NULL,
    PRIMARY KEY CLUSTERED ([sensory_id] ASC),
    CHECK ([eye_strain]=N'No' OR [eye_strain]=N'Yes'),
    CONSTRAINT [FK_sensory_encounter] FOREIGN KEY ([encounter_id]) REFERENCES [dbo].[patient_encounters] ([encounter_id]),
    CONSTRAINT [FK_sensory_patient] FOREIGN KEY ([patient_id]) REFERENCES [dbo].[patients] ([patient_id])
);


GO
CREATE NONCLUSTERED INDEX [IX_sensory_details_encounter]
    ON [dbo].[sensory_details]([encounter_id] ASC);

