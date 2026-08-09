-- The therapies performed in one sitting. A session is rarely one therapy:
-- Snehan and Swedan prepare the body for Basti, and the whole sequence is billed
-- as a whole. The order booked is the order performed and printed.
CREATE TABLE [dbo].[appointment_therapies] (
    [id]             INT             IDENTITY (1, 1) NOT NULL,
    [appointment_id] INT             NOT NULL,
    [therapy_id]     INT             NOT NULL,
    [sequence_order] INT             CONSTRAINT [DF_appointment_therapies_order] DEFAULT ((1)) NOT NULL,
    -- What this therapy costs on THIS booking. Held here so repricing the
    -- master later cannot change an existing booking's total.
    [charge]         DECIMAL (10, 2) CONSTRAINT [DF_appointment_therapies_charge] DEFAULT ((0)) NOT NULL,
    [created_at]     DATETIME2 (7)   CONSTRAINT [DF_appointment_therapies_created] DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [PK_appointment_therapies] PRIMARY KEY CLUSTERED ([id] ASC),
    -- The same therapy twice in one sitting is a data-entry slip.
    CONSTRAINT [UQ_appointment_therapies] UNIQUE NONCLUSTERED ([appointment_id] ASC, [therapy_id] ASC),
    CONSTRAINT [FK_appointment_therapies_appointment] FOREIGN KEY ([appointment_id]) REFERENCES [dbo].[appointments] ([appointment_id]),
    CONSTRAINT [FK_appointment_therapies_therapy] FOREIGN KEY ([therapy_id]) REFERENCES [dbo].[panchkarma_therapies] ([therapy_id])
);


GO
CREATE NONCLUSTERED INDEX [IX_appointment_therapies_appointment]
    ON [dbo].[appointment_therapies]([appointment_id] ASC, [sequence_order] ASC);
