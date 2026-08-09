-- Therapy rooms. A session is delivered in a room, so a slot is only bookable
-- when BOTH the therapist and a room are free.
CREATE TABLE [dbo].[panchkarma_rooms] (
    [room_id]     INT            IDENTITY (1, 1) NOT NULL,
    [room_name]   NVARCHAR (100) NOT NULL,
    [room_code]   NVARCHAR (20)  NULL,
    [description] NVARCHAR (500) NULL,
    [location]    NVARCHAR (200) NULL,
    -- How many sessions can run in the room at once. Almost always 1, but a
    -- large hall may take more than one table.
    [capacity]    INT            CONSTRAINT [DF_panchkarma_rooms_capacity] DEFAULT ((1)) NOT NULL,
    [is_active]   BIT            CONSTRAINT [DF_panchkarma_rooms_active] DEFAULT ((1)) NOT NULL,
    [created_at]  DATETIME2 (7)  CONSTRAINT [DF_panchkarma_rooms_created] DEFAULT (sysutcdatetime()) NOT NULL,
    [updated_at]  DATETIME2 (7)  CONSTRAINT [DF_panchkarma_rooms_updated] DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [PK_panchkarma_rooms] PRIMARY KEY CLUSTERED ([room_id] ASC),
    CONSTRAINT [UQ_panchkarma_rooms_name] UNIQUE NONCLUSTERED ([room_name] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_panchkarma_rooms_active]
    ON [dbo].[panchkarma_rooms]([is_active] ASC);
