-- Configurable therapy master. Therapies moved out of free text so a session
-- visit can be billed on the therapy rather than on a consultation fee.
CREATE TABLE [dbo].[panchkarma_therapies] (
    [therapy_id]               INT             IDENTITY (1, 1) NOT NULL,
    [therapy_name]             NVARCHAR (120)  NOT NULL,
    [description]              NVARCHAR (500)  NULL,
    -- Typical length of one session; the booking screen offers it as the default.
    [default_duration_minutes] INT             CONSTRAINT [DF_panchkarma_therapies_duration] DEFAULT ((45)) NOT NULL,
    -- What one session costs. Charges are placeholders for the clinic to set.
    [standard_charge]          DECIMAL (10, 2) CONSTRAINT [DF_panchkarma_therapies_charge] DEFAULT ((0)) NOT NULL,
    [preparation_notes]        NVARCHAR (500)  NULL,
    [is_active]                BIT             CONSTRAINT [DF_panchkarma_therapies_active] DEFAULT ((1)) NOT NULL,
    [created_at]               DATETIME2 (7)   CONSTRAINT [DF_panchkarma_therapies_created] DEFAULT (sysutcdatetime()) NOT NULL,
    [updated_at]               DATETIME2 (7)   CONSTRAINT [DF_panchkarma_therapies_updated] DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [PK_panchkarma_therapies] PRIMARY KEY CLUSTERED ([therapy_id] ASC),
    CONSTRAINT [UQ_panchkarma_therapies_name] UNIQUE NONCLUSTERED ([therapy_name] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_panchkarma_therapies_active]
    ON [dbo].[panchkarma_therapies]([is_active] ASC);
