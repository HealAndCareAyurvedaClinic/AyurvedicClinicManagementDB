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
    -- Panchakarma is bodywork: a therapist is matched to the patient's sex, so a
    -- therapist whose gender is not recorded cannot be assigned to a session.
    [gender]              NVARCHAR (10)  NULL,
    PRIMARY KEY CLUSTERED ([staff_id] ASC),
    CONSTRAINT [CK_staff_staff_type] CHECK ([staff_type] IN ('Doctor', 'Assistant Doctor', 'Nurse', 'Therapist', 'Receptionist')),
    CONSTRAINT [CK_staff_gender] CHECK ([gender] IS NULL OR [gender] IN ('Male', 'Female', 'Other'))
);


GO
-- Unique only among non-NULL registration numbers. A plain UNIQUE constraint
-- treats NULLs as equal, so a second therapist or receptionist without a council
-- registration number was rejected as a duplicate.
CREATE UNIQUE NONCLUSTERED INDEX [UX_staff_registration_number]
    ON [dbo].[staff]([registration_number] ASC) WHERE ([registration_number] IS NOT NULL);
