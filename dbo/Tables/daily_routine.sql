CREATE TABLE [dbo].[daily_routine] (
    [routine_id]            INT            IDENTITY (1, 1) NOT NULL,
    [patient_id]            INT            NOT NULL,
    [encounter_id]          INT            NOT NULL,
    [wake_up_time]          TIME (7)       NULL,
    [morning_beverage]      NVARCHAR (100) NULL,
    [morning_beverage_cups] INT            NULL,
    [cup_enthusiasm]        NVARCHAR (3)   NULL,
    [exercise]              NVARCHAR (3)   NULL,
    [exercise_type]         NVARCHAR (100) NULL,
    [exercise_duration]     NVARCHAR (50)  NULL,
    [bath_time]             NVARCHAR (50)  NULL,
    [bath_water_temp]       NVARCHAR (10)  NULL,
    [head_bath_frequency]   NVARCHAR (100) NULL,
    [additional_notes]      NVARCHAR (MAX) NULL,
    [created_at]            DATETIME2 (0)  DEFAULT (sysutcdatetime()) NOT NULL,
    [updated_at]            DATETIME2 (0)  DEFAULT (sysutcdatetime()) NOT NULL,
    [created_by]            INT            NULL,
    [updated_by]            INT            NULL,
    PRIMARY KEY CLUSTERED ([routine_id] ASC),
    CHECK ([bath_water_temp]=N'Warm' OR [bath_water_temp]=N'Cold' OR [bath_water_temp]=N'Hot'),
    CHECK ([cup_enthusiasm]=N'No' OR [cup_enthusiasm]=N'Yes'),
    CHECK ([exercise]=N'No' OR [exercise]=N'Yes'),
    CONSTRAINT [FK_routine_encounter] FOREIGN KEY ([encounter_id]) REFERENCES [dbo].[patient_encounters] ([encounter_id]),
    CONSTRAINT [FK_routine_patient] FOREIGN KEY ([patient_id]) REFERENCES [dbo].[patients] ([patient_id])
);


GO
CREATE NONCLUSTERED INDEX [IX_daily_routine_encounter]
    ON [dbo].[daily_routine]([encounter_id] ASC);

