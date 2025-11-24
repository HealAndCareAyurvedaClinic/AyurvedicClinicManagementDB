CREATE TABLE [dbo].[habbits] (
    [habbit_id]         INT            IDENTITY (1, 1) NOT NULL,
    [patient_id]        INT            NOT NULL,
    [habbit_type]       NVARCHAR (50)  NOT NULL,
    [other_habbit_type] NVARCHAR (100) NULL,
    [notes]             NVARCHAR (MAX) NULL,
    [created_at]        DATETIME2 (0)  DEFAULT (sysutcdatetime()) NOT NULL,
    [updated_at]        DATETIME2 (0)  DEFAULT (sysutcdatetime()) NOT NULL,
    [created_by]        INT            NULL,
    [updated_by]        INT            NULL,
    PRIMARY KEY CLUSTERED ([habbit_id] ASC),
    CHECK ([habbit_type]=N'Other' OR [habbit_type]=N'Rock' OR [habbit_type]=N'Soil' OR [habbit_type]=N'Nail Biting'),
    CONSTRAINT [FK_habbit_patient] FOREIGN KEY ([patient_id]) REFERENCES [dbo].[patients] ([patient_id])
);

