CREATE TABLE [dbo].[past_medical_history] (
    [history_id]         INT            IDENTITY (1, 1) NOT NULL,
    [patient_id]         INT            NOT NULL,
    [disease_name]       NVARCHAR (50)  NULL,
    [other_disease_name] NVARCHAR (50)  NULL,
    [diagnosis_date]     DATE           NULL,
    [treatment_received] NVARCHAR (MAX) NULL,
    [duration]           NVARCHAR (100) NULL,
    [current_status]     NVARCHAR (20)  NULL,
    [notes]              NVARCHAR (MAX) NULL,
    [created_at]         DATETIME2 (0)  DEFAULT (sysutcdatetime()) NOT NULL,
    [updated_at]         DATETIME2 (0)  DEFAULT (sysutcdatetime()) NOT NULL,
    [created_by]         INT            NULL,
    [updated_by]         INT            NULL,
    PRIMARY KEY CLUSTERED ([history_id] ASC),
    CHECK ([current_status]=N'Recurrent' OR [current_status]=N'Ongoing' OR [current_status]=N'Cured'),
    CHECK ([disease_name]=N'Other' OR [disease_name]=N'Maleria' OR [disease_name]=N'Devi' OR [disease_name]=N'Kanjinya' OR [disease_name]=N'Gowar'),
    CONSTRAINT [FK_past_medical_patient] FOREIGN KEY ([patient_id]) REFERENCES [dbo].[patients] ([patient_id])
);

