CREATE TABLE [dbo].[sleep_patterns] (
    [sleep_id]               INT            IDENTITY (1, 1) NOT NULL,
    [patient_id]             INT            NOT NULL,
    [encounter_id]           INT            NOT NULL,
    [sleep_time]             NVARCHAR (10)  NOT NULL,
    [sleep_difficulty]       NVARCHAR (30)  NULL,
    [wake_up_time]           TIME (7)       NULL,
    [total_sleep_hours]      DECIMAL (3, 1) NULL,
    [sleep_again_after_wake] NVARCHAR (3)   NULL,
    [daytime_sleep]          NVARCHAR (3)   NULL,
    [daytime_sleep_duration] NVARCHAR (50)  NULL,
    [post_meal_drowsiness]   NVARCHAR (3)   NULL,
    [sleep_quality]          NVARCHAR (20)  NULL,
    [dreams]                 NVARCHAR (20)  NULL,
    [snoring]                NVARCHAR (3)   NULL,
    [sleep_disturbances]     NVARCHAR (MAX) NULL,
    [sleep_talking]          NVARCHAR (3)   NULL,
    [sleep_walking]          NVARCHAR (3)   NULL,
    [sleep_urinating]        NVARCHAR (3)   NULL,
    [created_at]             DATETIME2 (0)  DEFAULT (sysutcdatetime()) NOT NULL,
    [updated_at]             DATETIME2 (0)  DEFAULT (sysutcdatetime()) NOT NULL,
    [created_by]             INT            NULL,
    [updated_by]             INT            NULL,
    PRIMARY KEY CLUSTERED ([sleep_id] ASC),
    CHECK ([daytime_sleep]=N'No' OR [daytime_sleep]=N'Yes'),
    CHECK ([dreams]=N'None' OR [dreams]=N'Rare' OR [dreams]=N'Occasional' OR [dreams]=N'Frequent'),
    CHECK ([post_meal_drowsiness]=N'No' OR [post_meal_drowsiness]=N'Yes'),
    CHECK ([sleep_again_after_wake]=N'No' OR [sleep_again_after_wake]=N'Yes'),
    CHECK ([sleep_difficulty]=N'Occasionally' OR [sleep_difficulty]=N'Sometimes' OR [sleep_difficulty]=N'Never' OR [sleep_difficulty]=N'Always'),
    CHECK ([sleep_quality]=N'Poor' OR [sleep_quality]=N'Moderate' OR [sleep_quality]=N'Good'),
    CHECK ([sleep_talking]=N'No' OR [sleep_talking]=N'Yes'),
    CHECK ([sleep_urinating]=N'No' OR [sleep_urinating]=N'Yes'),
    CHECK ([sleep_walking]=N'No' OR [sleep_walking]=N'Yes'),
    CHECK ([snoring]=N'No' OR [snoring]=N'Yes'),
    CONSTRAINT [FK_sleep_encounter] FOREIGN KEY ([encounter_id]) REFERENCES [dbo].[patient_encounters] ([encounter_id]),
    CONSTRAINT [FK_sleep_patient] FOREIGN KEY ([patient_id]) REFERENCES [dbo].[patients] ([patient_id])
);


GO
CREATE NONCLUSTERED INDEX [IX_sleep_patterns_encounter]
    ON [dbo].[sleep_patterns]([encounter_id] ASC);

