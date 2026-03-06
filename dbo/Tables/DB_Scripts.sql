-- =========================================================
-- Ayurvedic Clinic Management System - SQL Server Schema
-- Database: ayur_clinic
-- Corrected & SQL Server Compatible
-- =========================================================

SET NOCOUNT ON;
GO

-- Drop tables in reverse dependency order
IF OBJECT_ID('dbo.encounter_notes','U') IS NOT NULL DROP TABLE dbo.encounter_notes;
IF OBJECT_ID('dbo.encounter_diagnosis','U') IS NOT NULL DROP TABLE dbo.encounter_diagnosis;
IF OBJECT_ID('dbo.physical_examination','U') IS NOT NULL DROP TABLE dbo.physical_examination;
IF OBJECT_ID('dbo.ashtavidha_pariksha','U') IS NOT NULL DROP TABLE dbo.ashtavidha_pariksha;
IF OBJECT_ID('dbo.nadi_pariksha','U') IS NOT NULL DROP TABLE dbo.nadi_pariksha;
IF OBJECT_ID('dbo.ayurvedic_examination','U') IS NOT NULL DROP TABLE dbo.ayurvedic_examination;
IF OBJECT_ID('dbo.mental_health','U') IS NOT NULL DROP TABLE dbo.mental_health;
IF OBJECT_ID('dbo.sensory_details','U') IS NOT NULL DROP TABLE dbo.sensory_details;
IF OBJECT_ID('dbo.sleep_patterns','U') IS NOT NULL DROP TABLE dbo.sleep_patterns;
IF OBJECT_ID('dbo.perspiration','U') IS NOT NULL DROP TABLE dbo.perspiration;
IF OBJECT_ID('dbo.urinary_habits','U') IS NOT NULL DROP TABLE dbo.urinary_habits;
IF OBJECT_ID('dbo.bowel_habits','U') IS NOT NULL DROP TABLE dbo.bowel_habits;
IF OBJECT_ID('dbo.dietary_habits','U') IS NOT NULL DROP TABLE dbo.dietary_habits;
IF OBJECT_ID('dbo.daily_routine','U') IS NOT NULL DROP TABLE dbo.daily_routine;
IF OBJECT_ID('dbo.visit_complaints','U') IS NOT NULL DROP TABLE dbo.visit_complaints;
IF OBJECT_ID('dbo.visit_vitals','U') IS NOT NULL DROP TABLE dbo.visit_vitals;
IF OBJECT_ID('dbo.patient_encounters','U') IS NOT NULL DROP TABLE dbo.patient_encounters;
IF OBJECT_ID('dbo.current_medications','U') IS NOT NULL DROP TABLE dbo.current_medications;
IF OBJECT_ID('dbo.habbits','U') IS NOT NULL DROP TABLE dbo.habbits;
IF OBJECT_ID('dbo.addictions','U') IS NOT NULL DROP TABLE dbo.addictions;
IF OBJECT_ID('dbo.family_medical_history','U') IS NOT NULL DROP TABLE dbo.family_medical_history;
IF OBJECT_ID('dbo.past_medical_history','U') IS NOT NULL DROP TABLE dbo.past_medical_history;
IF OBJECT_ID('dbo.reproductive_history','U') IS NOT NULL DROP TABLE dbo.reproductive_history;
IF OBJECT_ID('dbo.patient_occupation','U') IS NOT NULL DROP TABLE dbo.patient_occupation;
IF OBJECT_ID('dbo.staff','U') IS NOT NULL DROP TABLE dbo.staff;
IF OBJECT_ID('dbo.patients','U') IS NOT NULL DROP TABLE dbo.patients;
GO

-- =========================================================
-- MASTER TABLES
-- =========================================================

-- Patients Master Table
CREATE TABLE dbo.patients (
    patient_id INT IDENTITY(1,1) PRIMARY KEY,
    registration_number NVARCHAR(50) NOT NULL UNIQUE,
    first_name NVARCHAR(255) NOT NULL,
    middle_name NVARCHAR(255) NULL,
    last_name NVARCHAR(255) NOT NULL,
    date_of_birth DATE NOT NULL,
    birth_time NVARCHAR(255) NULL,
    gender NVARCHAR(20) NOT NULL CHECK (gender IN (N'Male', N'Female', N'Other')),
    birth_place NVARCHAR(255) NULL,
    education NVARCHAR(255) NULL,
    phone_country_code NVARCHAR(10) NOT NULL,
    phone NVARCHAR(15) NOT NULL,
    alternate_phone NVARCHAR(15) NULL,
    whatsapp_phone NVARCHAR(15) NULL,
    email NVARCHAR(255) NULL,
    address_line1 NVARCHAR(MAX) NULL,
    address_line2 NVARCHAR(MAX) NULL,
    city NVARCHAR(100) NULL,
    state NVARCHAR(100) NULL,
    pincode NVARCHAR(10) NULL,
    country NVARCHAR(100) NOT NULL DEFAULT N'India',
    blood_group NVARCHAR(5) NULL,
    marital_status NVARCHAR(20) NULL CHECK (marital_status IN (N'Married', N'Unmarried', N'Divorced', N'Widowed')),
    emergency_contact_name NVARCHAR(255) NULL,
    emergency_contact_phone NVARCHAR(15) NULL,
    emergency_contact_relation NVARCHAR(50) NULL,
    registration_date DATE NOT NULL,
    is_active BIT NOT NULL DEFAULT 1,
    created_at DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    created_by INT NULL,
    updated_by INT NULL
);
GO

-- Patient Occupation
CREATE TABLE dbo.patient_occupation (
    occupation_id INT IDENTITY(1,1) PRIMARY KEY,
    patient_id INT NOT NULL UNIQUE,
    occupation_type NVARCHAR(50) NULL CHECK (occupation_type IN (N'Self_employed', N'Job', N'Business', N'Student', N'Retired', N'Homemaker', N'Other')),
    occupation_details NVARCHAR(255) NULL,
    work_nature NVARCHAR(50) NULL CHECK (work_nature IN (N'Sitting', N'Walking', N'Mental_stress', N'Physical_labor', N'Mixed', N'Other')),
    work_environment NVARCHAR(50) NULL CHECK (work_environment IN (N'Air_conditioned', N'Hot', N'Cold', N'Outdoor', N'Indoor', N'Other')),
    shift_type NVARCHAR(20) NULL CHECK (shift_type IN (N'Day', N'Night', N'Rotational', N'Fixed')),
    work_hours_per_day DECIMAL(4,2) NULL,
    vehicle_usage NVARCHAR(20) NULL CHECK (vehicle_usage IN (N'Two_wheeler', N'Four_wheeler', N'Both', N'None')),
    travel_frequency NVARCHAR(50) NULL,
    travel_duration_per_day NVARCHAR(50) NULL,
    updated_at DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_by INT NULL,
    CONSTRAINT FK_occupation_patient FOREIGN KEY (patient_id) REFERENCES dbo.patients(patient_id) 
);
GO

-- Reproductive History
CREATE TABLE dbo.reproductive_history (
    reproductive_id INT IDENTITY(1,1) PRIMARY KEY,
    patient_id INT NOT NULL UNIQUE,
    sexually_satisfied NVARCHAR(3) NULL CHECK (sexually_satisfied IN (N'Yes', N'No')),
    intercourse_frequency NVARCHAR(50) NULL,
    sexual_complaints NVARCHAR(50) NULL,
    masturbation_habit NVARCHAR(3) NULL CHECK (masturbation_habit IN (N'Yes', N'No')),
    family_planning NVARCHAR(3) NULL CHECK (family_planning IN (N'Yes', N'No')),
    contraceptive_method NVARCHAR(100) NULL,
    number_of_sons INT NOT NULL DEFAULT 0,
    number_of_daughters INT NOT NULL DEFAULT 0,
    total_pregnancies INT NOT NULL DEFAULT 0,
    miscarriage_count INT NOT NULL DEFAULT 0,
    abortion_count INT NOT NULL DEFAULT 0,
    gynecological_issues NVARCHAR(MAX) NULL,
    menstrual_history NVARCHAR(MAX) NULL,
    last_period_date DATETIME2(0) NULL,
    created_at DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    created_by INT NULL,
    updated_by INT NULL,
    CONSTRAINT FK_reproductive_patient FOREIGN KEY (patient_id) REFERENCES dbo.patients(patient_id) 
);
GO

-- Past Medical History
CREATE TABLE dbo.past_medical_history (
    history_id INT IDENTITY(1,1) PRIMARY KEY,
    patient_id INT NOT NULL,
    disease_name NVARCHAR(50) NULL CHECK (disease_name IN (N'Gowar', N'Kanjinya', N'Devi', N'Maleria', N'Other')),
    other_disease_name NVARCHAR(50) NULL,
    diagnosis_date DATE NULL,
    treatment_received NVARCHAR(MAX) NULL,
    duration NVARCHAR(100) NULL,
    current_status NVARCHAR(20) NULL CHECK (current_status IN (N'Cured', N'Ongoing', N'Recurrent')),
    notes NVARCHAR(MAX) NULL,
    created_at DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    created_by INT NULL,
    updated_by INT NULL,
    CONSTRAINT FK_past_medical_patient FOREIGN KEY (patient_id) REFERENCES dbo.patients(patient_id) 
);
GO

-- Family Medical History
CREATE TABLE dbo.family_medical_history (
    family_history_id INT IDENTITY(1,1) PRIMARY KEY,
    patient_id INT NOT NULL,
    disease_type NVARCHAR(50) NULL CHECK (disease_type IN (N'CANCER', N'Diabetes', N'Asthama', N'other')),
    other_disease_type NVARCHAR(50) NULL,
    affected_relation NVARCHAR(100) NULL,
    notes NVARCHAR(MAX) NULL,
    swakul NVARCHAR(100) NULL,
    pitrukul NVARCHAR(100) NULL,
    matrukul NVARCHAR(100) NULL,
    created_at DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    created_by INT NULL,
    updated_by INT NULL,
    CONSTRAINT FK_family_medical_patient FOREIGN KEY (patient_id) REFERENCES dbo.patients(patient_id) 
);
GO

-- Addictions
CREATE TABLE dbo.addictions (
    addiction_id INT IDENTITY(1,1) PRIMARY KEY,
    patient_id INT NOT NULL,
    addiction_type NVARCHAR(50) NOT NULL CHECK (addiction_type IN (N'Supari', N'Pan', N'Tobacco', N'Bidi', N'Cigarette', N'Pan_masala', N'Gutkha', N'Alcohol', N'Drugs', N'Tobacco_in_teeth', N'Other')),
    other_addiction_type NVARCHAR(100) NULL,
    frequency NVARCHAR(100) NULL,
    quantity_per_day NVARCHAR(50) NULL,
    addiction_duration_years INT NULL,
    start_age INT NULL,
    notes NVARCHAR(MAX) NULL,
    created_at DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    created_by INT NULL,
    updated_by INT NULL,
    CONSTRAINT FK_addiction_patient FOREIGN KEY (patient_id) REFERENCES dbo.patients(patient_id) 
);
GO

-- Habits
CREATE TABLE dbo.habbits (
    habbit_id INT IDENTITY(1,1) PRIMARY KEY,
    patient_id INT NOT NULL,
    habbit_type NVARCHAR(50) NOT NULL CHECK (habbit_type IN (N'Nail Biting', N'Soil', N'Rock', N'Other')),
    other_habbit_type NVARCHAR(100) NULL,
    notes NVARCHAR(MAX) NULL,
    created_at DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    created_by INT NULL,
    updated_by INT NULL,
    CONSTRAINT FK_habbit_patient FOREIGN KEY (patient_id) REFERENCES dbo.patients(patient_id) 
);
GO

-- Current Medications
CREATE TABLE dbo.current_medications (
    medication_id INT IDENTITY(1,1) PRIMARY KEY,
    patient_id INT NOT NULL,
    medicine_name NVARCHAR(255) NOT NULL,
    medicine_type NVARCHAR(20) NULL CHECK (medicine_type IN (N'Ayurvedic', N'Allopathic', N'Homeopathic', N'Other')),
    dosage NVARCHAR(100) NULL,
    frequency NVARCHAR(100) NULL,
    duration NVARCHAR(100) NULL,
    prescribing_doctor NVARCHAR(255) NULL,
    start_date DATE NULL,
    end_date DATE NULL,
    is_active BIT NOT NULL DEFAULT 1,
    notes NVARCHAR(MAX) NULL,
    created_at DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    created_by INT NULL,
    updated_by INT NULL,
    CONSTRAINT FK_medication_patient FOREIGN KEY (patient_id) REFERENCES dbo.patients(patient_id) 
);
GO

-- Staff Master
CREATE TABLE dbo.staff (
    staff_id INT IDENTITY(1,1) PRIMARY KEY,
    staff_name NVARCHAR(255) NOT NULL,
    staff_type NVARCHAR(50) NOT NULL CHECK (staff_type IN (N'Doctor', N'Assistant Doctor', N'Nurse', N'Receptionist')),
    qualification NVARCHAR(255) NULL,
    specialization NVARCHAR(255) NULL,
    registration_number NVARCHAR(100) UNIQUE NULL,
    phone NVARCHAR(15) NULL,
    mobile NVARCHAR(15) NOT NULL,
    email NVARCHAR(255) NULL,
    is_active BIT NOT NULL DEFAULT 1,
    created_at DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

-- =========================================================
-- ENCOUNTER TABLES
-- =========================================================

-- Patient Encounters
CREATE TABLE dbo.patient_encounters (
    encounter_id INT IDENTITY(1,1) PRIMARY KEY,
	appointment_id INT,  -- Links to appointment (NULL for walk-ins)
    patient_id INT NOT NULL,
    encounter_sequence NVARCHAR(50) NOT NULL UNIQUE,
    encounter_date DATETIME2(0) NOT NULL,
    encounter_type NVARCHAR(30) NOT NULL CHECK (encounter_type IN (N'New_patient', N'Follow_up', N'Emergency', N'Consultation', N'Panchkarma_session')),
    visit_reason NVARCHAR(MAX) NULL,
    chief_complaint NVARCHAR(MAX) NOT NULL,
    encounter_status NVARCHAR(20) NOT NULL DEFAULT N'Scheduled' CHECK (encounter_status IN (N'Scheduled', N'In_progress', N'Completed', N'Cancelled', N'No_show')),
    staff_id INT NULL,
    referring_doctor NVARCHAR(255) NULL,
    department NVARCHAR(100) NULL,
    created_at DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    created_by INT NULL,
    updated_by INT NULL,
    CONSTRAINT FK_encounter_patient FOREIGN KEY (patient_id) REFERENCES dbo.patients(patient_id) ,
    CONSTRAINT FK_encounter_staff FOREIGN KEY (staff_id) REFERENCES dbo.staff(staff_id) ON DELETE SET NULL
);
GO

-- Visit Vitals
CREATE TABLE dbo.visit_vitals (
    vital_id INT IDENTITY(1,1) PRIMARY KEY,
    encounter_id INT NOT NULL,
    patient_id INT NOT NULL,
    height DECIMAL(5,2) NULL,
    weight DECIMAL(5,2) NULL,
    bmi DECIMAL(4,2) NULL,
    temperature DECIMAL(4,2) NULL,
    pulse_rate INT NULL,
    blood_pressure_systolic INT NULL,
    blood_pressure_diastolic INT NULL,
    respiratory_rate INT NULL,
    oxygen_saturation DECIMAL(5,2) NULL,
    recorded_at DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    created_at DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    created_by INT NULL,
    updated_by INT NULL,
    CONSTRAINT FK_vitals_patient FOREIGN KEY (patient_id) REFERENCES dbo.patients(patient_id) ,
    CONSTRAINT FK_vitals_encounter FOREIGN KEY (encounter_id) REFERENCES dbo.patient_encounters(encounter_id) 
);
CREATE INDEX IX_visit_vitals_encounter ON dbo.visit_vitals(encounter_id);
GO

-- Visit Complaints
CREATE TABLE dbo.visit_complaints (
    complaint_id INT IDENTITY(1,1) PRIMARY KEY,
    encounter_id INT NOT NULL,
    patient_id INT NOT NULL,
    symptoms_text NVARCHAR(MAX) NOT NULL,
    complaint_text NVARCHAR(MAX) NOT NULL,
    duration NVARCHAR(100) NULL,
    physical_feelings NVARCHAR(100) NULL,
    non_physical_feelings NVARCHAR(100) NULL,
    severity NVARCHAR(10) NULL CHECK (severity IN (N'Mild', N'Moderate', N'Severe')),
    chronicity NVARCHAR(10) NULL CHECK (chronicity IN (N'Acute', N'Chronic', N'Subacute')),
    aggravating_factors NVARCHAR(MAX) NULL,
    relieving_factors NVARCHAR(MAX) NULL,
    additional_notes NVARCHAR(MAX) NULL,
    recorded_at DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    created_at DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    created_by INT NULL,
    updated_by INT NULL,
    CONSTRAINT FK_complaints_patient FOREIGN KEY (patient_id) REFERENCES dbo.patients(patient_id) ,
    CONSTRAINT FK_complaints_encounter FOREIGN KEY (encounter_id) REFERENCES dbo.patient_encounters(encounter_id) 
);
CREATE INDEX IX_visit_complaints_encounter ON dbo.visit_complaints(encounter_id);
GO

-- Daily Routine
CREATE TABLE dbo.daily_routine (
    routine_id INT IDENTITY(1,1) PRIMARY KEY,
    patient_id INT NOT NULL,
    encounter_id INT NOT NULL,
    wake_up_time TIME NULL,
    morning_beverage NVARCHAR(100) NULL,
    morning_beverage_cups INT NULL,
    cup_enthusiasm NVARCHAR(3) NULL CHECK (cup_enthusiasm IN (N'Yes', N'No')),
    exercise NVARCHAR(3) NULL CHECK (exercise IN (N'Yes', N'No')),
    exercise_type NVARCHAR(100) NULL,
    exercise_duration NVARCHAR(50) NULL,
    bath_time NVARCHAR(50) NULL,
    bath_water_temp NVARCHAR(10) NULL CHECK (bath_water_temp IN (N'Hot', N'Cold', N'Warm')),
    head_bath_frequency NVARCHAR(100) NULL,
    additional_notes NVARCHAR(MAX) NULL,
    created_at DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    created_by INT NULL,
    updated_by INT NULL,
    CONSTRAINT FK_routine_patient FOREIGN KEY (patient_id) REFERENCES dbo.patients(patient_id) ,
    CONSTRAINT FK_routine_encounter FOREIGN KEY (encounter_id) REFERENCES dbo.patient_encounters(encounter_id) 
);
CREATE INDEX IX_daily_routine_encounter ON dbo.daily_routine(encounter_id);
GO

-- Dietary Habits
CREATE TABLE dbo.dietary_habits (
    diet_id INT IDENTITY(1,1) PRIMARY KEY,
    patient_id INT NOT NULL,
    encounter_id INT NOT NULL,
    hunger_level NVARCHAR(50) NULL,
    meals_per_day INT NULL,
    water_intake_liters DECIMAL(3,1) NULL,
    breakfast_timing NVARCHAR(50) NULL,
    lunch_timing NVARCHAR(50) NULL,
    supper_timing NVARCHAR(50) NULL,
    dinner_timing NVARCHAR(50) NULL,
    meal_timing NVARCHAR(20) NULL CHECK (meal_timing IN (N'Regular', N'Irregular')),
    meal_preference NVARCHAR(50) NULL CHECK (meal_preference IN (N'Before_hunger', N'During_hunger', N'After_hunger', N'Irregular')),
    hunger_feeling NVARCHAR(20) NULL CHECK (hunger_feeling IN (N'Yes', N'No', N'Sometimes', N'Not_at_all')),
    food_intolerance NVARCHAR(MAX) NULL,
    main_staple_food NVARCHAR(100) NULL,
    diet_type NVARCHAR(30) NULL CHECK (diet_type IN (N'Vegetarian', N'Non_vegetarian', N'Vegan', N'Eggetarian')),
    tea_coffee_intake BIT NULL,
    tea_coffee_cups_per_day INT NULL,
    milk_intake BIT NULL,
    late_night_eating BIT NULL,
    outside_food_frequency NVARCHAR(50) NULL,
    fruit_intake NVARCHAR(MAX) NULL,
    fruit_intake_timing NVARCHAR(30) NULL CHECK (fruit_intake_timing IN (N'Before_Meal', N'During_Meal', N'After_Meal', N'Other_Time')),
    created_at DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    created_by INT NULL,
    updated_by INT NULL,
    CONSTRAINT FK_diet_patient FOREIGN KEY (patient_id) REFERENCES dbo.patients(patient_id) ,
    CONSTRAINT FK_diet_encounter FOREIGN KEY (encounter_id) REFERENCES dbo.patient_encounters(encounter_id) 
);
CREATE INDEX IX_dietary_habits_encounter ON dbo.dietary_habits(encounter_id);
GO

-- Bowel Habits
CREATE TABLE dbo.bowel_habits (
    bowel_id INT IDENTITY(1,1) PRIMARY KEY,
    patient_id INT NOT NULL,
    encounter_id INT NOT NULL,
    frequency_per_day INT NOT NULL,
    duration_in_minutes INT NULL,
    urgency_present NVARCHAR(3) NULL CHECK (urgency_present IN (N'Yes', N'No')),
    urgency_minutes INT NULL,
    sensation_present_on_time NVARCHAR(3) NULL CHECK (sensation_present_on_time IN (N'Yes', N'No')),
    after_taking_tea_or_coffee NVARCHAR(3) NULL CHECK (after_taking_tea_or_coffee IN (N'Yes', N'No')),
    color NVARCHAR(50) NULL,
    consistency NVARCHAR(20) NULL CHECK (consistency IN (N'Hard', N'Normal', N'Loose', N'Watery', N'Sticky')),
    blood_present NVARCHAR(3) NULL CHECK (blood_present IN (N'Yes', N'No')),
    mucus_present NVARCHAR(3) NULL CHECK (mucus_present IN (N'Yes', N'No')),
    undigested_food NVARCHAR(3) NULL CHECK (undigested_food IN (N'Yes', N'No')),
    floating_in_water NVARCHAR(3) NULL CHECK (floating_in_water IN (N'Yes', N'No')),
    gas_issues NVARCHAR(3) NULL CHECK (gas_issues IN (N'Yes', N'No')),
    constipation NVARCHAR(3) NULL CHECK (constipation IN (N'Yes', N'No')),
    other_complaints NVARCHAR(MAX) NULL,
    any_other_medicine NVARCHAR(MAX) NULL,
    created_at DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    created_by INT NULL,
    updated_by INT NULL,
    CONSTRAINT FK_bowel_patient FOREIGN KEY (patient_id) REFERENCES dbo.patients(patient_id) ,
    CONSTRAINT FK_bowel_encounter FOREIGN KEY (encounter_id) REFERENCES dbo.patient_encounters(encounter_id) 
);
CREATE INDEX IX_bowel_habits_encounter ON dbo.bowel_habits(encounter_id);
GO

-- Urinary Habits
CREATE TABLE dbo.urinary_habits (
    urine_id INT IDENTITY(1,1) PRIMARY KEY,
    patient_id INT NOT NULL,
    encounter_id INT NOT NULL,
    day_frequency INT NULL,
    night_frequency INT NULL,
    color NVARCHAR(50) NULL,
    odor NVARCHAR(50) NULL,
    clarity NVARCHAR(20) NULL CHECK (clarity IN (N'Clear', N'Cloudy', N'Turbid')),
    scalding NVARCHAR(3) NULL CHECK (scalding IN (N'Yes', N'No')),
    burning_sensation NVARCHAR(3) NULL CHECK (burning_sensation IN (N'Yes', N'No')),
    urgency NVARCHAR(3) NULL CHECK (urgency IN (N'Yes', N'No')),
    hesitancy NVARCHAR(3) NULL CHECK (hesitancy IN (N'Yes', N'No')),
    sediment NVARCHAR(3) NULL CHECK (sediment IN (N'Yes', N'No')),
    other_complaints NVARCHAR(MAX) NULL,
    created_at DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    created_by INT NULL,
    updated_by INT NULL,
    CONSTRAINT FK_urine_patient FOREIGN KEY (patient_id) REFERENCES dbo.patients(patient_id) ,
    CONSTRAINT FK_urine_encounter FOREIGN KEY (encounter_id) REFERENCES dbo.patient_encounters(encounter_id) 
);
CREATE INDEX IX_urinary_habits_encounter ON dbo.urinary_habits(encounter_id);
GO

-- Perspiration (Sweda)
CREATE TABLE dbo.perspiration (
    sweda_id INT IDENTITY(1,1) PRIMARY KEY,
    patient_id INT NOT NULL,
    encounter_id INT NOT NULL,
    sweat_amount NVARCHAR(20) NOT NULL CHECK (sweat_amount IN (N'Excessive', N'Moderate', N'Less', N'Absent')),
    sweat_timing NVARCHAR(100) NULL,
    summer_sweat NVARCHAR(30) NULL CHECK (summer_sweat IN (N'Normal', N'Excessive', N'In_sun_only', N'During_work')),
    sweat_odor NVARCHAR(20) NULL CHECK (sweat_odor IN (N'Strong', N'Moderate', N'Mild', N'None')),
    body_odor NVARCHAR(3) NULL CHECK (body_odor IN (N'Yes', N'No')),
    night_sweats NVARCHAR(3) NULL CHECK (night_sweats IN (N'Yes', N'No')),
    stain_on_clothes NVARCHAR(3) NULL CHECK (stain_on_clothes IN (N'Yes', N'No')),
    palm_and_feet_sweat_excessive NVARCHAR(3) NULL CHECK (palm_and_feet_sweat_excessive IN (N'Yes', N'No')),
    ac_usage NVARCHAR(3) NULL CHECK (ac_usage IN (N'Yes', N'No')),
    created_at DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    created_by INT NULL,
    updated_by INT NULL,
    CONSTRAINT FK_sweda_patient FOREIGN KEY (patient_id) REFERENCES dbo.patients(patient_id) ,
    CONSTRAINT FK_sweda_encounter FOREIGN KEY (encounter_id) REFERENCES dbo.patient_encounters(encounter_id) 
);
CREATE INDEX IX_perspiration_encounter ON dbo.perspiration(encounter_id);
GO

-- Sleep Patterns
CREATE TABLE dbo.sleep_patterns (
    sleep_id INT IDENTITY(1,1) PRIMARY KEY,
    patient_id INT NOT NULL,
    encounter_id INT NOT NULL,
    sleep_time NVARCHAR(10) NOT NULL,
    sleep_difficulty NVARCHAR(30) NULL CHECK (sleep_difficulty IN (N'Always', N'Never', N'Sometimes', N'Occasionally')),
    wake_up_time TIME NULL,
    total_sleep_hours DECIMAL(3,1) NULL,
    sleep_again_after_wake NVARCHAR(3) NULL CHECK (sleep_again_after_wake IN (N'Yes', N'No')),
    daytime_sleep NVARCHAR(3) NULL CHECK (daytime_sleep IN (N'Yes', N'No')),
    daytime_sleep_duration NVARCHAR(50) NULL,
    post_meal_drowsiness NVARCHAR(3) NULL CHECK (post_meal_drowsiness IN (N'Yes', N'No')),
    sleep_quality NVARCHAR(20) NULL CHECK (sleep_quality IN (N'Good', N'Moderate', N'Poor')),
    dreams NVARCHAR(20) NULL CHECK (dreams IN (N'Frequent', N'Occasional', N'Rare', N'None')),
    snoring NVARCHAR(3) NULL CHECK (snoring IN (N'Yes', N'No')),
    sleep_disturbances NVARCHAR(MAX) NULL,
    sleep_talking NVARCHAR(3) NULL CHECK (sleep_talking IN (N'Yes', N'No')),
    sleep_walking NVARCHAR(3) NULL CHECK (sleep_walking IN (N'Yes', N'No')),
    sleep_urinating NVARCHAR(3) NULL CHECK (sleep_urinating IN (N'Yes', N'No')),
    created_at DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    created_by INT NULL,
    updated_by INT NULL,
    CONSTRAINT FK_sleep_patient FOREIGN KEY (patient_id) REFERENCES dbo.patients(patient_id) ,
    CONSTRAINT FK_sleep_encounter FOREIGN KEY (encounter_id) REFERENCES dbo.patient_encounters(encounter_id) 
);
CREATE INDEX IX_sleep_patterns_encounter ON dbo.sleep_patterns(encounter_id);
GO

-- Sensory Details
CREATE TABLE dbo.sensory_details (
    sensory_id INT IDENTITY(1,1) PRIMARY KEY,
    patient_id INT NOT NULL,
    encounter_id INT NOT NULL,
    tv_watching_hours DECIMAL(4,2) NULL,
    computer_work_hours DECIMAL(4,2) NULL,
    mobile_usage_hours DECIMAL(4,2) NULL,
    reading_hours DECIMAL(4,2) NULL,
    eye_strain NVARCHAR(3) NULL CHECK (eye_strain IN (N'Yes', N'No')),
    headache_frequency NVARCHAR(50) NULL,
    created_at DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    created_by INT NULL,
    updated_by INT NULL,
    CONSTRAINT FK_sensory_patient FOREIGN KEY (patient_id) REFERENCES dbo.patients(patient_id) ,
    CONSTRAINT FK_sensory_encounter FOREIGN KEY (encounter_id) REFERENCES dbo.patient_encounters(encounter_id) 
);
CREATE INDEX IX_sensory_details_encounter ON dbo.sensory_details(encounter_id);
GO

-- Mental Health
CREATE TABLE dbo.mental_health (
    mental_health_id INT IDENTITY(1,1) PRIMARY KEY,
    patient_id INT NOT NULL,
    encounter_id INT NOT NULL,
    past_trauma NVARCHAR(3) NOT NULL CHECK (past_trauma IN (N'Yes', N'No')),
    trauma_description NVARCHAR(MAX) NULL,
    trauma_severity NVARCHAR(20) NULL CHECK (trauma_severity IN (N'Mild', N'Moderate', N'Severe')),
    home_office_environment NVARCHAR(MAX) NULL,
    chronic_stress NVARCHAR(3) NULL CHECK (chronic_stress IN (N'Yes', N'No')),
    stress_level NVARCHAR(20) NULL CHECK (stress_level IN (N'Low', N'Moderate', N'High', N'Very_high')),
    stress_symptoms NVARCHAR(MAX) NULL,
    personal_trait_anger BIT NULL,
    personal_trait_short_tempered BIT NULL,
    personal_trait_quarrelsome BIT NULL,
    personal_trait_suspicious BIT NULL,
    personal_trait_greedy BIT NULL,
    personal_trait_careless BIT NULL,
    personal_trait_ambitious BIT NULL,
    personal_trait_jealous BIT NULL,
    anger_issues NVARCHAR(3) NULL CHECK (anger_issues IN (N'Yes', N'No')),
    anger_expression NVARCHAR(MAX) NULL,
    current_situation_satisfaction NVARCHAR(3) NULL CHECK (current_situation_satisfaction IN (N'Yes', N'No')),
    dissatisfaction_areas NVARCHAR(MAX) NULL,
    change_readiness NVARCHAR(3) NULL CHECK (change_readiness IN (N'Yes', N'No')),
    guilt_about_past NVARCHAR(3) NULL CHECK (guilt_about_past IN (N'Yes', N'No')),
    compromise_tendency NVARCHAR(3) NULL CHECK (compromise_tendency IN (N'Yes', N'No')),
    loneliness NVARCHAR(3) NULL CHECK (loneliness IN (N'Yes', N'No')),
    comparison_with_others NVARCHAR(3) NULL CHECK (comparison_with_others IN (N'Yes', N'No')),
    feeling_responsible NVARCHAR(3) NULL CHECK (feeling_responsible IN (N'Yes', N'No')),
    anxiety NVARCHAR(3) NULL CHECK (anxiety IN (N'Yes', N'No')),
    depression_symptoms NVARCHAR(3) NULL CHECK (depression_symptoms IN (N'Yes', N'No')),
    created_at DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    created_by INT NULL,
    updated_by INT NULL,
    CONSTRAINT FK_mental_health_patient FOREIGN KEY (patient_id) REFERENCES dbo.patients(patient_id) ,
    CONSTRAINT FK_mental_health_encounter FOREIGN KEY (encounter_id) REFERENCES dbo.patient_encounters(encounter_id) 
);
CREATE INDEX IX_mental_health_encounter ON dbo.mental_health(encounter_id);
GO

-- =========================================================
-- AYURVEDIC EXAMINATION TABLES
-- =========================================================

-- Ayurvedic Examination
CREATE TABLE dbo.ayurvedic_examination (
    exam_id INT IDENTITY(1,1) PRIMARY KEY,
    patient_id INT NOT NULL,
    encounter_id INT NOT NULL,
    prakriti NVARCHAR(100) NULL,
    vikriti NVARCHAR(100) NULL,
    sara NVARCHAR(100) NULL,
    samhanana NVARCHAR(100) NULL,
    pramana NVARCHAR(100) NULL,
    satmya NVARCHAR(MAX) NULL,
    satva NVARCHAR(100) NULL,
    aharashakti_jarana NVARCHAR(100) NULL,
    aharashakti_abhyavarana NVARCHAR(100) NULL,
    vyayamashakti NVARCHAR(100) NULL,
    vaya NVARCHAR(50) NULL,
    desha NVARCHAR(100) NULL,
    kala NVARCHAR(100) NULL,
    recorded_at DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_ayur_exam_patient FOREIGN KEY (patient_id) REFERENCES dbo.patients(patient_id) ,
    CONSTRAINT FK_ayur_exam_encounter FOREIGN KEY (encounter_id) REFERENCES dbo.patient_encounters(encounter_id) 
);
CREATE INDEX IX_ayurvedic_examination_encounter ON dbo.ayurvedic_examination(encounter_id);
GO

-- Nadi Pariksha (Pulse)
CREATE TABLE dbo.nadi_pariksha (
    nadi_id INT IDENTITY(1,1) PRIMARY KEY,
    patient_id INT NOT NULL,
    encounter_id INT NOT NULL,
    right_hand_superficial NVARCHAR(100) NULL,
    right_hand_middle NVARCHAR(100) NULL,
    right_hand_deep NVARCHAR(100) NULL,
    left_hand_superficial NVARCHAR(100) NULL,
    left_hand_middle NVARCHAR(100) NULL,
    left_hand_deep NVARCHAR(100) NULL,
    vata_characteristics NVARCHAR(MAX) NULL,
    pitta_characteristics NVARCHAR(MAX) NULL,
    kapha_characteristics NVARCHAR(MAX) NULL,
    gati NVARCHAR(100) NULL,
    vega NVARCHAR(100) NULL,
    bala NVARCHAR(100) NULL,
    created_at DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    created_by INT NULL,
    updated_by INT NULL,
    CONSTRAINT FK_nadi_patient FOREIGN KEY (patient_id) REFERENCES dbo.patients(patient_id) ,
    CONSTRAINT FK_nadi_encounter FOREIGN KEY (encounter_id) REFERENCES dbo.patient_encounters(encounter_id) 
);
CREATE INDEX IX_nadi_pariksha_encounter ON dbo.nadi_pariksha(encounter_id);
GO

-- Ashtavidha Pariksha (Eight-fold Examination)
CREATE TABLE dbo.ashtavidha_pariksha (
    ashta_id INT IDENTITY(1,1) PRIMARY KEY,
    patient_id INT NOT NULL,
    encounter_id INT NOT NULL,
    nadi NVARCHAR(100) NULL,
    mutra NVARCHAR(100) NULL,
    mala NVARCHAR(100) NULL,
    jihva NVARCHAR(100) NULL,
    shabda NVARCHAR(100) NULL,
    sparsha NVARCHAR(100) NULL,
    drik NVARCHAR(100) NULL,
    akriti NVARCHAR(100) NULL,
    recorded_at DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_ashta_patient FOREIGN KEY (patient_id) REFERENCES dbo.patients(patient_id) ,
    CONSTRAINT FK_ashta_encounter FOREIGN KEY (encounter_id) REFERENCES dbo.patient_encounters(encounter_id) 
);
CREATE INDEX IX_ashtavidha_pariksha_encounter ON dbo.ashtavidha_pariksha(encounter_id);
GO

-- Physical Examination
CREATE TABLE dbo.physical_examination (
    physical_exam_id INT IDENTITY(1,1) PRIMARY KEY,
    patient_id INT NOT NULL,
    encounter_id INT NOT NULL,
    general_appearance NVARCHAR(MAX) NULL,
    built NVARCHAR(20) NULL CHECK (built IN (N'Thin', N'Medium', N'Obese')),
    nourishment NVARCHAR(30) NULL CHECK (nourishment IN (N'Well_nourished', N'Moderately_nourished', N'Poorly_nourished')),
    pallor NVARCHAR(10) NULL CHECK (pallor IN (N'Present', N'Absent')),
    icterus NVARCHAR(10) NULL CHECK (icterus IN (N'Present', N'Absent')),
    cyanosis NVARCHAR(10) NULL CHECK (cyanosis IN (N'Present', N'Absent')),
    clubbing NVARCHAR(10) NULL CHECK (clubbing IN (N'Present', N'Absent')),
    lymphadenopathy NVARCHAR(10) NULL CHECK (lymphadenopathy IN (N'Present', N'Absent')),
    edema NVARCHAR(10) NULL CHECK (edema IN (N'Present', N'Absent')),
    skin_examination NVARCHAR(MAX) NULL,
    systemic_examination NVARCHAR(MAX) NULL,
    recorded_at DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_phys_exam_patient FOREIGN KEY (patient_id) REFERENCES dbo.patients(patient_id) ,
    CONSTRAINT FK_phys_exam_encounter FOREIGN KEY (encounter_id) REFERENCES dbo.patient_encounters(encounter_id) 
);
CREATE INDEX IX_physical_examination_encounter ON dbo.physical_examination(encounter_id);
GO

-- Encounter Diagnosis
CREATE TABLE dbo.encounter_diagnosis (
    diagnosis_id INT IDENTITY(1,1) PRIMARY KEY,
    encounter_id INT NOT NULL,
    patient_id INT NOT NULL,
    roga_name NVARCHAR(255) NOT NULL,
    ayurvedic_diagnosis NVARCHAR(MAX) NULL,
    modern_diagnosis NVARCHAR(MAX) NULL,
    diagnosis_type NVARCHAR(30) NULL CHECK (diagnosis_type IN (N'Primary', N'Secondary', N'Differential', N'Provisional', N'Final')),
    dosha_involved NVARCHAR(100) NULL,
    dushya NVARCHAR(100) NULL,
    srotas NVARCHAR(100) NULL,
    avastha NVARCHAR(100) NULL,
    notes NVARCHAR(MAX) NULL,
    diagnosis_date DATE NULL,
    CONSTRAINT FK_diagnosis_patient FOREIGN KEY (patient_id) REFERENCES dbo.patients(patient_id) ,
    CONSTRAINT FK_diagnosis_encounter FOREIGN KEY (encounter_id) REFERENCES dbo.patient_encounters(encounter_id) 
);
CREATE INDEX IX_encounter_diagnosis_encounter ON dbo.encounter_diagnosis(encounter_id);
GO

-- Encounter Notes
CREATE TABLE dbo.encounter_notes (
    note_id INT IDENTITY(1,1) PRIMARY KEY,
    encounter_id INT NOT NULL,
    patient_id INT NOT NULL,
    note_type NVARCHAR(50) NULL CHECK (note_type IN (N'Clinical_notes', N'Follow_up_notes', N'Progress_notes', N'Doctor_observations', N'Dietitian_notes', N'Therapist_notes')),
    note_text NVARCHAR(MAX) NOT NULL,
    created_by INT NULL,
    created_at DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_notes_patient FOREIGN KEY (patient_id) REFERENCES dbo.patients(patient_id) ,
    CONSTRAINT FK_notes_encounter FOREIGN KEY (encounter_id) REFERENCES dbo.patient_encounters(encounter_id) 
);
CREATE INDEX IX_encounter_notes_encounter ON dbo.encounter_notes(encounter_id);
GO

--Encounter Prescriptions
CREATE TABLE dbo.encounter_prescriptions (
    prescription_id INT IDENTITY(1,1) PRIMARY KEY,
    encounter_id    INT NOT NULL,
    patient_id      INT NOT NULL,
    medicine_name   NVARCHAR(255) NOT NULL,
    medicine_type   NVARCHAR(30) NULL
                    CHECK (medicine_type IN (
                        N'Classical_Ayurvedic',
                        N'Patent_Ayurvedic',
                        N'Herbal',
                        N'Modern',
                        N'Other'
                    )),
    dosage          NVARCHAR(100) NULL,
    anupana         NVARCHAR(100) NULL,
    frequency       NVARCHAR(100) NULL,
    timing          NVARCHAR(100) NULL,
    duration        NVARCHAR(100) NULL,
    quantity        NVARCHAR(50)  NULL,
    instructions    NVARCHAR(MAX) NULL,
    created_at      DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at      DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    created_by      INT NULL,
    updated_by      INT NULL,

    CONSTRAINT FK_ep_patient
        FOREIGN KEY (patient_id)
        REFERENCES dbo.patients(patient_id)
        ON DELETE CASCADE,

    CONSTRAINT FK_ep_encounter
        FOREIGN KEY (encounter_id)
        REFERENCES dbo.patient_encounters(encounter_id)
        ON DELETE CASCADE
);

-- Index for encounter-based prescription lookups
CREATE INDEX IX_encounter_prescriptions_encounter
    ON dbo.encounter_prescriptions (encounter_id);
GO


--Encounter treatment plan
CREATE TABLE encounter_treatment_plan (
    treatment_plan_id INT IDENTITY(1,1) PRIMARY KEY,
    encounter_id      INT NOT NULL,
    patient_id        INT NOT NULL,
    treatment_category NVARCHAR(50) NULL
                       CHECK (treatment_category IN (
                           'Shodhana',
                           'Shamana',
                           'Panchkarma',
                           'Pathya',
                           'Lifestyle_modification',
                           'Dietary_changes',
                           'Yoga'
                       )),
    treatment_name    NVARCHAR(255),
    treatment_details NVARCHAR(MAX),
    duration          NVARCHAR(100),
    frequency         NVARCHAR(100),
    instructions      NVARCHAR(MAX),

    CONSTRAINT FK_etp_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id)
        ON DELETE CASCADE,

    CONSTRAINT FK_etp_encounter
        FOREIGN KEY (encounter_id)
        REFERENCES patient_encounters(encounter_id)
        ON DELETE CASCADE
);

--panchakarma procedure
CREATE TABLE panchkarma_procedures (
    procedure_id   INT IDENTITY(1,1) PRIMARY KEY,
    encounter_id   INT NOT NULL,
    patient_id     INT NOT NULL,
    procedure_name NVARCHAR(255) NOT NULL,
    procedure_type NVARCHAR(50)  NULL
                   CHECK (procedure_type IN (
                       'Vamana',
                       'Virechana',
                       'Basti',
                       'Nasya',
                       'Raktamokshana',
                       'Snehana',
                       'Swedana',
                       'Other'
                   )),
    procedure_date DATE,
    duration       NVARCHAR(100),
    materials_used NVARCHAR(MAX),
    observations   NVARCHAR(MAX),
    result         NVARCHAR(MAX),
    performed_by   NVARCHAR(255),

    CONSTRAINT FK_pkp_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id)
        ON DELETE CASCADE,

    CONSTRAINT FK_pkp_encounter
        FOREIGN KEY (encounter_id)
        REFERENCES patient_encounters(encounter_id)
        ON DELETE CASCADE
);


CREATE TABLE investigations (
    investigation_id  INT IDENTITY(1,1) PRIMARY KEY,
    patient_id        INT NOT NULL,
    encounter_id      INT NOT NULL,
    test_category     NVARCHAR(100),
    test_name         NVARCHAR(255) NOT NULL,
    test_date         DATE,
    result            NVARCHAR(MAX),
    normal_range      NVARCHAR(100),
    unit              NVARCHAR(50),
    abnormal_flag     NVARCHAR(20) NULL
                      CHECK (abnormal_flag IN (
                          'Normal',
                          'High',
                          'Low',
                          'Critical'
                      )),
    remarks           NVARCHAR(MAX),
    report_file_path  NVARCHAR(500),
    lab_name          NVARCHAR(255),
    recorded_at       DATETIME2 DEFAULT GETDATE(),

    CONSTRAINT FK_inv_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id)
        ON DELETE CASCADE,

    CONSTRAINT FK_inv_encounter
        FOREIGN KEY (encounter_id)
        REFERENCES patient_encounters(encounter_id)
        ON DELETE CASCADE
);


CREATE TABLE follow_up_schedule (
    followup_id     INT IDENTITY(1,1) PRIMARY KEY,
    encounter_id    INT NOT NULL,
    patient_id      INT NOT NULL,
    followup_date   DATE NOT NULL,
    followup_reason NVARCHAR(MAX),
    status          NVARCHAR(20) NOT NULL DEFAULT 'Scheduled'
                    CHECK (status IN (
                        'Scheduled',
                        'Completed',
                        'Cancelled',
                        'Rescheduled'
                    )),
    reminder_sent   BIT NOT NULL DEFAULT 0,
    notes           NVARCHAR(MAX),

    CONSTRAINT FK_fus_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id)
        ON DELETE CASCADE,

    CONSTRAINT FK_fus_encounter
        FOREIGN KEY (encounter_id)
        REFERENCES patient_encounters(encounter_id)
        ON DELETE CASCADE
);



CREATE TABLE medicines_master (
    medicine_id        INT IDENTITY(1,1) PRIMARY KEY,
    medicine_name      NVARCHAR(255) NOT NULL,
    medicine_category  NVARCHAR(100),
    manufacturer       NVARCHAR(255),
    composition        NVARCHAR(MAX),
    standard_dosage    NVARCHAR(100),
    form               NVARCHAR(50) NULL
                       CHECK (form IN (
                           'Tablet',
                           'Capsule',
                           'Syrup',
                           'Powder',
                           'Oil',
                           'Ghrita',
                           'Asava_Arishta',
                           'Churna',
                           'Vati',
                           'Kwatha',
                           'Other'
                       )),
    shelf_life_months  INT,
    storage_conditions NVARCHAR(MAX),
    is_active          BIT NOT NULL DEFAULT 1,

    CONSTRAINT CHK_shelf_life
        CHECK (shelf_life_months > 0)
);



CREATE TABLE dbo.audit_log (
    log_id      INT IDENTITY(1,1) PRIMARY KEY,
    table_name  NVARCHAR(100) NOT NULL,
    record_id   INT NOT NULL,
    action_type NVARCHAR(10) NOT NULL
                CHECK (action_type IN (
                    N'INSERT',
                    N'UPDATE',
                    N'DELETE'
                )),
    changed_by  INT NULL,
    changed_at  DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    old_values  NVARCHAR(MAX) NULL,     -- JSON stored as NVARCHAR(MAX)
    new_values  NVARCHAR(MAX) NULL,     -- JSON stored as NVARCHAR(MAX)
    ip_address  NVARCHAR(50) NULL,

    CONSTRAINT FK_audit_changed_by
        FOREIGN KEY (changed_by)
        REFERENCES dbo.staff(staff_id),

    CONSTRAINT CHK_audit_json_old
        CHECK (old_values IS NULL OR ISJSON(old_values) = 1),

    CONSTRAINT CHK_audit_json_new
        CHECK (new_values IS NULL OR ISJSON(new_values) = 1)
);



CREATE TABLE appointments (
    appointment_id           INT IDENTITY(1,1) PRIMARY KEY,
    patient_id               INT NOT NULL,
    doctor_id                INT NOT NULL,
    appointment_date         DATE NOT NULL,
    appointment_time         TIME NOT NULL,
    end_time                 TIME,
    appointment_type         NVARCHAR(50) NOT NULL
                             CHECK (appointment_type IN (
                                 'New_consultation',
                                 'Follow_up',
                                 'Panchkarma_session',
                                 'Emergency',
                                 'Routine_checkup',
                                 'Panchakarma_therapy',
                                 'Consultation_only'
                             )),
    duration_minutes         INT DEFAULT 30,
    reason_for_visit         NVARCHAR(MAX),
    chief_complaint          NVARCHAR(500),
    appointment_status       NVARCHAR(20) NOT NULL DEFAULT 'Scheduled'
                             CHECK (appointment_status IN (
                                 'Scheduled',
                                 'Confirmed',
                                 'In_progress',
                                 'Completed',
                                 'Cancelled',
                                 'No_show',
                                 'Rescheduled'
                             )),
    booking_channel          NVARCHAR(20) NULL
                             CHECK (booking_channel IN (
                                 'Phone',
                                 'Walk_in',
                                 'Online',
                                 'Mobile_app',
                                 'Referral',
                                 'WhatsApp'
                             )),
    booking_date             DATETIME2 DEFAULT GETDATE(),
    booked_by                NVARCHAR(100),
    priority                 NVARCHAR(20) NOT NULL DEFAULT 'Normal'
                             CHECK (priority IN (
                                 'Normal',
                                 'Urgent',
                                 'Emergency'
                             )),
    special_requirements     NVARCHAR(MAX),
    requires_fasting         BIT NOT NULL DEFAULT 0,
    requires_preparation     BIT NOT NULL DEFAULT 0,
    preparation_instructions NVARCHAR(MAX),
    contact_phone            NVARCHAR(15),
    contact_email            NVARCHAR(255),
    reminder_sent            BIT NOT NULL DEFAULT 0,
    reminder_sent_at         DATETIME2 NULL,
    cancellation_reason      NVARCHAR(MAX),
    cancelled_by             NVARCHAR(20) NULL
                             CHECK (cancelled_by IN (
                                 'Patient',
                                 'Doctor',
                                 'Admin',
                                 'System'
                             )),
    cancellation_date        DATETIME2 NULL,
    consultation_fee         DECIMAL(10,2),
    payment_status           NVARCHAR(20) NOT NULL DEFAULT 'Pending'
                             CHECK (payment_status IN (
                                 'Pending',
                                 'Paid',
                                 'Partially_paid',
                                 'Refunded'
                             )),
    internal_notes           NVARCHAR(MAX),
    doctor_notes             NVARCHAR(MAX),
    created_at               DATETIME2 DEFAULT GETDATE(),
    created_by               INT,
    updated_at               DATETIME2 DEFAULT GETDATE(),
    updated_by               INT,

    CONSTRAINT FK_apt_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id)
        ON DELETE CASCADE,

    CONSTRAINT FK_apt_doctor
        FOREIGN KEY (doctor_id)
        REFERENCES doctors(doctor_id)
        ON DELETE CASCADE,

    CONSTRAINT CHK_duration
        CHECK (duration_minutes > 0),

    CONSTRAINT CHK_end_time
        CHECK (end_time > appointment_time)
);

CREATE TABLE dbo.doctors (
    doctor_id           INT IDENTITY(1,1) PRIMARY KEY,
    doctor_name         NVARCHAR(255) NOT NULL,
    qualification       NVARCHAR(255) NULL,
    specialization      NVARCHAR(255) NULL,
    registration_number NVARCHAR(100) NULL,
    phone               NVARCHAR(15)  NULL,
    email               NVARCHAR(255) NULL,
    consultation_fee    DECIMAL(10,2) NULL,
    is_active           BIT NOT NULL DEFAULT 1,
    created_at          DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT UQ_doctor_registration
        UNIQUE (registration_number),

    CONSTRAINT CHK_doctor_fee
        CHECK (consultation_fee >= 0)
);

-- Index for doctor name lookups
CREATE INDEX IX_doctors_name
    ON dbo.doctors (doctor_name);
GO


CREATE TABLE doctor_schedule (
    schedule_id            INT IDENTITY(1,1) PRIMARY KEY,
    doctor_id              INT NOT NULL,
    day_of_week            NVARCHAR(10) NOT NULL
                           CHECK (day_of_week IN (
                               'Monday',
                               'Tuesday',
                               'Wednesday',
                               'Thursday',
                               'Friday',
                               'Saturday',
                               'Sunday'
                           )),
    start_time             TIME NOT NULL,
    end_time               TIME NOT NULL,
    slot_duration_minutes  INT DEFAULT 30,
    max_patients_per_slot  INT DEFAULT 1,
    is_active              BIT NOT NULL DEFAULT 1,
    effective_from         DATE,
    effective_to           DATE,

    CONSTRAINT FK_ds_doctor
        FOREIGN KEY (doctor_id)
        REFERENCES doctors(doctor_id)
        ON DELETE CASCADE,

    CONSTRAINT CHK_schedule_times
        CHECK (end_time > start_time),

    CONSTRAINT CHK_slot_duration
        CHECK (slot_duration_minutes > 0),

    CONSTRAINT CHK_max_patients
        CHECK (max_patients_per_slot > 0),

    CONSTRAINT CHK_effective_dates
        CHECK (effective_to IS NULL OR effective_to >= effective_from)
);



CREATE TABLE appointment_slots (
    slot_id      INT IDENTITY(1,1) PRIMARY KEY,
    doctor_id    INT NOT NULL,
    slot_date    DATE NOT NULL,
    slot_time    TIME NOT NULL,
    is_available BIT NOT NULL DEFAULT 1,
    is_blocked   BIT NOT NULL DEFAULT 0,
    block_reason NVARCHAR(255),

    CONSTRAINT FK_as_doctor
        FOREIGN KEY (doctor_id)
        REFERENCES doctors(doctor_id)
        ON DELETE CASCADE,

    CONSTRAINT UQ_unique_slot
        UNIQUE (doctor_id, slot_date, slot_time)
);


CREATE TABLE appointment_reminders (
    reminder_id       INT IDENTITY(1,1) PRIMARY KEY,
    appointment_id    INT NOT NULL,
    reminder_type     NVARCHAR(20) NOT NULL
                      CHECK (reminder_type IN (
                          'SMS',
                          'Email',
                          'WhatsApp',
                          'Phone_call'
                      )),
    reminder_schedule NVARCHAR(20) NULL
                      CHECK (reminder_schedule IN (
                          '24_hours_before',
                          '2_hours_before',
                          '1_day_before',
                          'Custom'
                      )),
    scheduled_time    DATETIME2 NOT NULL,
    sent_status       NVARCHAR(20) NOT NULL DEFAULT 'Pending'
                      CHECK (sent_status IN (
                          'Pending',
                          'Sent',
                          'Failed',
                          'Cancelled'
                      )),
    sent_at           DATETIME2 NULL,

    CONSTRAINT FK_ar_appointment
        FOREIGN KEY (appointment_id)
        REFERENCES appointments(appointment_id)
        ON DELETE CASCADE,

    CONSTRAINT CHK_sent_at
        CHECK (sent_at IS NULL OR sent_at >= scheduled_time)
);




CREATE TABLE appointment_history (
    history_id          INT IDENTITY(1,1) PRIMARY KEY,
    appointment_id      INT NOT NULL,
    action_type         NVARCHAR(20) NULL
                        CHECK (action_type IN (
                            'Created',
                            'Confirmed',
                            'Cancelled',
                            'Rescheduled',
                            'Completed',
                            'No_show'
                        )),
    old_date            DATE,
    old_time            TIME,
    new_date            DATE,
    new_time            TIME,
    cancellation_reason NVARCHAR(MAX),
    cancelled_by        NVARCHAR(20) NULL
                        CHECK (cancelled_by IN (
                            'Patient',
                            'Doctor',
                            'Admin',
                            'System'
                        )),
    action_timestamp    DATETIME2 DEFAULT GETDATE(),
    notes               NVARCHAR(MAX),

    CONSTRAINT FK_ah_appointment
        FOREIGN KEY (appointment_id)
        REFERENCES appointments(appointment_id)
        ON DELETE CASCADE,

    CONSTRAINT CHK_ah_reschedule_dates
        CHECK (
            action_type <> 'Rescheduled'
            OR (old_date IS NOT NULL AND new_date IS NOT NULL)
        ),

    CONSTRAINT CHK_ah_cancel_reason
        CHECK (
            action_type <> 'Cancelled'
            OR cancelled_by IS NOT NULL
        )
);


-- =========================================================
-- BILLING MODULE
-- =========================================================

CREATE TABLE dbo.bills (
    bill_id             INT IDENTITY(1,1) PRIMARY KEY,
    bill_number         NVARCHAR(50) NOT NULL UNIQUE,   -- e.g. BILL-2026-00001
    patient_id          INT NOT NULL,
    encounter_id        INT NULL,                        -- NULL for direct billing
    appointment_id      INT NULL,                        -- NULL for walk-in billing
    bill_date           DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    bill_type           NVARCHAR(30) NOT NULL DEFAULT 'OPD'
                        CHECK (bill_type IN (
                            'OPD',
                            'IPD',
                            'Panchkarma',
                            'Investigation',
                            'Pharmacy',
                            'Mixed'
                        )),
    subtotal            DECIMAL(10,2) NOT NULL DEFAULT 0,
    discount_type       NVARCHAR(20) NULL
                        CHECK (discount_type IN ('Flat', 'Percentage', 'None')),
    discount_value      DECIMAL(10,2) NOT NULL DEFAULT 0,
    discount_amount     DECIMAL(10,2) NOT NULL DEFAULT 0,
    tax_amount          DECIMAL(10,2) NOT NULL DEFAULT 0,
    total_amount        DECIMAL(10,2) NOT NULL DEFAULT 0,
    paid_amount         DECIMAL(10,2) NOT NULL DEFAULT 0,
    balance_due         DECIMAL(10,2) NOT NULL DEFAULT 0,
    bill_status         NVARCHAR(20) NOT NULL DEFAULT 'Draft'
                        CHECK (bill_status IN (
                            'Draft',
                            'Generated',
                            'Partially_paid',
                            'Paid',
                            'Cancelled',
                            'Refunded'
                        )),
    notes               NVARCHAR(MAX) NULL,
    created_at          DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at          DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    created_by          INT NULL,
    updated_by          INT NULL,

    CONSTRAINT FK_bill_patient
        FOREIGN KEY (patient_id)
        REFERENCES dbo.patients(patient_id),

    CONSTRAINT FK_bill_encounter
        FOREIGN KEY (encounter_id)
        REFERENCES dbo.patient_encounters(encounter_id),

    CONSTRAINT FK_bill_appointment
        FOREIGN KEY (appointment_id)
        REFERENCES dbo.appointments(appointment_id),

    CONSTRAINT CHK_bill_amounts
        CHECK (subtotal >= 0 AND discount_amount >= 0
               AND tax_amount >= 0 AND total_amount >= 0
               AND paid_amount >= 0 AND balance_due >= 0)
);


CREATE TABLE dbo.bill_items (
    item_id             INT IDENTITY(1,1) PRIMARY KEY,
    bill_id             INT NOT NULL,
    item_type           NVARCHAR(30) NOT NULL
                        CHECK (item_type IN (
                            'Consultation',
                            'Medicine',
                            'Panchkarma_procedure',
                            'Investigation',
                            'Service',
                            'Other'
                        )),
    item_description    NVARCHAR(255) NOT NULL,
    medicine_id         INT NULL,           -- FK to medicines_master if item_type = 'Medicine'
    quantity            DECIMAL(10,3) NOT NULL DEFAULT 1,
    unit                NVARCHAR(50) NULL,  -- e.g. 'Tablet', 'ml', 'Session'
    unit_price          DECIMAL(10,2) NOT NULL,
    discount_percent    DECIMAL(5,2) NOT NULL DEFAULT 0,
    tax_percent         DECIMAL(5,2) NOT NULL DEFAULT 0,
    line_total          DECIMAL(10,2) NOT NULL,

    CONSTRAINT FK_bill_item_bill
        FOREIGN KEY (bill_id)
        REFERENCES dbo.bills(bill_id)
        ON DELETE CASCADE,

    CONSTRAINT FK_bill_item_medicine
        FOREIGN KEY (medicine_id)
        REFERENCES dbo.medicines_master(medicine_id),

    CONSTRAINT CHK_bill_item_qty
        CHECK (quantity > 0),

    CONSTRAINT CHK_bill_item_price
        CHECK (unit_price >= 0 AND line_total >= 0)
);



CREATE TABLE dbo.payments (
    payment_id          INT IDENTITY(1,1) PRIMARY KEY,
    payment_number      NVARCHAR(50) NOT NULL UNIQUE,   -- e.g. PAY-2026-00001
    bill_id             INT NOT NULL,
    patient_id          INT NOT NULL,
    payment_date        DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    amount              DECIMAL(10,2) NOT NULL,
    payment_mode        NVARCHAR(30) NOT NULL
                        CHECK (payment_mode IN (
                            'Cash',
                            'UPI',
                            'Card',
                            'Net_banking',
                            'Cheque',
                            'Online',
                            'Wallet'
                        )),
    transaction_ref     NVARCHAR(100) NULL,     -- UPI TxnID / Cheque no.
    payment_status      NVARCHAR(20) NOT NULL DEFAULT 'Completed'
                        CHECK (payment_status IN (
                            'Completed',
                            'Pending',
                            'Failed',
                            'Refunded'
                        )),
    remarks             NVARCHAR(500) NULL,
    created_at          DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    created_by          INT NULL,

    CONSTRAINT FK_payment_bill
        FOREIGN KEY (bill_id)
        REFERENCES dbo.bills(bill_id),

    CONSTRAINT FK_payment_patient
        FOREIGN KEY (patient_id)
        REFERENCES dbo.patients(patient_id),

    CONSTRAINT CHK_payment_amount
        CHECK (amount > 0)
);


CREATE TABLE dbo.refunds (
    refund_id           INT IDENTITY(1,1) PRIMARY KEY,
    payment_id          INT NOT NULL,
    bill_id             INT NOT NULL,
    patient_id          INT NOT NULL,
    refund_date         DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    refund_amount       DECIMAL(10,2) NOT NULL,
    refund_mode         NVARCHAR(30) NOT NULL
                        CHECK (refund_mode IN (
                            'Cash', 'UPI', 'Card',
                            'Net_banking', 'Cheque', 'Wallet'
                        )),
    refund_reason       NVARCHAR(MAX) NULL,
    refund_status       NVARCHAR(20) NOT NULL DEFAULT 'Processed'
                        CHECK (refund_status IN (
                            'Processed', 'Pending', 'Failed'
                        )),
    created_at          DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    created_by          INT NULL,

    CONSTRAINT FK_refund_payment
        FOREIGN KEY (payment_id)
        REFERENCES dbo.payments(payment_id),

    CONSTRAINT FK_refund_bill
        FOREIGN KEY (bill_id)
        REFERENCES dbo.bills(bill_id),

    CONSTRAINT FK_refund_patient
        FOREIGN KEY (patient_id)
        REFERENCES dbo.patients(patient_id),

    CONSTRAINT CHK_refund_amount
        CHECK (refund_amount > 0)
);


-- =========================================================
-- INVENTORY MODULE
-- =========================================================

CREATE TABLE dbo.inventory (
    inventory_id        INT IDENTITY(1,1) PRIMARY KEY,
    medicine_id         INT NOT NULL,
    batch_number        NVARCHAR(100) NOT NULL,
    manufacture_date    DATE NULL,
    expiry_date         DATE NOT NULL,
    quantity_received   DECIMAL(10,3) NOT NULL,
    quantity_available  DECIMAL(10,3) NOT NULL,
    quantity_unit       NVARCHAR(50) NOT NULL,   -- e.g. 'Tablets', 'ml', 'gm'
    purchase_price      DECIMAL(10,2) NOT NULL,
    selling_price       DECIMAL(10,2) NOT NULL,
    mrp                 DECIMAL(10,2) NULL,
    supplier_id         INT NULL,                -- FK to suppliers
    location            NVARCHAR(100) NULL,      -- Shelf / rack location
    is_active           BIT NOT NULL DEFAULT 1,
    created_at          DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at          DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    created_by          INT NULL,

    CONSTRAINT FK_inv_medicine
        FOREIGN KEY (medicine_id)
        REFERENCES dbo.medicines_master(medicine_id),

    CONSTRAINT UQ_inventory_batch
        UNIQUE (medicine_id, batch_number),

    CONSTRAINT CHK_inv_expiry
        CHECK (expiry_date > manufacture_date OR manufacture_date IS NULL),

    CONSTRAINT CHK_inv_qty
        CHECK (quantity_received > 0 AND quantity_available >= 0),

    CONSTRAINT CHK_inv_price
        CHECK (purchase_price >= 0 AND selling_price >= 0)
);



CREATE TABLE dbo.suppliers (
    supplier_id         INT IDENTITY(1,1) PRIMARY KEY,
    supplier_name       NVARCHAR(255) NOT NULL,
    contact_person      NVARCHAR(255) NULL,
    phone               NVARCHAR(15) NULL,
    email               NVARCHAR(255) NULL,
    address             NVARCHAR(MAX) NULL,
    gst_number          NVARCHAR(20) NULL,
    drug_license_number NVARCHAR(50) NULL,
    is_active           BIT NOT NULL DEFAULT 1,
    created_at          DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME()
);

-- Add FK from inventory to suppliers
ALTER TABLE dbo.inventory
    ADD CONSTRAINT FK_inv_supplier
    FOREIGN KEY (supplier_id)
    REFERENCES dbo.suppliers(supplier_id);




CREATE TABLE dbo.purchase_orders (
    po_id               INT IDENTITY(1,1) PRIMARY KEY,
    po_number           NVARCHAR(50) NOT NULL UNIQUE,   -- e.g. PO-2026-00001
    supplier_id         INT NOT NULL,
    order_date          DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    expected_delivery   DATE NULL,
    po_status           NVARCHAR(20) NOT NULL DEFAULT 'Draft'
                        CHECK (po_status IN (
                            'Draft',
                            'Sent',
                            'Partially_received',
                            'Received',
                            'Cancelled'
                        )),
    total_amount        DECIMAL(10,2) NOT NULL DEFAULT 0,
    notes               NVARCHAR(MAX) NULL,
    created_at          DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at          DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    created_by          INT NULL,

    CONSTRAINT FK_po_supplier
        FOREIGN KEY (supplier_id)
        REFERENCES dbo.suppliers(supplier_id)
);


CREATE TABLE dbo.purchase_order_items (
    po_item_id          INT IDENTITY(1,1) PRIMARY KEY,
    po_id               INT NOT NULL,
    medicine_id         INT NOT NULL,
    ordered_quantity    DECIMAL(10,3) NOT NULL,
    received_quantity   DECIMAL(10,3) NOT NULL DEFAULT 0,
    unit                NVARCHAR(50) NOT NULL,
    unit_price          DECIMAL(10,2) NOT NULL,
    line_total          DECIMAL(10,2) NOT NULL,

    CONSTRAINT FK_poi_po
        FOREIGN KEY (po_id)
        REFERENCES dbo.purchase_orders(po_id)
        ON DELETE CASCADE,

    CONSTRAINT FK_poi_medicine
        FOREIGN KEY (medicine_id)
        REFERENCES dbo.medicines_master(medicine_id),

    CONSTRAINT CHK_poi_qty
        CHECK (ordered_quantity > 0 AND received_quantity >= 0)
);


CREATE TABLE dbo.stock_transactions (
    txn_id              INT IDENTITY(1,1) PRIMARY KEY,
    inventory_id        INT NOT NULL,
    medicine_id         INT NOT NULL,
    txn_type            NVARCHAR(20) NOT NULL
                        CHECK (txn_type IN (
                            'Purchase',       -- Stock in from PO
                            'Dispensed',      -- Issued to patient via bill
                            'Adjustment',     -- Manual correction
                            'Expired',        -- Removed due to expiry
                            'Return_to_supplier',
                            'Return_from_patient',
                            'Opening_stock'
                        )),
    quantity_change     DECIMAL(10,3) NOT NULL,   -- Positive = stock in, Negative = stock out
    quantity_before     DECIMAL(10,3) NOT NULL,
    quantity_after      DECIMAL(10,3) NOT NULL,
    reference_type      NVARCHAR(30) NULL
                        CHECK (reference_type IN (
                            'Bill', 'Purchase_order',
                            'Manual', 'Expiry_removal'
                        )),
    reference_id        INT NULL,       -- bill_id or po_id
    remarks             NVARCHAR(500) NULL,
    txn_date            DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    created_by          INT NULL,

    CONSTRAINT FK_stxn_inventory
        FOREIGN KEY (inventory_id)
        REFERENCES dbo.inventory(inventory_id),

    CONSTRAINT FK_stxn_medicine
        FOREIGN KEY (medicine_id)
        REFERENCES dbo.medicines_master(medicine_id)
);



CREATE TABLE dbo.stock_alerts (
    alert_id            INT IDENTITY(1,1) PRIMARY KEY,
    medicine_id         INT NOT NULL,
    inventory_id        INT NULL,
    alert_type          NVARCHAR(30) NOT NULL
                        CHECK (alert_type IN (
                            'Low_stock',
                            'Out_of_stock',
                            'Near_expiry',      -- Within 90 days
                            'Expired'
                        )),
    alert_message       NVARCHAR(500) NULL,
    is_resolved         BIT NOT NULL DEFAULT 0,
    resolved_at         DATETIME2(0) NULL,
    created_at          DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT FK_alert_medicine
        FOREIGN KEY (medicine_id)
        REFERENCES dbo.medicines_master(medicine_id),

    CONSTRAINT FK_alert_inventory
        FOREIGN KEY (inventory_id)
        REFERENCES dbo.inventory(inventory_id)
);








CREATE INDEX IX_stock_alerts_unresolved
    ON dbo.stock_alerts (medicine_id, alert_type)
    WHERE is_resolved = 0;    -- Filtered index for active alerts only
GO











CREATE INDEX IX_stxn_inventory ON dbo.stock_transactions (inventory_id, txn_date);
CREATE INDEX IX_stxn_medicine  ON dbo.stock_transactions (medicine_id, txn_date);
CREATE INDEX IX_stxn_type      ON dbo.stock_transactions (txn_type, txn_date);
GO




CREATE INDEX IX_poi_po ON dbo.purchase_order_items (po_id);
GO











CREATE INDEX IX_suppliers_name ON dbo.suppliers (supplier_name);
GO


CREATE INDEX IX_po_supplier ON dbo.purchase_orders (supplier_id, order_date);
CREATE INDEX IX_po_status   ON dbo.purchase_orders (po_status, order_date);
GO



















CREATE INDEX IX_inventory_medicine    ON dbo.inventory (medicine_id);
CREATE INDEX IX_inventory_expiry      ON dbo.inventory (expiry_date);   -- For expiry alerts
CREATE INDEX IX_inventory_available   ON dbo.inventory (medicine_id, quantity_available);
GO














CREATE INDEX IX_refunds_bill ON dbo.refunds (bill_id);
GO


















CREATE INDEX IX_payments_bill      ON dbo.payments (bill_id);
CREATE INDEX IX_payments_patient   ON dbo.payments (patient_id, payment_date);
CREATE INDEX IX_payments_mode_date ON dbo.payments (payment_mode, payment_date);
GO















CREATE INDEX IX_bill_items_bill ON dbo.bill_items (bill_id);
GO














CREATE INDEX IX_bills_patient     ON dbo.bills (patient_id, bill_date);
CREATE INDEX IX_bills_status      ON dbo.bills (bill_status, bill_date);
CREATE INDEX IX_bills_encounter   ON dbo.bills (encounter_id);
GO










































-- Composite index for appointment timeline queries
CREATE INDEX idx_appointment_history
    ON appointment_history (appointment_id, action_timestamp);










-- Composite index for pending reminder dispatch queries
CREATE INDEX idx_pending_reminders
    ON appointment_reminders (scheduled_time, sent_status);








-- Filtered index for available slot lookups
CREATE INDEX idx_available_slots
    ON appointment_slots (doctor_id, slot_date, is_available);









-- Composite index for doctor availability lookups by day
CREATE INDEX idx_doctor_day
    ON doctor_schedule (doctor_id, day_of_week);














-- Composite index for date + time scheduling queries
CREATE INDEX idx_appointment_date
    ON appointments (appointment_date, appointment_time);

-- Index for patient appointment history
CREATE INDEX idx_patient_appointments
    ON appointments (patient_id, appointment_date);

-- Index for doctor's daily schedule
CREATE INDEX idx_doctor_schedule
    ON appointments (doctor_id, appointment_date, appointment_time);

-- Index for status-based filtering
CREATE INDEX idx_appointment_status
    ON appointments (appointment_status, appointment_date);

-- Index for booking date tracking
CREATE INDEX idx_booking_date
    ON appointments (booking_date);












































-- Composite index for table + record lookups
CREATE INDEX idx_audit_table
    ON audit_log (table_name, record_id);

-- Index for date-range audit queries
CREATE INDEX idx_audit_date
    ON audit_log (changed_at);
















CREATE INDEX idx_medicine_name
    ON medicines_master (medicine_name);







-- Index for medicine name lookups
CREATE INDEX idx_medicine_name
    ON medicines_master (medicine_name);











-- Index for date-based follow-up lookups
CREATE INDEX idx_followup_date
    ON follow_up_schedule (followup_date);

-- Composite index for patient-specific follow-up queries
CREATE INDEX idx_patient_followup
    ON follow_up_schedule (patient_id, followup_date);










-- Indexes for encounter and date-based lookups
CREATE INDEX idx_encounter_investigations
    ON investigations (encounter_id);

CREATE INDEX idx_test_date
    ON investigations (test_date);



-- Separate index for encounter lookups
CREATE INDEX idx_encounter_panchkarma
    ON panchkarma_procedures (encounter_id);


-- Separate index for encounter lookups
CREATE INDEX idx_encounter_treatment
    ON encounter_treatment_plan (encounter_id);



-- =========================================================
-- SUMMARY INDEXES FOR PERFORMANCE
-- =========================================================

CREATE INDEX IX_patients_reg_number ON dbo.patients(registration_number);
CREATE INDEX IX_patients_phone ON dbo.patients(phone);
CREATE INDEX IX_patients_is_active ON dbo.patients(is_active);
CREATE INDEX IX_encounters_patient ON dbo.patient_encounters(patient_id);
CREATE INDEX IX_encounters_date ON dbo.patient_encounters(encounter_date);
GO

-- =========================================================
-- SUCCESS MESSAGE
-- =========================================================
PRINT N'Database schema created successfully!';
PRINT N'Total tables created: 26';
PRINT N'Database is ready for use.';
GO
