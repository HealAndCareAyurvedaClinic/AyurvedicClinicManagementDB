-- The recurring hours a therapist works. Mirrors dbo.doctor_schedule: a session
-- cannot be booked out of the supervising doctor's diary, so therapists get
-- schedules of their own.
CREATE TABLE [dbo].[therapist_schedule] (
    [schedule_id]           INT           IDENTITY (1, 1) NOT NULL,
    [therapist_id]          INT           NOT NULL,
    [day_of_week]           NVARCHAR (20) NOT NULL,
    [start_time]            TIME (5)      NOT NULL,
    [end_time]              TIME (5)      NOT NULL,
    [slot_duration_minutes] INT           CONSTRAINT [DF_therapist_schedule_duration] DEFAULT ((60)) NULL,
    [max_sessions_per_slot] INT           CONSTRAINT [DF_therapist_schedule_capacity] DEFAULT ((1)) NULL,
    [is_active]             BIT           CONSTRAINT [DF_therapist_schedule_active] DEFAULT ((1)) NOT NULL,
    [effective_from]        DATE          NULL,
    [effective_to]          DATE          NULL,
    CONSTRAINT [PK_therapist_schedule] PRIMARY KEY CLUSTERED ([schedule_id] ASC),
    CONSTRAINT [CK_therapist_schedule_day] CHECK ([day_of_week] IN ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday')),
    CONSTRAINT [FK_therapist_schedule_staff] FOREIGN KEY ([therapist_id]) REFERENCES [dbo].[staff] ([staff_id])
);


GO
CREATE NONCLUSTERED INDEX [IX_therapist_schedule_therapist]
    ON [dbo].[therapist_schedule]([therapist_id] ASC, [is_active] ASC);
