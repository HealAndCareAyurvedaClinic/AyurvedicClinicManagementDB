CREATE TABLE [dbo].[family_medical_history] (
    [family_history_id]  INT            IDENTITY (1, 1) NOT NULL,
    [patient_id]         INT            NOT NULL,
    [disease_type]       NVARCHAR (50)  NULL,
    [other_disease_type] NVARCHAR (50)  NULL,
    [affected_relation]  NVARCHAR (100) NULL,
    [notes]              NVARCHAR (MAX) NULL,
    [swakul]             NVARCHAR (100) NULL,
    [pitrukul]           NVARCHAR (100) NULL,
    [matrukul]           NVARCHAR (100) NULL,
    [created_at]         DATETIME2 (0)  DEFAULT (sysutcdatetime()) NOT NULL,
    [updated_at]         DATETIME2 (0)  DEFAULT (sysutcdatetime()) NOT NULL,
    [created_by]         INT            NULL,
    [updated_by]         INT            NULL,
    PRIMARY KEY CLUSTERED ([family_history_id] ASC),
    CHECK ([disease_type]=N'other' OR [disease_type]=N'Asthama' OR [disease_type]=N'Diabetes' OR [disease_type]=N'CANCER'),
    CONSTRAINT [FK_family_medical_patient] FOREIGN KEY ([patient_id]) REFERENCES [dbo].[patients] ([patient_id])
);

