-- ============================================================================
-- seed-access-rights-data.sql
--
-- Reference/seed data for the access-rights (RBAC) feature so every team
-- member can reproduce the same working environment locally.
--
-- Covers: roles, access_groups, access_levels, role_access_groups,
--         access_group_access_levels, menus, screens, sections,
--         section_fields, access_level_menus, access_level_screens,
--         access_level_sections, access_level_section_fields
--
-- Intentionally EXCLUDED: users, user_roles, refresh_tokens
--   (real per-developer credentials/tokens, not portable seed data -
--    create your own admin user via the Register User screen or the
--    /api/auth/register endpoint instead)
--
-- All inserts are guarded with WHERE NOT EXISTS / NOT EXISTS lookups by
-- natural key (name), not hardcoded IDENTITY values, so this script is:
--   - safe to re-run (idempotent)
--   - safe to run against a database whose IDENTITY values differ from
--     the machine this was generated on
--
-- Run this after the DB project has been deployed / all tables created.
-- ============================================================================

USE [AyurvedicClinicMgmt];
GO

-- ----------------------------------------------------------------------------
-- 1. roles
-- ----------------------------------------------------------------------------
INSERT INTO dbo.roles (role_name, description)
SELECT v.role_name, v.description
FROM (VALUES
    ('Admin',            'Full system access'),
    ('Doctor',           'Clinical doctor'),
    ('Assistant Doctor',   'Assistant to a doctor'),
    ('Nurse',            'Nursing staff'),
    ('Receptionist',       'Front-desk / reception staff')
) AS v(role_name, description)
WHERE NOT EXISTS (SELECT 1 FROM dbo.roles r WHERE r.role_name = v.role_name);
GO

-- ----------------------------------------------------------------------------
-- 2. access_groups
-- ----------------------------------------------------------------------------
INSERT INTO dbo.access_groups (access_group_name, access_group_description)
SELECT v.access_group_name, v.access_group_description
FROM (VALUES
    ('Full Access',       'Unrestricted access to all modules'),
    ('Clinical Access',     'Patient records, encounters, and clinical screens'),
    ('Front Desk Access',   'Appointments, patient search, and billing counter'),
    ('Read Only Access',    'View-only access across the system')
) AS v(access_group_name, access_group_description)
WHERE NOT EXISTS (SELECT 1 FROM dbo.access_groups ag WHERE ag.access_group_name = v.access_group_name);
GO

-- ----------------------------------------------------------------------------
-- 3. access_levels
-- ----------------------------------------------------------------------------
INSERT INTO dbo.access_levels (access_level_name, access_level_description)
SELECT v.access_level_name, v.access_level_description
FROM (VALUES
    ('Doctor Screen Full Access', 'Full access to the Doctors screen')
) AS v(access_level_name, access_level_description)
WHERE NOT EXISTS (SELECT 1 FROM dbo.access_levels al WHERE al.access_level_name = v.access_level_name);
GO

-- ----------------------------------------------------------------------------
-- 4. role_access_groups (Role -> Access Group)
-- ----------------------------------------------------------------------------
INSERT INTO dbo.role_access_groups (role_id, access_group_id)
SELECT r.role_id, ag.access_group_id
FROM (VALUES
    ('Admin', 'Full Access')
) AS v(role_name, access_group_name)
JOIN dbo.roles r ON r.role_name = v.role_name
JOIN dbo.access_groups ag ON ag.access_group_name = v.access_group_name
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.role_access_groups rag
    WHERE rag.role_id = r.role_id AND rag.access_group_id = ag.access_group_id
);
GO

-- ----------------------------------------------------------------------------
-- 5. access_group_access_levels (Access Group -> Access Level)
-- ----------------------------------------------------------------------------
INSERT INTO dbo.access_group_access_levels (access_group_id, access_level_id)
SELECT ag.access_group_id, al.access_level_id
FROM (VALUES
    ('Full Access',     'Doctor Screen Full Access'),
    ('Clinical Access',   'Doctor Screen Full Access')
) AS v(access_group_name, access_level_name)
JOIN dbo.access_groups ag ON ag.access_group_name = v.access_group_name
JOIN dbo.access_levels al ON al.access_level_name = v.access_level_name
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.access_group_access_levels agal
    WHERE agal.access_group_id = ag.access_group_id AND agal.access_level_id = al.access_level_id
);
GO

-- ----------------------------------------------------------------------------
-- 6. menus (sidebar/top-menu structure - all top-level, no parents)
-- ----------------------------------------------------------------------------
INSERT INTO dbo.menus (menu_name, menu_type, module, menu_order, menu_icon, menu_route)
SELECT v.menu_name, v.menu_type, v.module, v.menu_order, v.menu_icon, v.menu_route
FROM (VALUES
    ('Dashboard',            'TopMenu', 'Clinical',   1, 'dashboard',            '/dashboard'),
    ('Billing Counter',        'TopMenu', 'Finance',    1, 'point_of_sale',        '/billing'),
    ('Pharmacy Counter',       'TopMenu', 'Pharmacy',   1, 'local_pharmacy',        '/pharmacy-dispense'),
    ('Staff',              'TopMenu', 'Management', 1, 'badge',              '/staff'),
    ('Patients',            'TopMenu', 'Clinical',   2, 'people',             '/patient-list'),
    ('Payments',            'TopMenu', 'Finance',    2, 'payment',            '/payments'),
    ('Medicines',            'TopMenu', 'Pharmacy',   2, 'medication',           '/medicines'),
    ('Register User',         'TopMenu', 'Management', 2, 'person_add_alt',        '/register-user'),
    ('Register Patient',       'TopMenu', 'Clinical',   3, 'person_add',           '/patient-registration'),
    ('Refunds',             'TopMenu', 'Finance',    3, 'money_off',            '/refunds'),
    ('Inventory',            'TopMenu', 'Pharmacy',   3, 'inventory_2',           '/inventory'),
    ('Manage Users',          'TopMenu', 'Management', 3, 'manage_accounts',        '/manage-users'),
    ('Appointments',          'TopMenu', 'Clinical',   4, 'calendar_today',         '/appointments'),
    ('Suppliers',            'TopMenu', 'Pharmacy',   4, 'local_shipping',         '/suppliers'),
    ('Manage Roles',          'TopMenu', 'Management', 4, 'shield',             '/manage-roles'),
    ('Doctor Worklist',        'TopMenu', 'Clinical',   5, 'assignment_ind',         '/doctor-worklist'),
    ('Purchase Orders',        'TopMenu', 'Pharmacy',   5, 'shopping_cart',         '/purchase-orders'),
    ('Manage Menus',          'TopMenu', 'Management', 5, 'menu',              '/manage-menus'),
    ('Doctors',             'TopMenu', 'Clinical',   6, 'medical_services',        '/doctors'),
    ('Stock Alerts',          'TopMenu', 'Pharmacy',   6, 'warning_amber',         '/stock-alerts'),
    ('Manage Access Rights',     'TopMenu', 'Management', 6, 'security',            '/manage-access-rights'),
    ('Slots & Schedules',       'TopMenu', 'Clinical',   7, 'event_available',        '/appointment-slots'),
    ('Audit Logs',           'TopMenu', 'Management', 7, 'manage_search',         '/audit-logs'),
    ('Reminders',            'TopMenu', 'Clinical',   8, 'notifications_active',      '/appointment-reminders'),
    ('Reports',             'TopMenu', 'Management', 8, 'assessment',           '/reports')
) AS v(menu_name, menu_type, module, menu_order, menu_icon, menu_route)
WHERE NOT EXISTS (SELECT 1 FROM dbo.menus m WHERE m.menu_name = v.menu_name);
GO

-- ----------------------------------------------------------------------------
-- 7. screens (linked to their owning menu by name)
-- ----------------------------------------------------------------------------
INSERT INTO dbo.screens (screen_name, screen_description, menu_id, screen_route)
SELECT v.screen_name, v.screen_description, m.menu_id, v.screen_route
FROM (VALUES
    ('Doctors',       'Manage clinic doctors',         'Doctors',       '/doctors'),
    ('Patients',      'Manage patient records',         'Patients',      '/patient-list'),
    ('Appointments',    'Book and manage appointments',     'Appointments',    '/appointments'),
    ('Staff',        'Manage clinic staff',           'Staff',       '/staff'),
    ('Billing Counter',  'Generate and manage bills',       'Billing Counter',  '/billing'),
    ('Medicines',      'Manage medicine master data',      'Medicines',     '/medicines'),
    ('Suppliers',      'Manage medicine suppliers',       'Suppliers',     '/suppliers')
) AS v(screen_name, screen_description, menu_name, screen_route)
JOIN dbo.menus m ON m.menu_name = v.menu_name
WHERE NOT EXISTS (SELECT 1 FROM dbo.screens s WHERE s.screen_name = v.screen_name);
GO

-- ----------------------------------------------------------------------------
-- 8. sections (linked to their owning screen by name)
-- ----------------------------------------------------------------------------
INSERT INTO dbo.sections (section_name, section_description, screen_id)
SELECT v.section_name, v.section_description, s.screen_id
FROM (VALUES
    ('Doctor Details',    'Core doctor profile fields',   'Doctors'),
    ('Patient Details',    'Core patient profile fields',   'Patients'),
    ('Appointment Details',  'Booking details',          'Appointments'),
    ('Staff Details',     'Core staff profile fields',    'Staff'),
    ('Bill Details',      'Invoice and payment fields',   'Billing Counter'),
    ('Medicine Details',   'Master medicine fields',      'Medicines'),
    ('Supplier Details',   'Supplier contact fields',      'Suppliers')
) AS v(section_name, section_description, screen_name)
JOIN dbo.screens s ON s.screen_name = v.screen_name
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.sections sec
    WHERE sec.section_name = v.section_name AND sec.screen_id = s.screen_id
);
GO

-- ----------------------------------------------------------------------------
-- 9. section_fields (linked to their owning screen + section by name)
-- ----------------------------------------------------------------------------
INSERT INTO dbo.section_fields
    (screen_id, section_id, field_name, field_label, control_type, is_system_required, field_order)
SELECT sc.screen_id, se.section_id, v.field_name, v.field_label, v.control_type, v.is_system_required, v.field_order
FROM (VALUES
    -- Doctors / Doctor Details
    ('Doctors',    'Doctor Details',    'doctorName',       'Doctor Name',       'text',   1, 1),
    ('Doctors',    'Doctor Details',    'qualification',     'Qualification',      'text',   0, 2),
    ('Doctors',    'Doctor Details',    'specialization',     'Specialization',      'text',   0, 3),
    ('Doctors',    'Doctor Details',    'registrationNumber',   'Registration Number',   'text',   0, 4),
    ('Doctors',    'Doctor Details',    'phone',         'Phone',           'text',   0, 5),
    ('Doctors',    'Doctor Details',    'email',         'Email',           'email',  0, 6),
    ('Doctors',    'Doctor Details',    'consultationFee',    'Consultation Fee',     'number',  0, 7),
    -- Patients / Patient Details
    ('Patients',    'Patient Details',    'firstName',        'First Name',        'text',   1, 1),
    ('Patients',    'Patient Details',    'lastName',        'Last Name',         'text',   1, 2),
    ('Patients',    'Patient Details',    'dateOfBirth',      'Date of Birth',      'date',   1, 3),
    ('Patients',    'Patient Details',    'gender',         'Gender',           'select', 1, 4),
    ('Patients',    'Patient Details',    'phone',         'Phone',           'text',   1, 5),
    ('Patients',    'Patient Details',    'email',         'Email',           'email',  0, 6),
    ('Patients',    'Patient Details',    'bloodGroup',       'Blood Group',        'select', 0, 7),
    ('Patients',    'Patient Details',    'addressLine1',      'Address',          'textarea',0, 8),
    -- Appointments / Appointment Details
    ('Appointments',  'Appointment Details',  'appointmentType',    'Appointment Type',     'select', 1, 1),
    ('Appointments',  'Appointment Details',  'reasonForVisit',     'Reason for Visit',     'text',   0, 2),
    ('Appointments',  'Appointment Details',  'appointmentStatus',   'Status',           'select', 1, 3),
    ('Appointments',  'Appointment Details',  'priority',        'Priority',          'select', 0, 4),
    ('Appointments',  'Appointment Details',  'consultationFee',    'Consultation Fee',     'number',  0, 5),
    ('Appointments',  'Appointment Details',  'contactPhone',      'Contact Phone',       'text',   0, 6),
    -- Staff / Staff Details
    ('Staff',      'Staff Details',     'staffName',        'Staff Name',        'text',   1, 1),
    ('Staff',      'Staff Details',     'staffType',        'Staff Type',        'select', 1, 2),
    ('Staff',      'Staff Details',     'qualification',     'Qualification',      'text',   0, 3),
    ('Staff',      'Staff Details',     'mobile',         'Mobile',           'text',   1, 4),
    ('Staff',      'Staff Details',     'email',         'Email',           'email',  0, 5),
    -- Billing Counter / Bill Details
    ('Billing Counter', 'Bill Details',      'billNumber',       'Bill Number',        'text',   1, 1),
    ('Billing Counter', 'Bill Details',      'billType',        'Bill Type',         'select', 1, 2),
    ('Billing Counter', 'Bill Details',      'subtotal',        'Subtotal',          'number',  1, 3),
    ('Billing Counter', 'Bill Details',      'discountValue',     'Discount',          'number',  0, 4),
    ('Billing Counter', 'Bill Details',      'totalAmount',      'Total Amount',       'number',  1, 5),
    ('Billing Counter', 'Bill Details',      'billStatus',       'Status',           'select', 1, 6),
    ('Billing Counter', 'Bill Details',      'notes',         'Notes',           'textarea',0, 7),
    -- Medicines / Medicine Details
    ('Medicines',    'Medicine Details',    'medicineName',      'Medicine Name',       'text',   1, 1),
    ('Medicines',    'Medicine Details',    'medicineCategory',    'Category',          'select', 0, 2),
    ('Medicines',    'Medicine Details',    'manufacturer',      'Manufacturer',       'text',   0, 3),
    ('Medicines',    'Medicine Details',    'form',          'Form',            'select', 0, 4),
    ('Medicines',    'Medicine Details',    'standardDosage',     'Standard Dosage',      'text',   0, 5),
    -- Suppliers / Supplier Details
    ('Suppliers',    'Supplier Details',    'supplierName',      'Supplier Name',       'text',   1, 1),
    ('Suppliers',    'Supplier Details',    'contactPerson',     'Contact Person',      'text',   0, 2),
    ('Suppliers',    'Supplier Details',    'phone',         'Phone',           'text',   0, 3),
    ('Suppliers',    'Supplier Details',    'email',         'Email',           'email',  0, 4),
    ('Suppliers',    'Supplier Details',    'gstNumber',        'GST Number',        'text',   0, 5),
    ('Suppliers',    'Supplier Details',    'address',        'Address',          'textarea',0, 6)
) AS v(screen_name, section_name, field_name, field_label, control_type, is_system_required, field_order)
JOIN dbo.screens sc ON sc.screen_name = v.screen_name
JOIN dbo.sections se ON se.section_name = v.section_name AND se.screen_id = sc.screen_id
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.section_fields sf
    WHERE sf.screen_id = sc.screen_id AND sf.section_id = se.section_id AND sf.field_name = v.field_name
);
GO

-- ----------------------------------------------------------------------------
-- 10. access_level_menus (grants for "Doctor Screen Full Access")
-- ----------------------------------------------------------------------------
INSERT INTO dbo.access_level_menus (access_level_id, menu_id, is_view)
SELECT al.access_level_id, m.menu_id, 1
FROM (VALUES
    ('Doctor Screen Full Access', 'Doctors')
) AS v(access_level_name, menu_name)
JOIN dbo.access_levels al ON al.access_level_name = v.access_level_name
JOIN dbo.menus m ON m.menu_name = v.menu_name
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.access_level_menus alm
    WHERE alm.access_level_id = al.access_level_id AND alm.menu_id = m.menu_id
);
GO

-- ----------------------------------------------------------------------------
-- 11. access_level_screens (grants for "Doctor Screen Full Access")
-- ----------------------------------------------------------------------------
INSERT INTO dbo.access_level_screens (access_level_id, screen_id, is_view, is_read, is_write, is_delete)
SELECT al.access_level_id, s.screen_id, 1, 1, 1, 1
FROM (VALUES
    ('Doctor Screen Full Access', 'Doctors')
) AS v(access_level_name, screen_name)
JOIN dbo.access_levels al ON al.access_level_name = v.access_level_name
JOIN dbo.screens s ON s.screen_name = v.screen_name
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.access_level_screens als
    WHERE als.access_level_id = al.access_level_id AND als.screen_id = s.screen_id
);
GO

-- ----------------------------------------------------------------------------
-- 12. access_level_sections (grants for "Doctor Screen Full Access")
-- ----------------------------------------------------------------------------
INSERT INTO dbo.access_level_sections (access_level_id, section_id, is_view, is_read, is_write, is_delete)
SELECT al.access_level_id, se.section_id, 1, 1, 1, 1
FROM (VALUES
    ('Doctor Screen Full Access', 'Doctors', 'Doctor Details')
) AS v(access_level_name, screen_name, section_name)
JOIN dbo.access_levels al ON al.access_level_name = v.access_level_name
JOIN dbo.screens sc ON sc.screen_name = v.screen_name
JOIN dbo.sections se ON se.section_name = v.section_name AND se.screen_id = sc.screen_id
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.access_level_sections als
    WHERE als.access_level_id = al.access_level_id AND als.section_id = se.section_id
);
GO

-- ----------------------------------------------------------------------------
-- 13. access_level_section_fields (grants for "Doctor Screen Full Access")
--     doctorName is also marked Required; the rest are not.
-- ----------------------------------------------------------------------------
INSERT INTO dbo.access_level_section_fields
    (access_level_id, section_field_id, is_view, is_read, is_write, is_delete, is_required)
SELECT al.access_level_id, sf.section_field_id, 1, 1, 1, 1, v.is_required
FROM (VALUES
    ('Doctor Screen Full Access', 'Doctors', 'Doctor Details', 'doctorName',       1),
    ('Doctor Screen Full Access', 'Doctors', 'Doctor Details', 'qualification',     0),
    ('Doctor Screen Full Access', 'Doctors', 'Doctor Details', 'specialization',     0),
    ('Doctor Screen Full Access', 'Doctors', 'Doctor Details', 'registrationNumber',   0),
    ('Doctor Screen Full Access', 'Doctors', 'Doctor Details', 'phone',         0),
    ('Doctor Screen Full Access', 'Doctors', 'Doctor Details', 'email',         0),
    ('Doctor Screen Full Access', 'Doctors', 'Doctor Details', 'consultationFee',    0)
) AS v(access_level_name, screen_name, section_name, field_name, is_required)
JOIN dbo.access_levels al ON al.access_level_name = v.access_level_name
JOIN dbo.screens sc ON sc.screen_name = v.screen_name
JOIN dbo.sections se ON se.section_name = v.section_name AND se.screen_id = sc.screen_id
JOIN dbo.section_fields sf ON sf.field_name = v.field_name AND sf.screen_id = sc.screen_id AND sf.section_id = se.section_id
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.access_level_section_fields alsf
    WHERE alsf.access_level_id = al.access_level_id AND alsf.section_field_id = sf.section_field_id
);
GO

PRINT 'Access-rights seed data applied (or already present).';
GO
