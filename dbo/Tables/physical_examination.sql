CREATE TABLE [dbo].[physical_examination] (
    [physical_exam_id]     INT            IDENTITY (1, 1) NOT NULL,
    [patient_id]           INT            NOT NULL,
    [encounter_id]         INT            NOT NULL,
    [general_appearance]   NVARCHAR (MAX) NULL,
    [built]                NVARCHAR (20)  NULL,
    [nourishment]          NVARCHAR (30)  NULL,
    [pallor]               NVARCHAR (10)  NULL,
    [icterus]              NVARCHAR (10)  NULL,
    [cyanosis]             NVARCHAR (10)  NULL,
    [clubbing]             NVARCHAR (10)  NULL,
    [lymphadenopathy]      NVARCHAR (10)  NULL,
    [edema]                NVARCHAR (10)  NULL,
    [skin_examination]     NVARCHAR (MAX) NULL,
    [systemic_examination] NVARCHAR (MAX) NULL,
    [recorded_at]          DATETIME2 (0)  DEFAULT (sysutcdatetime()) NOT NULL,
    PRIMARY KEY CLUSTERED ([physical_exam_id] ASC),
    CHECK ([built]=N'Obese' OR [built]=N'Medium' OR [built]=N'Thin'),
    CHECK ([clubbing]=N'Absent' OR [clubbing]=N'Present'),
    CHECK ([cyanosis]=N'Absent' OR [cyanosis]=N'Present'),
    CHECK ([edema]=N'Absent' OR [edema]=N'Present'),
    CHECK ([icterus]=N'Absent' OR [icterus]=N'Present'),
    CHECK ([lymphadenopathy]=N'Absent' OR [lymphadenopathy]=N'Present'),
    CHECK ([nourishment]=N'Poorly_nourished' OR [nourishment]=N'Moderately_nourished' OR [nourishment]=N'Well_nourished'),
    CHECK ([pallor]=N'Absent' OR [pallor]=N'Present'),
    CONSTRAINT [FK_phys_exam_encounter] FOREIGN KEY ([encounter_id]) REFERENCES [dbo].[patient_encounters] ([encounter_id]),
    CONSTRAINT [FK_phys_exam_patient] FOREIGN KEY ([patient_id]) REFERENCES [dbo].[patients] ([patient_id])
);


GO
CREATE NONCLUSTERED INDEX [IX_physical_examination_encounter]
    ON [dbo].[physical_examination]([encounter_id] ASC);

