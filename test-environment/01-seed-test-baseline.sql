/*
    Test-environment baseline data.

    Run against AyurvedicClinicMgmt_Test ONLY. It deletes every patient, visit,
    bill and stock row, so running it against the clinic database would destroy
    it - the guard below refuses to run anywhere but a database whose name ends
    in _Test.

    What it produces is a small, KNOWN world that manual test cases can name:
    fixed people, fixed medicines, fixed appointments. Access-rights
    configuration is left as it is, and repaired where a role has been left
    unusable, so every login can actually sign in.

    Deliberately absent: any patient a test case creates. Names such as
    "Test Patient", "Allergy Test" and "Full Fields" belong to the test run, so
    a reset must remove them.

    Idempotent: it clears and rebuilds, so running it twice gives the same result.
*/
SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;

------------------------------------------------------------------ safety guard
IF DB_NAME() NOT LIKE '%[_]Test'
BEGIN
    DECLARE @here SYSNAME = DB_NAME();
    RAISERROR('REFUSED: this script only runs against a database whose name ends in _Test. Current database is %s.', 16, 1, @here);
    SET NOEXEC ON;
END
GO

------------------------------------------------------------------ 1. clear, children first
DELETE FROM dbo.refunds;
DELETE FROM dbo.payments;
DELETE FROM dbo.bill_items;
DELETE FROM dbo.bills;

DELETE FROM dbo.stock_transactions;
DELETE FROM dbo.stock_alerts;
DELETE FROM dbo.purchase_order_items;
DELETE FROM dbo.purchase_orders;
DELETE FROM dbo.inventory;

DELETE FROM dbo.appointment_therapies;
DELETE FROM dbo.appointment_therapists;
DELETE FROM dbo.panchkarma_sessions;
DELETE FROM dbo.appointment_history;
DELETE FROM dbo.appointment_reminders;
DELETE FROM dbo.appointment_slots;
DELETE FROM dbo.appointments;
DELETE FROM dbo.therapist_slots;
DELETE FROM dbo.therapist_schedule;
DELETE FROM dbo.doctor_schedule;

-- Everything hanging off an encounter.
DELETE FROM dbo.encounter_notes;
DELETE FROM dbo.encounter_diagnosis;
DELETE FROM dbo.encounter_prescriptions;
DELETE FROM dbo.encounter_treatment_plan;
DELETE FROM dbo.panchkarma_procedures;
DELETE FROM dbo.investigation_report_files;
DELETE FROM dbo.investigation_reports;
DELETE FROM dbo.investigations;
DELETE FROM dbo.follow_up_schedule;
DELETE FROM dbo.physical_examination;
DELETE FROM dbo.ashtavidha_pariksha;
DELETE FROM dbo.nadi_pariksha;
DELETE FROM dbo.ayurvedic_examination;
DELETE FROM dbo.mental_health;
DELETE FROM dbo.sensory_details;
DELETE FROM dbo.sleep_patterns;
DELETE FROM dbo.perspiration;
DELETE FROM dbo.urinary_habits;
DELETE FROM dbo.bowel_habits;
DELETE FROM dbo.dietary_habits;
DELETE FROM dbo.daily_routine;
DELETE FROM dbo.visit_complaints;
DELETE FROM dbo.visit_vitals;
DELETE FROM dbo.patient_encounters;

-- Everything hanging off a patient.
DELETE FROM dbo.allergies;
DELETE FROM dbo.addictions;
DELETE FROM dbo.habbits;
DELETE FROM dbo.current_medications;
DELETE FROM dbo.family_medical_history;
DELETE FROM dbo.past_medical_history;
DELETE FROM dbo.reproductive_history;
DELETE FROM dbo.patient_occupation;
DELETE FROM dbo.patients;

DELETE FROM dbo.audit_log;

-- Logins are rebuilt so their passwords are known.
DELETE FROM dbo.refresh_tokens;
DELETE FROM dbo.user_roles;
DELETE FROM dbo.users;

DELETE FROM dbo.medicines_master;
DELETE FROM dbo.suppliers;
DELETE FROM dbo.doctors;
DELETE FROM dbo.staff;
DELETE FROM dbo.panchkarma_therapies;
DELETE FROM dbo.panchkarma_rooms;

------------------------------------------------------------------ 2. predictable ids
-- Test cases refer to patients by name, but predictable ids make a failure far
-- easier to talk about ("patient 1003" rather than "the third one").
DBCC CHECKIDENT ('dbo.patients',          RESEED, 1000) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('dbo.staff',             RESEED, 100)  WITH NO_INFOMSGS;
DBCC CHECKIDENT ('dbo.doctors',           RESEED, 200)  WITH NO_INFOMSGS;
DBCC CHECKIDENT ('dbo.users',             RESEED, 10)   WITH NO_INFOMSGS;
DBCC CHECKIDENT ('dbo.medicines_master',  RESEED, 300)  WITH NO_INFOMSGS;
DBCC CHECKIDENT ('dbo.suppliers',         RESEED, 400)  WITH NO_INFOMSGS;
DBCC CHECKIDENT ('dbo.inventory',         RESEED, 500)  WITH NO_INFOMSGS;
DBCC CHECKIDENT ('dbo.appointments',      RESEED, 600)  WITH NO_INFOMSGS;
DBCC CHECKIDENT ('dbo.panchkarma_therapies', RESEED, 700) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('dbo.panchkarma_rooms',  RESEED, 800)  WITH NO_INFOMSGS;

------------------------------------------------------------------ 3. staff
INSERT INTO dbo.staff (staff_name, staff_type, qualification, specialization, registration_number, mobile, email, gender, is_active)
VALUES
 (N'Anand Kulkarni', N'Doctor',           N'BAMS, MD (Ayurveda)', N'Panchakarma',     N'MH-AY-10241', N'9820011001', N'anand@healandcare.local',  N'Male',   1),
 (N'Bhavna Shah',    N'Assistant Doctor', N'BAMS',                N'General',         N'MH-AY-10242', N'9820011002', N'bhavna@healandcare.local', N'Female', 1),
 (N'Chetan Mehta',   N'Admin',            N'MBA (Healthcare)',    N'Administration',  NULL,           N'9820011003', N'chetan@healandcare.local', N'Male',   1),
 (N'Divya Patel',    N'Receptionist',     N'B.Com',               N'Front Desk',      NULL,           N'9820011004', N'divya@healandcare.local',  N'Female', 1),
 -- Gender matters: a therapist is matched to the patient's sex.
 (N'Esha Joshi',     N'Therapist',        N'Panchakarma Diploma', N'Abhyanga, Basti', NULL,           N'9820011005', N'esha@healandcare.local',   N'Female', 1),
 (N'Farhan Qureshi', N'Therapist',        N'Panchakarma Diploma', N'Abhyanga',        NULL,           N'9820011006', N'farhan@healandcare.local', N'Male',   1);

------------------------------------------------------------------ 4. doctors
INSERT INTO dbo.doctors (doctor_name, qualification, specialization, registration_number, phone, email, consultation_fee, is_active)
VALUES
 (N'Dr Anand Kulkarni', N'BAMS, MD (Ayurveda)', N'Panchakarma',        N'MH-AY-10241', N'9820011001', N'anand@healandcare.local', 500.00, 1),
 (N'Dr Sneha Kulkarni', N'BAMS',                N'General Medicine',   N'MH-AY-10250', N'9820011010', N'sneha@healandcare.local', 400.00, 1);

------------------------------------------------------------------ 5. logins
-- Passwords are the username followed by @123, except admin/admin123.
-- Hashes are PBKDF2-SHA256, 16-byte salt + 20-byte key, matching the API.
DECLARE @staffAnand  INT = (SELECT staff_id FROM dbo.staff WHERE staff_name = N'Anand Kulkarni');
DECLARE @staffBhavna INT = (SELECT staff_id FROM dbo.staff WHERE staff_name = N'Bhavna Shah');
DECLARE @staffChetan INT = (SELECT staff_id FROM dbo.staff WHERE staff_name = N'Chetan Mehta');
DECLARE @staffDivya  INT = (SELECT staff_id FROM dbo.staff WHERE staff_name = N'Divya Patel');
DECLARE @staffEsha   INT = (SELECT staff_id FROM dbo.staff WHERE staff_name = N'Esha Joshi');

INSERT INTO dbo.users (username, email, password_hash, first_name, last_name, staff_id, is_active, is_deleted)
VALUES
 (N'chetan', N'chetan@healandcare.local', N'odh5Hlz8qVDLjmzY76A0SwI6OrpRYlSEqTd1PPRcoB3AXIFY', N'Chetan', N'Mehta',     @staffChetan, 1, 0),
 (N'anand',  N'anand@healandcare.local',  N'HM/GEgVaXKaq8VrtTcpPrYACwkSXUcZbT3v899SmFLun/Cip', N'Anand',  N'Kulkarni',  @staffAnand,  1, 0),
 (N'bhavna', N'bhavna@healandcare.local', N'fgUT7S9Ou85fLY0IsV0JKl2XyMOIcUVDMw9BUCLRoJFT6qNM', N'Bhavna', N'Shah',      @staffBhavna, 1, 0),
 (N'divya',  N'divya@healandcare.local',  N'bTNa/7kccshLO400hOeizrtuJ+NKpsaG+Kh9Bj8VEaHQs7rs', N'Divya',  N'Patel',     @staffDivya,  1, 0),
 (N'esha',   N'esha@healandcare.local',   N'3h9ZXTawCv4YJ5aIkGtyYfXQxxsdA1JjY0UoYCMD5DIuTlRA', N'Esha',   N'Joshi',     @staffEsha,   1, 0),
 (N'admin',  N'admin@healandcare.local',  N'Mx4dpFtlaTPfVejTVVq+PpPD8TNXrdawJriclw0HAmd761up', N'Clinic', N'Administrator', NULL,     1, 0);

INSERT INTO dbo.user_roles (user_id, role_id)
SELECT u.user_id, r.role_id
FROM dbo.users u
JOIN (VALUES (N'chetan', N'Admin'), (N'anand', N'Doctor'), (N'bhavna', N'Assistant Doctor'),
             (N'divya', N'Receptionist'), (N'esha', N'Therapist'), (N'admin', N'Admin')) AS m(username, role_name)
  ON m.username = u.username
JOIN dbo.roles r ON r.role_name = m.role_name;

------------------------------------------------------------------ 6. patients
-- Five people who exist before any test runs. Test cases create their own on top.
INSERT INTO dbo.patients
 (registration_number, first_name, last_name, date_of_birth, gender, phone_country_code, phone,
  email, address_line1, city, state, pincode, country, blood_group, marital_status,
  emergency_contact_name, emergency_contact_phone, emergency_contact_relation,
  registration_date, is_active, history_completed)
VALUES
 (N'REG-T-0001', N'Aarav',  N'Sharma', '1985-04-12', N'Male',   N'+91', N'9870000001', N'aarav.sharma@example.com',  N'14 Model Colony',      N'Pune',   N'Maharashtra', N'411016', N'India', N'B+',  N'Married',   N'Sunita Sharma', N'9870000011', N'Wife',    '2026-01-10', 1, 0),
 (N'REG-T-0002', N'Priya',  N'Nair',   '1992-09-03', N'Female', N'+91', N'9870000002', N'priya.nair@example.com',    N'8 Baner Road',        N'Pune',   N'Maharashtra', N'411045', N'India', N'O+',  N'Unmarried', N'Latha Nair',    N'9870000012', N'Mother',  '2026-02-02', 1, 1),
 -- The third row: PAT-091 checks that opening it shows this patient and not another.
 (N'REG-T-0003', N'Rohan',  N'Desai',  '1978-12-21', N'Male',   N'+91', N'9870000003', N'rohan.desai@example.com',   N'22 FC Road',          N'Pune',   N'Maharashtra', N'411004', N'India', N'A-',  N'Married',   N'Nisha Desai',   N'9870000013', N'Wife',    '2026-02-14', 1, 0),
 (N'REG-T-0004', N'Meera',  N'Iyer',   '2001-06-30', N'Female', N'+91', N'9870000004', NULL,                          N'5 Kothrud',           N'Pune',   N'Maharashtra', N'411038', N'India', N'AB+', N'Single',    NULL,             NULL,          NULL,       '2026-03-01', 1, 0),
 (N'REG-T-0005', N'Vikram', N'Rao',    '1966-02-08', N'Male',   N'+91', N'9870000005', N'vikram.rao@example.com',    N'91 Camp Area',        N'Pune',   N'Maharashtra', N'411001', N'India', N'O-',  N'Widowed',   N'Arjun Rao',     N'9870000015', N'Son',     '2026-03-20', 1, 0);

-- Priya carries a known allergy, so a test can tell a real one from a lost one.
INSERT INTO dbo.allergies (patient_id, allergy_name, allergy_type, reaction, severity, is_active)
SELECT patient_id, N'Sulfa drugs', N'Medication', N'Skin rash', N'Moderate', 1
FROM dbo.patients WHERE registration_number = N'REG-T-0002';

------------------------------------------------------------------ 7. pharmacy
INSERT INTO dbo.suppliers (supplier_name, contact_person, phone, email, gst_number, is_active)
VALUES
 (N'Baidyanath Distributors', N'Suresh Jain', N'9860000001', N'sales@baidyanath.example', N'27AABCU9603R1ZM', 1),
 (N'Dabur Wholesale',         N'Anita Rao',   N'9860000002', N'orders@dabur.example',     N'27AAACD0826Q1Z8', 1);

INSERT INTO dbo.medicines_master (medicine_name, medicine_category, manufacturer, composition, standard_dosage, form, shelf_life_months, storage_conditions, is_active)
VALUES
 (N'Triphala Churna',    N'Classical_Ayurvedic', N'Baidyanath', N'Amalaki, Bibhitaki, Haritaki', N'5 g twice daily',   N'Churna',        36, N'Cool, dry place', 1),
 (N'Ashwagandha Churna', N'Classical_Ayurvedic', N'Dabur',      N'Withania somnifera',           N'3-6 g twice daily', N'Churna',        36, N'Cool, dry place', 1),
 (N'Arjunarishta',       N'Classical_Ayurvedic', N'Baidyanath', N'Terminalia arjuna, Draksha',   N'15-30 ml',          N'Asava_Arishta', 48, N'Cool, dry place', 1),
 (N'Saraswatarishta',    N'Classical_Ayurvedic', N'Dabur',      N'Brahmi, Shankhpushpi',         N'15 ml twice daily', N'Asava_Arishta', 48, N'Cool, dry place', 1);

-- One batch per medicine, plus one deliberately near expiry so expiry rules can be seen.
INSERT INTO dbo.inventory (medicine_id, batch_number, manufacture_date, expiry_date, quantity_received, quantity_available, quantity_unit, purchase_price, selling_price, mrp, supplier_id, location, is_active)
SELECT m.medicine_id, v.batch, v.mfg, v.exp, v.qty, v.qty, v.unit, v.cost, v.sell, v.mrp,
       (SELECT supplier_id FROM dbo.suppliers WHERE supplier_name = v.supplier), v.loc, 1
FROM (VALUES
 (N'Triphala Churna',    N'TRI-T-001', CAST('2025-06-01' AS DATE), CAST('2028-06-01' AS DATE), 100.000, N'Packs',   70.00, 110.00, 130.00, N'Baidyanath Distributors', N'Rack A1'),
 (N'Ashwagandha Churna', N'ASH-T-001', CAST('2025-08-01' AS DATE), CAST('2028-08-01' AS DATE), 120.000, N'Packs',   80.00, 125.00, 145.00, N'Dabur Wholesale',         N'Rack A2'),
 (N'Arjunarishta',       N'ARJ-T-001', CAST('2025-03-01' AS DATE), CAST('2029-03-01' AS DATE),  60.000, N'Bottles', 85.00, 120.00, 140.00, N'Baidyanath Distributors', N'Rack C1'),
 -- Expires soon: lets a tester see the near-expiry behaviour without editing data.
 (N'Saraswatarishta',    N'SAR-T-001', CAST('2024-01-01' AS DATE), CAST('2026-10-31' AS DATE),  40.000, N'Bottles', 90.00, 130.00, 150.00, N'Dabur Wholesale',         N'Rack C2')
) AS v(med, batch, mfg, exp, qty, unit, cost, sell, mrp, supplier, loc)
JOIN dbo.medicines_master m ON m.medicine_name = v.med;

------------------------------------------------------------------ 8. panchakarma
INSERT INTO dbo.panchkarma_therapies (therapy_name, description, default_duration_minutes, standard_charge, is_active)
VALUES
 (N'Abhyanga',   N'Full body oil massage',                        60, 1200.00, 1),
 (N'Shirodhara', N'Warm liquid poured steadily over the forehead', 45, 1500.00, 1),
 (N'Swedana',    N'Induced sudation, usually after Snehan',        30,  800.00, 1);

INSERT INTO dbo.panchkarma_rooms (room_name, room_code, description, location, capacity, is_active)
VALUES
 (N'Therapy Room 1', N'PK-1', N'General Panchakarma therapy room', N'Ground floor', 1, 1),
 (N'Steam Room',     N'PK-S', N'Swedana and steam therapies',      N'Ground floor', 1, 1);

-- Esha works weekday mornings, so a session can be booked without setup.
INSERT INTO dbo.therapist_schedule (therapist_id, day_of_week, start_time, end_time, slot_duration_minutes, max_sessions_per_slot, is_active)
SELECT s.staff_id, d.day, '09:00', '13:00', 60, 1, 1
FROM dbo.staff s
CROSS JOIN (VALUES (N'Monday'), (N'Tuesday'), (N'Wednesday'), (N'Thursday'), (N'Friday')) AS d(day)
WHERE s.staff_name = N'Esha Joshi';

------------------------------------------------------------------ 9. appointments
-- Two for today so the dashboard and worklist have something to show, and one
-- in the past so history is not empty. Dates are relative, so the baseline does
-- not go stale.
INSERT INTO dbo.appointments
 (patient_id, doctor_id, appointment_date, appointment_time, end_time, appointment_type,
  duration_minutes, reason_for_visit, chief_complaint, appointment_status, booking_channel,
  priority, consultation_fee, payment_status, created_at)
SELECT p.patient_id, d.doctor_id, v.appt_date, v.appt_time, v.end_time, v.type,
       30, v.reason, v.complaint, v.status, N'Walk_in', N'Normal', 500.00, N'Pending', SYSUTCDATETIME()
FROM (VALUES
 (N'REG-T-0001', N'Dr Anand Kulkarni', CAST(GETDATE() AS DATE),          CAST('10:00' AS TIME), CAST('10:30' AS TIME), N'New_consultation', N'Joint pain',        N'Pain in both knees for a month',  N'Scheduled'),
 (N'REG-T-0002', N'Dr Sneha Kulkarni', CAST(GETDATE() AS DATE),          CAST('11:00' AS TIME), CAST('11:30' AS TIME), N'Follow_up',        N'Review',            N'Follow-up on digestion',          N'Confirmed'),
 (N'REG-T-0003', N'Dr Anand Kulkarni', DATEADD(DAY, -7, CAST(GETDATE() AS DATE)), CAST('09:30' AS TIME), CAST('10:00' AS TIME), N'New_consultation', N'General weakness', N'Tiredness through the day',   N'Completed')
) AS v(reg, doctor, appt_date, appt_time, end_time, type, reason, complaint, status)
JOIN dbo.patients p ON p.registration_number = v.reg
JOIN dbo.doctors  d ON d.doctor_name = v.doctor;

------------------------------------------------------------------ 10. repair unusable roles
-- A role granting no menus cannot sign in anywhere, which blocks testing rather
-- than testing anything. Any role left with fewer than two menus is given the
-- clinical set so its login is usable.
DECLARE @dashboard TABLE (menu_name NVARCHAR(255));
INSERT INTO @dashboard VALUES
 (N'Dashboard'), (N'Patients'), (N'Register Patient'), (N'Appointments'),
 (N'Doctor Worklist'), (N'Doctors'), (N'Slots & Schedules'), (N'Reminders'),
 (N'Medicines'), (N'Panchakarma Queue');

INSERT INTO dbo.access_level_menus (access_level_id, menu_id, is_view)
SELECT al.access_level_id, m.menu_id, 1
FROM dbo.access_levels al
CROSS JOIN dbo.menus m
JOIN @dashboard d ON d.menu_name = m.menu_name
WHERE al.access_level_name = N'Doctor Clinical'
  AND (SELECT COUNT(*) FROM dbo.access_level_menus x WHERE x.access_level_id = al.access_level_id) < 2
  AND NOT EXISTS (SELECT 1 FROM dbo.access_level_menus y
                  WHERE y.access_level_id = al.access_level_id AND y.menu_id = m.menu_id);

-- Every role needs somewhere to land after signing in.
INSERT INTO dbo.access_level_menus (access_level_id, menu_id, is_view)
SELECT al.access_level_id, m.menu_id, 1
FROM dbo.access_levels al
CROSS JOIN dbo.menus m
WHERE m.menu_name = N'Dashboard'
  AND EXISTS (SELECT 1 FROM dbo.access_level_menus x WHERE x.access_level_id = al.access_level_id)
  AND NOT EXISTS (SELECT 1 FROM dbo.access_level_menus y
                  WHERE y.access_level_id = al.access_level_id AND y.menu_id = m.menu_id);

------------------------------------------------------------------ report
SELECT 'database        : ' + DB_NAME();
SELECT 'logins          : ' + STRING_AGG(username, ', ') WITHIN GROUP (ORDER BY username) FROM dbo.users;
SELECT 'patients        : ' + CAST(COUNT(*) AS VARCHAR) FROM dbo.patients;
SELECT 'doctors / staff : ' + CAST((SELECT COUNT(*) FROM dbo.doctors) AS VARCHAR) + ' / ' + CAST((SELECT COUNT(*) FROM dbo.staff) AS VARCHAR);
SELECT 'medicines/batch : ' + CAST((SELECT COUNT(*) FROM dbo.medicines_master) AS VARCHAR) + ' / ' + CAST((SELECT COUNT(*) FROM dbo.inventory) AS VARCHAR);
SELECT 'appointments    : ' + CAST(COUNT(*) AS VARCHAR) FROM dbo.appointments;
SELECT 'bills/payments  : ' + CAST((SELECT COUNT(*) FROM dbo.bills) AS VARCHAR) + ' / ' + CAST((SELECT COUNT(*) FROM dbo.payments) AS VARCHAR) + '   (expected 0 / 0)';
GO
SET NOEXEC OFF;
