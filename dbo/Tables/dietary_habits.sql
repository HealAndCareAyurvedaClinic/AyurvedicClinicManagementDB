CREATE TABLE [dbo].[dietary_habits] (
    [diet_id]                 INT            IDENTITY (1, 1) NOT NULL,
    [patient_id]              INT            NOT NULL,
    [encounter_id]            INT            NOT NULL,
    [hunger_level]            NVARCHAR (50)  NULL,
    [meals_per_day]           INT            NULL,
    [water_intake_liters]     DECIMAL (3, 1) NULL,
    [breakfast_timing]        NVARCHAR (50)  NULL,
    [lunch_timing]            NVARCHAR (50)  NULL,
    [supper_timing]           NVARCHAR (50)  NULL,
    [dinner_timing]           NVARCHAR (50)  NULL,
    [meal_timing]             NVARCHAR (20)  NULL,
    [meal_preference]         NVARCHAR (50)  NULL,
    [hunger_feeling]          NVARCHAR (20)  NULL,
    [food_intolerance]        NVARCHAR (MAX) NULL,
    [main_staple_food]        NVARCHAR (100) NULL,
    [diet_type]               NVARCHAR (30)  NULL,
    [tea_coffee_intake]       BIT            NULL,
    [tea_coffee_cups_per_day] INT            NULL,
    [milk_intake]             BIT            NULL,
    [late_night_eating]       BIT            NULL,
    [outside_food_frequency]  NVARCHAR (50)  NULL,
    [fruit_intake]            NVARCHAR (MAX) NULL,
    [fruit_intake_timing]     NVARCHAR (30)  NULL,
    [created_at]              DATETIME2 (0)  DEFAULT (sysutcdatetime()) NOT NULL,
    [updated_at]              DATETIME2 (0)  DEFAULT (sysutcdatetime()) NOT NULL,
    [created_by]              INT            NULL,
    [updated_by]              INT            NULL,
    PRIMARY KEY CLUSTERED ([diet_id] ASC),
    CHECK ([diet_type]=N'Eggetarian' OR [diet_type]=N'Vegan' OR [diet_type]=N'Non_vegetarian' OR [diet_type]=N'Vegetarian'),
    CHECK ([fruit_intake_timing]=N'Other_Time' OR [fruit_intake_timing]=N'After_Meal' OR [fruit_intake_timing]=N'During_Meal' OR [fruit_intake_timing]=N'Before_Meal'),
    CHECK ([hunger_feeling]=N'Not_at_all' OR [hunger_feeling]=N'Sometimes' OR [hunger_feeling]=N'No' OR [hunger_feeling]=N'Yes'),
    CHECK ([meal_preference]=N'Irregular' OR [meal_preference]=N'After_hunger' OR [meal_preference]=N'During_hunger' OR [meal_preference]=N'Before_hunger'),
    CHECK ([meal_timing]=N'Irregular' OR [meal_timing]=N'Regular'),
    CONSTRAINT [FK_diet_encounter] FOREIGN KEY ([encounter_id]) REFERENCES [dbo].[patient_encounters] ([encounter_id]),
    CONSTRAINT [FK_diet_patient] FOREIGN KEY ([patient_id]) REFERENCES [dbo].[patients] ([patient_id])
);


GO
CREATE NONCLUSTERED INDEX [IX_dietary_habits_encounter]
    ON [dbo].[dietary_habits]([encounter_id] ASC);

