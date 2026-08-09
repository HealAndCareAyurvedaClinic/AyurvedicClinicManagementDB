-- The therapists delivering a session. Some therapies need more than one pair
-- of hands (four-hand Abhyanga, for one).
CREATE TABLE [dbo].[appointment_therapists] (
    [id]             INT           IDENTITY (1, 1) NOT NULL,
    [appointment_id] INT           NOT NULL,
    [therapist_id]   INT           NOT NULL,
    -- The one shown wherever a single name is displayed.
    [is_primary]     BIT           CONSTRAINT [DF_appointment_therapists_primary] DEFAULT ((0)) NOT NULL,
    [created_at]     DATETIME2 (7) CONSTRAINT [DF_appointment_therapists_created] DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [PK_appointment_therapists] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [UQ_appointment_therapists] UNIQUE NONCLUSTERED ([appointment_id] ASC, [therapist_id] ASC),
    CONSTRAINT [FK_appointment_therapists_appointment] FOREIGN KEY ([appointment_id]) REFERENCES [dbo].[appointments] ([appointment_id]),
    CONSTRAINT [FK_appointment_therapists_staff] FOREIGN KEY ([therapist_id]) REFERENCES [dbo].[staff] ([staff_id])
);


GO
CREATE NONCLUSTERED INDEX [IX_appointment_therapists_appointment]
    ON [dbo].[appointment_therapists]([appointment_id] ASC);
