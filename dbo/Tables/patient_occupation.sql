CREATE TABLE [dbo].[patient_occupation] (
    [occupation_id]           INT            IDENTITY (1, 1) NOT NULL,
    [patient_id]              INT            NOT NULL,
    [occupation_type]         NVARCHAR (50)  NULL,
    [occupation_details]      NVARCHAR (255) NULL,
    [work_nature]             NVARCHAR (50)  NULL,
    [work_environment]        NVARCHAR (50)  NULL,
    [shift_type]              NVARCHAR (20)  NULL,
    [work_hours_per_day]      DECIMAL (4, 2) NULL,
    [vehicle_usage]           NVARCHAR (20)  NULL,
    [travel_frequency]        NVARCHAR (50)  NULL,
    [travel_duration_per_day] NVARCHAR (50)  NULL,
    [updated_at]              DATETIME2 (0)  DEFAULT (sysutcdatetime()) NOT NULL,
    [updated_by]              INT            NULL,
    PRIMARY KEY CLUSTERED ([occupation_id] ASC),
    CHECK ([occupation_type]=N'Other' OR [occupation_type]=N'Homemaker' OR [occupation_type]=N'Retired' OR [occupation_type]=N'Student' OR [occupation_type]=N'Business' OR [occupation_type]=N'Job' OR [occupation_type]=N'Self_employed'),
    CHECK ([shift_type]=N'Fixed' OR [shift_type]=N'Rotational' OR [shift_type]=N'Night' OR [shift_type]=N'Day'),
    CHECK ([vehicle_usage]=N'None' OR [vehicle_usage]=N'Both' OR [vehicle_usage]=N'Four_wheeler' OR [vehicle_usage]=N'Two_wheeler'),
    CHECK ([work_environment]=N'Other' OR [work_environment]=N'Indoor' OR [work_environment]=N'Outdoor' OR [work_environment]=N'Cold' OR [work_environment]=N'Hot' OR [work_environment]=N'Air_conditioned'),
    CHECK ([work_nature]=N'Other' OR [work_nature]=N'Mixed' OR [work_nature]=N'Physical_labor' OR [work_nature]=N'Mental_stress' OR [work_nature]=N'Walking' OR [work_nature]=N'Sitting'),
    CONSTRAINT [FK_occupation_patient] FOREIGN KEY ([patient_id]) REFERENCES [dbo].[patients] ([patient_id]),
    UNIQUE NONCLUSTERED ([patient_id] ASC)
);

