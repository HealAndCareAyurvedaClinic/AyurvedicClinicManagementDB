CREATE TABLE [dbo].[addictions] (
    [addiction_id]             INT            IDENTITY (1, 1) NOT NULL,
    [patient_id]               INT            NOT NULL,
    [addiction_type]           NVARCHAR (50)  NOT NULL,
    [other_addiction_type]     NVARCHAR (100) NULL,
    [frequency]                NVARCHAR (100) NULL,
    [quantity_per_day]         NVARCHAR (50)  NULL,
    [addiction_duration_years] INT            NULL,
    [start_age]                INT            NULL,
    [notes]                    NVARCHAR (MAX) NULL,
    [created_at]               DATETIME2 (0)  DEFAULT (sysutcdatetime()) NOT NULL,
    [updated_at]               DATETIME2 (0)  DEFAULT (sysutcdatetime()) NOT NULL,
    [created_by]               INT            NULL,
    [updated_by]               INT            NULL,
    PRIMARY KEY CLUSTERED ([addiction_id] ASC),
    CHECK ([addiction_type]=N'Other' OR [addiction_type]=N'Tobacco_in_teeth' OR [addiction_type]=N'Drugs' OR [addiction_type]=N'Alcohol' OR [addiction_type]=N'Gutkha' OR [addiction_type]=N'Pan_masala' OR [addiction_type]=N'Cigarette' OR [addiction_type]=N'Bidi' OR [addiction_type]=N'Tobacco' OR [addiction_type]=N'Pan' OR [addiction_type]=N'Supari'),
    CONSTRAINT [FK_addiction_patient] FOREIGN KEY ([patient_id]) REFERENCES [dbo].[patients] ([patient_id])
);

