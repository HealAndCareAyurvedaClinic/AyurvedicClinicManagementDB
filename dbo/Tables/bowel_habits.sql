CREATE TABLE [dbo].[bowel_habits] (
    [bowel_id]                   INT            IDENTITY (1, 1) NOT NULL,
    [patient_id]                 INT            NOT NULL,
    [encounter_id]               INT            NOT NULL,
    [frequency_per_day]          INT            NOT NULL,
    [duration_in_minutes]        INT            NULL,
    [urgency_present]            NVARCHAR (3)   NULL,
    [urgency_minutes]            INT            NULL,
    [sensation_present_on_time]  NVARCHAR (3)   NULL,
    [after_taking_tea_or_coffee] NVARCHAR (3)   NULL,
    [color]                      NVARCHAR (50)  NULL,
    [consistency]                NVARCHAR (20)  NULL,
    [blood_present]              NVARCHAR (3)   NULL,
    [mucus_present]              NVARCHAR (3)   NULL,
    [undigested_food]            NVARCHAR (3)   NULL,
    [floating_in_water]          NVARCHAR (3)   NULL,
    [gas_issues]                 NVARCHAR (3)   NULL,
    [constipation]               NVARCHAR (3)   NULL,
    [other_complaints]           NVARCHAR (MAX) NULL,
    [any_other_medicine]         NVARCHAR (MAX) NULL,
    [created_at]                 DATETIME2 (0)  DEFAULT (sysutcdatetime()) NOT NULL,
    [updated_at]                 DATETIME2 (0)  DEFAULT (sysutcdatetime()) NOT NULL,
    [created_by]                 INT            NULL,
    [updated_by]                 INT            NULL,
    PRIMARY KEY CLUSTERED ([bowel_id] ASC),
    CHECK ([after_taking_tea_or_coffee]=N'No' OR [after_taking_tea_or_coffee]=N'Yes'),
    CHECK ([blood_present]=N'No' OR [blood_present]=N'Yes'),
    CHECK ([consistency]=N'Sticky' OR [consistency]=N'Watery' OR [consistency]=N'Loose' OR [consistency]=N'Normal' OR [consistency]=N'Hard'),
    CHECK ([constipation]=N'No' OR [constipation]=N'Yes'),
    CHECK ([floating_in_water]=N'No' OR [floating_in_water]=N'Yes'),
    CHECK ([gas_issues]=N'No' OR [gas_issues]=N'Yes'),
    CHECK ([mucus_present]=N'No' OR [mucus_present]=N'Yes'),
    CHECK ([sensation_present_on_time]=N'No' OR [sensation_present_on_time]=N'Yes'),
    CHECK ([undigested_food]=N'No' OR [undigested_food]=N'Yes'),
    CHECK ([urgency_present]=N'No' OR [urgency_present]=N'Yes'),
    CONSTRAINT [FK_bowel_encounter] FOREIGN KEY ([encounter_id]) REFERENCES [dbo].[patient_encounters] ([encounter_id]),
    CONSTRAINT [FK_bowel_patient] FOREIGN KEY ([patient_id]) REFERENCES [dbo].[patients] ([patient_id])
);


GO
CREATE NONCLUSTERED INDEX [IX_bowel_habits_encounter]
    ON [dbo].[bowel_habits]([encounter_id] ASC);

