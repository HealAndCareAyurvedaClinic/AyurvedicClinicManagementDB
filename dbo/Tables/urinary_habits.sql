CREATE TABLE [dbo].[urinary_habits] (
    [urine_id]          INT            IDENTITY (1, 1) NOT NULL,
    [patient_id]        INT            NOT NULL,
    [encounter_id]      INT            NOT NULL,
    [day_frequency]     INT            NULL,
    [night_frequency]   INT            NULL,
    [color]             NVARCHAR (50)  NULL,
    [odor]              NVARCHAR (50)  NULL,
    [clarity]           NVARCHAR (20)  NULL,
    [scalding]          NVARCHAR (3)   NULL,
    [burning_sensation] NVARCHAR (3)   NULL,
    [urgency]           NVARCHAR (3)   NULL,
    [hesitancy]         NVARCHAR (3)   NULL,
    [sediment]          NVARCHAR (3)   NULL,
    [other_complaints]  NVARCHAR (MAX) NULL,
    [created_at]        DATETIME2 (0)  DEFAULT (sysutcdatetime()) NOT NULL,
    [updated_at]        DATETIME2 (0)  DEFAULT (sysutcdatetime()) NOT NULL,
    [created_by]        INT            NULL,
    [updated_by]        INT            NULL,
    PRIMARY KEY CLUSTERED ([urine_id] ASC),
    CHECK ([burning_sensation]=N'No' OR [burning_sensation]=N'Yes'),
    CHECK ([clarity]=N'Turbid' OR [clarity]=N'Cloudy' OR [clarity]=N'Clear'),
    CHECK ([hesitancy]=N'No' OR [hesitancy]=N'Yes'),
    CHECK ([scalding]=N'No' OR [scalding]=N'Yes'),
    CHECK ([sediment]=N'No' OR [sediment]=N'Yes'),
    CHECK ([urgency]=N'No' OR [urgency]=N'Yes'),
    CONSTRAINT [FK_urine_encounter] FOREIGN KEY ([encounter_id]) REFERENCES [dbo].[patient_encounters] ([encounter_id]),
    CONSTRAINT [FK_urine_patient] FOREIGN KEY ([patient_id]) REFERENCES [dbo].[patients] ([patient_id])
);


GO
CREATE NONCLUSTERED INDEX [IX_urinary_habits_encounter]
    ON [dbo].[urinary_habits]([encounter_id] ASC);

