CREATE TABLE [dbo].[staff] (
    [staff_id]            INT            IDENTITY (1, 1) NOT NULL,
    [staff_name]          NVARCHAR (255) NOT NULL,
    [staff_type]          NVARCHAR (50)  NOT NULL,
    [qualification]       NVARCHAR (255) NULL,
    [specialization]      NVARCHAR (255) NULL,
    [registration_number] NVARCHAR (100) NULL,
    [phone]               NVARCHAR (15)  NULL,
    [mobile]              NVARCHAR (15)  NOT NULL,
    [email]               NVARCHAR (255) NULL,
    [is_active]           BIT            DEFAULT ((1)) NOT NULL,
    [created_at]          DATETIME2 (0)  DEFAULT (sysutcdatetime()) NOT NULL,
    PRIMARY KEY CLUSTERED ([staff_id] ASC),
    CHECK ([staff_type]=N'Receptionist' OR [staff_type]=N'Nurse' OR [staff_type]=N'Assistant Doctor' OR [staff_type]=N'Doctor'),
    UNIQUE NONCLUSTERED ([registration_number] ASC)
);

