CREATE TABLE [dbo].[perspiration] (
    [sweda_id]                      INT            IDENTITY (1, 1) NOT NULL,
    [patient_id]                    INT            NOT NULL,
    [encounter_id]                  INT            NOT NULL,
    [sweat_amount]                  NVARCHAR (20)  NOT NULL,
    [sweat_timing]                  NVARCHAR (100) NULL,
    [summer_sweat]                  NVARCHAR (30)  NULL,
    [sweat_odor]                    NVARCHAR (20)  NULL,
    [body_odor]                     NVARCHAR (3)   NULL,
    [night_sweats]                  NVARCHAR (3)   NULL,
    [stain_on_clothes]              NVARCHAR (3)   NULL,
    [palm_and_feet_sweat_excessive] NVARCHAR (3)   NULL,
    [ac_usage]                      NVARCHAR (3)   NULL,
    [created_at]                    DATETIME2 (0)  DEFAULT (sysutcdatetime()) NOT NULL,
    [updated_at]                    DATETIME2 (0)  DEFAULT (sysutcdatetime()) NOT NULL,
    [created_by]                    INT            NULL,
    [updated_by]                    INT            NULL,
    PRIMARY KEY CLUSTERED ([sweda_id] ASC),
    CHECK ([ac_usage]=N'No' OR [ac_usage]=N'Yes'),
    CHECK ([body_odor]=N'No' OR [body_odor]=N'Yes'),
    CHECK ([night_sweats]=N'No' OR [night_sweats]=N'Yes'),
    CHECK ([palm_and_feet_sweat_excessive]=N'No' OR [palm_and_feet_sweat_excessive]=N'Yes'),
    CHECK ([stain_on_clothes]=N'No' OR [stain_on_clothes]=N'Yes'),
    CHECK ([summer_sweat]=N'During_work' OR [summer_sweat]=N'In_sun_only' OR [summer_sweat]=N'Excessive' OR [summer_sweat]=N'Normal'),
    CHECK ([sweat_amount]=N'Absent' OR [sweat_amount]=N'Less' OR [sweat_amount]=N'Moderate' OR [sweat_amount]=N'Excessive'),
    CHECK ([sweat_odor]=N'None' OR [sweat_odor]=N'Mild' OR [sweat_odor]=N'Moderate' OR [sweat_odor]=N'Strong'),
    CONSTRAINT [FK_sweda_encounter] FOREIGN KEY ([encounter_id]) REFERENCES [dbo].[patient_encounters] ([encounter_id]),
    CONSTRAINT [FK_sweda_patient] FOREIGN KEY ([patient_id]) REFERENCES [dbo].[patients] ([patient_id])
);


GO
CREATE NONCLUSTERED INDEX [IX_perspiration_encounter]
    ON [dbo].[perspiration]([encounter_id] ASC);

