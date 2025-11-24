CREATE TABLE [dbo].[patients] (
    [patient_id]                 INT            IDENTITY (1, 1) NOT NULL,
    [registration_number]        NVARCHAR (50)  NOT NULL,
    [first_name]                 NVARCHAR (255) NOT NULL,
    [middle_name]                NVARCHAR (255) NULL,
    [last_name]                  NVARCHAR (255) NOT NULL,
    [date_of_birth]              DATE           NOT NULL,
    [birth_time]                 NVARCHAR (255) NULL,
    [gender]                     NVARCHAR (20)  NOT NULL,
    [birth_place]                NVARCHAR (255) NULL,
    [education]                  NVARCHAR (255) NULL,
    [phone_country_code]         NVARCHAR (10)  NOT NULL,
    [phone]                      NVARCHAR (15)  NOT NULL,
    [alternate_phone]            NVARCHAR (15)  NULL,
    [whatsapp_phone]             NVARCHAR (15)  NULL,
    [email]                      NVARCHAR (255) NULL,
    [address_line1]              NVARCHAR (MAX) NULL,
    [address_line2]              NVARCHAR (MAX) NULL,
    [city]                       NVARCHAR (100) NULL,
    [state]                      NVARCHAR (100) NULL,
    [pincode]                    NVARCHAR (10)  NULL,
    [country]                    NVARCHAR (100) DEFAULT (N'India') NOT NULL,
    [blood_group]                NVARCHAR (5)   NULL,
    [marital_status]             NVARCHAR (20)  NULL,
    [emergency_contact_name]     NVARCHAR (255) NULL,
    [emergency_contact_phone]    NVARCHAR (15)  NULL,
    [emergency_contact_relation] NVARCHAR (50)  NULL,
    [registration_date]          DATE           NOT NULL,
    [is_active]                  BIT            DEFAULT ((1)) NOT NULL,
    [created_at]                 DATETIME2 (0)  DEFAULT (sysutcdatetime()) NOT NULL,
    [updated_at]                 DATETIME2 (0)  DEFAULT (sysutcdatetime()) NOT NULL,
    [created_by]                 INT            NULL,
    [updated_by]                 INT            NULL,
    PRIMARY KEY CLUSTERED ([patient_id] ASC),
    CHECK ([gender]=N'Other' OR [gender]=N'Female' OR [gender]=N'Male'),
    CHECK ([marital_status]=N'Widowed' OR [marital_status]=N'Divorced' OR [marital_status]=N'Unmarried' OR [marital_status]=N'Married'),
    UNIQUE NONCLUSTERED ([registration_number] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_patients_reg_number]
    ON [dbo].[patients]([registration_number] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_patients_phone]
    ON [dbo].[patients]([phone] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_patients_is_active]
    ON [dbo].[patients]([is_active] ASC);

