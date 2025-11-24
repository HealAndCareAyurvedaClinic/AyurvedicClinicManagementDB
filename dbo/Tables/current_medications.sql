CREATE TABLE [dbo].[current_medications] (
    [medication_id]      INT            IDENTITY (1, 1) NOT NULL,
    [patient_id]         INT            NOT NULL,
    [medicine_name]      NVARCHAR (255) NOT NULL,
    [medicine_type]      NVARCHAR (20)  NULL,
    [dosage]             NVARCHAR (100) NULL,
    [frequency]          NVARCHAR (100) NULL,
    [duration]           NVARCHAR (100) NULL,
    [prescribing_doctor] NVARCHAR (255) NULL,
    [start_date]         DATE           NULL,
    [end_date]           DATE           NULL,
    [is_active]          BIT            DEFAULT ((1)) NOT NULL,
    [notes]              NVARCHAR (MAX) NULL,
    [created_at]         DATETIME2 (0)  DEFAULT (sysutcdatetime()) NOT NULL,
    [updated_at]         DATETIME2 (0)  DEFAULT (sysutcdatetime()) NOT NULL,
    [created_by]         INT            NULL,
    [updated_by]         INT            NULL,
    PRIMARY KEY CLUSTERED ([medication_id] ASC),
    CHECK ([medicine_type]=N'Other' OR [medicine_type]=N'Homeopathic' OR [medicine_type]=N'Allopathic' OR [medicine_type]=N'Ayurvedic'),
    CONSTRAINT [FK_medication_patient] FOREIGN KEY ([patient_id]) REFERENCES [dbo].[patients] ([patient_id])
);

