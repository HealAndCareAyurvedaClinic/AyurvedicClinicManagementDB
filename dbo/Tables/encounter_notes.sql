CREATE TABLE [dbo].[encounter_notes] (
    [note_id]      INT            IDENTITY (1, 1) NOT NULL,
    [encounter_id] INT            NOT NULL,
    [patient_id]   INT            NOT NULL,
    [note_type]    NVARCHAR (50)  NULL,
    [note_text]    NVARCHAR (MAX) NOT NULL,
    [created_by]   INT            NULL,
    [created_at]   DATETIME2 (0)  DEFAULT (sysutcdatetime()) NOT NULL,
    PRIMARY KEY CLUSTERED ([note_id] ASC),
    CHECK ([note_type]=N'Therapist_notes' OR [note_type]=N'Dietitian_notes' OR [note_type]=N'Doctor_observations' OR [note_type]=N'Progress_notes' OR [note_type]=N'Follow_up_notes' OR [note_type]=N'Clinical_notes'),
    CONSTRAINT [FK_notes_encounter] FOREIGN KEY ([encounter_id]) REFERENCES [dbo].[patient_encounters] ([encounter_id]),
    CONSTRAINT [FK_notes_patient] FOREIGN KEY ([patient_id]) REFERENCES [dbo].[patients] ([patient_id])
);


GO
CREATE NONCLUSTERED INDEX [IX_encounter_notes_encounter]
    ON [dbo].[encounter_notes]([encounter_id] ASC);

