CREATE TABLE [dbo].[patient_encounters] (
    [encounter_id]       INT            IDENTITY (1, 1) NOT NULL,
    [patient_id]         INT            NOT NULL,
    [encounter_sequence] NVARCHAR (50)  NOT NULL,
    [encounter_date]     DATETIME2 (0)  NOT NULL,
    [encounter_type]     NVARCHAR (30)  NOT NULL,
    [visit_reason]       NVARCHAR (MAX) NULL,
    [chief_complaint]    NVARCHAR (MAX) NOT NULL,
    [encounter_status]   NVARCHAR (20)  DEFAULT (N'Scheduled') NOT NULL,
    [staff_id]           INT            NULL,
    [referring_doctor]   NVARCHAR (255) NULL,
    [department]         NVARCHAR (100) NULL,
    [created_at]         DATETIME2 (0)  DEFAULT (sysutcdatetime()) NOT NULL,
    [updated_at]         DATETIME2 (0)  DEFAULT (sysutcdatetime()) NOT NULL,
    [created_by]         INT            NULL,
    [updated_by]         INT            NULL,
    PRIMARY KEY CLUSTERED ([encounter_id] ASC),
    CHECK ([encounter_status]=N'No_show' OR [encounter_status]=N'Cancelled' OR [encounter_status]=N'Completed' OR [encounter_status]=N'In_progress' OR [encounter_status]=N'Scheduled'),
    CHECK ([encounter_type]=N'Panchkarma_session' OR [encounter_type]=N'Consultation' OR [encounter_type]=N'Emergency' OR [encounter_type]=N'Follow_up' OR [encounter_type]=N'New_patient'),
    CONSTRAINT [FK_encounter_patient] FOREIGN KEY ([patient_id]) REFERENCES [dbo].[patients] ([patient_id]),
    CONSTRAINT [FK_encounter_staff] FOREIGN KEY ([staff_id]) REFERENCES [dbo].[staff] ([staff_id]) ON DELETE SET NULL,
    UNIQUE NONCLUSTERED ([encounter_sequence] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_encounters_patient]
    ON [dbo].[patient_encounters]([patient_id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_encounters_date]
    ON [dbo].[patient_encounters]([encounter_date] ASC);

