-- What actually happened in the therapy room. Kept apart from
-- dbo.patient_encounters: a therapy session is not a clinic visit and does not
-- belong in the visit picker. Reaching Completed is what puts it in front of
-- the billing counter.
CREATE TABLE [dbo].[panchkarma_sessions] (
    [session_id]       INT             IDENTITY (1, 1) NOT NULL,
    -- One session per appointment; starting it twice must not duplicate the record.
    [appointment_id]   INT             NOT NULL,
    [patient_id]       INT             NOT NULL,
    [therapy_id]       INT             NULL,
    [therapist_id]     INT             NULL,
    [doctor_id]        INT             NULL,
    [room_id]          INT             NULL,
    [session_date]     DATE            NOT NULL,
    [started_at]       DATETIME2 (7)   NULL,
    [completed_at]     DATETIME2 (7)   NULL,
    [session_status]   NVARCHAR (20)   CONSTRAINT [DF_panchkarma_sessions_status] DEFAULT ('In_progress') NOT NULL,
    -- What was done: oils, temperature, duration, sequence of steps.
    [therapy_details]  NVARCHAR (MAX)  NULL,
    [materials_used]   NVARCHAR (1000) NULL,
    [duration_minutes] INT             NULL,
    -- Who wrote what. The therapist delivers, the doctor oversees.
    [therapist_notes]  NVARCHAR (MAX)  NULL,
    [doctor_notes]     NVARCHAR (MAX)  NULL,
    [patient_response] NVARCHAR (1000) NULL,
    [created_at]       DATETIME2 (7)   CONSTRAINT [DF_panchkarma_sessions_created] DEFAULT (sysutcdatetime()) NOT NULL,
    [updated_at]       DATETIME2 (7)   CONSTRAINT [DF_panchkarma_sessions_updated] DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [PK_panchkarma_sessions] PRIMARY KEY CLUSTERED ([session_id] ASC),
    CONSTRAINT [UQ_panchkarma_sessions_appointment] UNIQUE NONCLUSTERED ([appointment_id] ASC),
    CONSTRAINT [CK_panchkarma_sessions_status] CHECK ([session_status] IN ('In_progress', 'Completed', 'Cancelled')),
    CONSTRAINT [FK_panchkarma_sessions_appointment] FOREIGN KEY ([appointment_id]) REFERENCES [dbo].[appointments] ([appointment_id]),
    CONSTRAINT [FK_panchkarma_sessions_patient] FOREIGN KEY ([patient_id]) REFERENCES [dbo].[patients] ([patient_id]),
    CONSTRAINT [FK_panchkarma_sessions_therapy] FOREIGN KEY ([therapy_id]) REFERENCES [dbo].[panchkarma_therapies] ([therapy_id]),
    CONSTRAINT [FK_panchkarma_sessions_therapist] FOREIGN KEY ([therapist_id]) REFERENCES [dbo].[staff] ([staff_id]),
    CONSTRAINT [FK_panchkarma_sessions_doctor] FOREIGN KEY ([doctor_id]) REFERENCES [dbo].[doctors] ([doctor_id]),
    CONSTRAINT [FK_panchkarma_sessions_room] FOREIGN KEY ([room_id]) REFERENCES [dbo].[panchkarma_rooms] ([room_id])
);


GO
CREATE NONCLUSTERED INDEX [IX_panchkarma_sessions_status]
    ON [dbo].[panchkarma_sessions]([session_status] ASC, [session_date] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_panchkarma_sessions_patient]
    ON [dbo].[panchkarma_sessions]([patient_id] ASC);
