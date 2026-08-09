-- The bookable times generated from a therapist's schedule.
-- Mirrors dbo.appointment_slots.
CREATE TABLE [dbo].[therapist_slots] (
    [slot_id]      INT            IDENTITY (1, 1) NOT NULL,
    [therapist_id] INT            NOT NULL,
    [slot_date]    DATE           NOT NULL,
    [slot_time]    TIME (5)       NOT NULL,
    [is_available] BIT            CONSTRAINT [DF_therapist_slots_available] DEFAULT ((1)) NOT NULL,
    [is_blocked]   BIT            CONSTRAINT [DF_therapist_slots_blocked] DEFAULT ((0)) NOT NULL,
    [block_reason] NVARCHAR (255) NULL,
    CONSTRAINT [PK_therapist_slots] PRIMARY KEY CLUSTERED ([slot_id] ASC),
    CONSTRAINT [UQ_therapist_slots_slot] UNIQUE NONCLUSTERED ([therapist_id] ASC, [slot_date] ASC, [slot_time] ASC),
    CONSTRAINT [FK_therapist_slots_staff] FOREIGN KEY ([therapist_id]) REFERENCES [dbo].[staff] ([staff_id])
);


GO
CREATE NONCLUSTERED INDEX [IX_therapist_slots_date]
    ON [dbo].[therapist_slots]([slot_date] ASC, [therapist_id] ASC);
