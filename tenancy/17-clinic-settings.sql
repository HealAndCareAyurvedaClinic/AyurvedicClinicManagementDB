/*
    Clinic branding and prescription settings, so the letterhead stops being source code.

    ---------------------------------------------------------------- the problem

    Everything on a printed prescription -- the logo, the clinic name, the address, the
    phone number, the licence number -- came from UI/src/app/config/app.config.ts, a
    TypeScript constant compiled into the bundle. One clinic's details, hard-coded, in a
    product sold to many. A second clinic could not change its own address without a
    developer, a build and a deployment, and the logo was a file at a fixed path in the
    bundle (assets/images/logo.png) that nobody but a developer could replace.

    It is also incomplete even for one clinic: dbo.tenants holds contact_email and
    contact_phone but no address at all, and dbo.branches holds an address per branch.
    Neither holds a logo, a tagline, a licence number or anything about how a
    prescription should be laid out.

    ---------------------------------------------------------------- what this adds

      1. dbo.clinic_settings -- one row per clinic. The letterhead fields, the prescriber
         block, and the prescription layout choice.
      2. dbo.clinic_logos    -- one row per clinic, the uploaded image itself.
      3. A row in clinic_settings for every clinic that already exists, pre-filled from
         dbo.tenants and the clinic's primary branch, so no clinic starts blank.

    Two tables rather than one because of how they are read. The settings are read on
    every page load to draw the header; the logo is an image the browser should fetch
    once and cache by itself. Keeping the varbinary out of clinic_settings means a
    settings read is a few hundred bytes and does not drag an image through it. This is
    the opposite choice from dbo.investigation_report_files, which keeps file_data beside
    its metadata -- correctly, because there the two are always wanted together. Here
    they are not.

    ---------------------------------------------------------------- the template column

    prescription_template is CHECK-constrained to four values, and the choice between
    them is a real workflow distinction rather than decoration:

      Classic      logo left, clinic block right. A4, blank paper. The present layout.
      Centered     logo centred above a centred clinic block. A4, blank paper.
      Compact      one slim header band, denser body. A4, blank paper, fewer sheets.
      Preprinted   NO header. For a clinic whose paper is already printed with its
                   letterhead, where drawing one would print it twice.

    Preprinted is the one with behaviour attached, and it is deliberately asymmetric:
    printing suppresses the header and leaves preprinted_top_margin_mm of blank space for
    the pre-printed one, while DOWNLOADING the same prescription draws the header in
    full. A downloaded PDF is emailed, filed, or printed by the patient on plain paper --
    nobody at the other end has the clinic's stationery, so a header-less PDF would
    arrive as an unattributable list of medicines.

    That asymmetry is not invented here. Cliniko documents the same rule for its
    letterhead, which "will only appear when you print (or if you save the treatment note
    as a PDF and print it out)"; and MyOPD's letterhead instructions are to measure the
    pre-printed header and enter its height as the top margin, with the clinic and doctor
    name switches turned off so they are not printed twice. preprinted_top_margin_mm is
    that measurement, in millimetres, which is the unit the PDF is already laid out in.

    ---------------------------------------------------------------- scoping

    Both tables are clinic-wide, not per-branch. A branch has its own address in
    dbo.branches, but a prescription is issued on the clinic's letterhead under the
    clinic's licence, and the logo is the clinic's. A clinic that genuinely needs a
    different letterhead per branch is a later change, and this leaves room for it: the
    unique index is on tenant_id alone, so widening it to (tenant_id, branch_id) stays an
    additive step.

    Idempotent. Safe to re-run: re-running creates nothing twice and overwrites no
    setting anybody has since changed.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;
SET QUOTED_IDENTIFIER ON;
GO

---------------------------------------------------------------- 1. settings
IF OBJECT_ID('dbo.clinic_settings', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.clinic_settings
    (
        setting_id                 INT            IDENTITY(1,1) NOT NULL,
        tenant_id                  INT            NOT NULL,

        -- The letterhead. Nullable throughout: a clinic that has filled in nothing yet
        -- gets a prescription with its name on it and no false details, which is better
        -- than a prescription carrying somebody else's address.
        clinic_display_name        NVARCHAR(200)  NULL,
        tagline                    NVARCHAR(200)  NULL,
        address_line1              NVARCHAR(255)  NULL,
        address_line2              NVARCHAR(255)  NULL,
        city                       NVARCHAR(100)  NULL,
        state                      NVARCHAR(100)  NULL,
        pincode                    NVARCHAR(10)   NULL,
        country                    NVARCHAR(100)  NULL,
        phone                      NVARCHAR(50)   NULL,
        email                      NVARCHAR(255)  NULL,
        website                    NVARCHAR(255)  NULL,
        registration_number        NVARCHAR(100)  NULL,
        -- On the bill rather than the prescription, and required on anything a patient
        -- may claim against or set against input credit. It was hard-coded in the UI
        -- bundle alongside the address, which made one clinic's GST number print on
        -- every clinic's bills.
        gst_number                 NVARCHAR(20)   NULL,

        -- The prescriber block printed above the signature line. Clinic-wide on purpose:
        -- it is what a small clinic wants, where one doctor signs everything. Where a
        -- visit records its own doctor the prescription prefers that, and this is the
        -- fallback -- see the API, which does not let this overwrite a known prescriber.
        doctor_name                NVARCHAR(200)  NULL,
        doctor_qualifications      NVARCHAR(200)  NULL,
        doctor_registration_number NVARCHAR(100)  NULL,

        -- Layout.
        prescription_template      NVARCHAR(30)   NOT NULL,
        show_logo                  BIT            NOT NULL,
        logo_height_mm             DECIMAL(5,2)   NOT NULL,
        preprinted_top_margin_mm   DECIMAL(5,2)   NOT NULL,
        prescription_footer_note   NVARCHAR(400)  NULL,

        created_at                 DATETIME2(7)   NOT NULL,
        updated_at                 DATETIME2(7)   NULL,
        updated_by                 INT            NULL,

        CONSTRAINT PK_clinic_settings PRIMARY KEY CLUSTERED (setting_id ASC),

        -- One row per clinic. The constraint is what makes "the clinic's settings" a
        -- meaningful phrase; without it a second row would silently shadow the first.
        CONSTRAINT UQ_clinic_settings_tenant UNIQUE NONCLUSTERED (tenant_id ASC),

        CONSTRAINT FK_clinic_settings_tenant FOREIGN KEY (tenant_id)
            REFERENCES dbo.tenants (tenant_id),

        CONSTRAINT CK_clinic_settings_template CHECK
            (prescription_template IN (N'Classic', N'Centered', N'Compact', N'Preprinted')),

        -- A logo taller than a fifth of the page, or a top margin past the middle of it,
        -- is a typo rather than a preference. A4 is 297mm tall.
        CONSTRAINT CK_clinic_settings_logo_height CHECK
            (logo_height_mm > 0 AND logo_height_mm <= 60),
        CONSTRAINT CK_clinic_settings_top_margin CHECK
            (preprinted_top_margin_mm >= 0 AND preprinted_top_margin_mm <= 150)
    );

    ALTER TABLE dbo.clinic_settings ADD CONSTRAINT DF_clinic_settings_template
        DEFAULT (N'Classic') FOR prescription_template;
    ALTER TABLE dbo.clinic_settings ADD CONSTRAINT DF_clinic_settings_show_logo
        DEFAULT ((1)) FOR show_logo;
    ALTER TABLE dbo.clinic_settings ADD CONSTRAINT DF_clinic_settings_logo_height
        DEFAULT ((18.0)) FOR logo_height_mm;
    -- 45mm: a typical pre-printed Ayurvedic letterhead runs a logo and three or four
    -- lines of address across the top of the sheet. It is a starting point to be
    -- measured and corrected per clinic, not a claim about anybody's stationery.
    ALTER TABLE dbo.clinic_settings ADD CONSTRAINT DF_clinic_settings_top_margin
        DEFAULT ((45.0)) FOR preprinted_top_margin_mm;
    ALTER TABLE dbo.clinic_settings ADD CONSTRAINT DF_clinic_settings_created
        DEFAULT (sysutcdatetime()) FOR created_at;

    PRINT '  dbo.clinic_settings created';
END
ELSE
    PRINT '  dbo.clinic_settings already present';
GO

---------------------------------------------------------------- 2. the logo itself
IF OBJECT_ID('dbo.clinic_logos', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.clinic_logos
    (
        logo_id        INT             IDENTITY(1,1) NOT NULL,
        tenant_id      INT             NOT NULL,

        file_name      NVARCHAR(255)   NOT NULL,
        mime_type      NVARCHAR(100)   NOT NULL,
        size_bytes     INT             NOT NULL,
        logo_data      VARBINARY(MAX)  NOT NULL,

        -- Lets the logo endpoint answer with an ETag and the browser answer itself with
        -- a 304 thereafter. Without it every page load re-sends the image.
        content_hash   NVARCHAR(64)    NOT NULL,

        -- Natural pixel size, read once at upload. The PDF needs the aspect ratio to
        -- scale the image to logo_height_mm without distorting it, and working it out
        -- from the bytes at print time would mean decoding the image for every
        -- prescription.
        width_px       INT             NULL,
        height_px      INT             NULL,

        uploaded_at    DATETIME2(7)    NOT NULL,
        uploaded_by    INT             NULL,

        CONSTRAINT PK_clinic_logos PRIMARY KEY CLUSTERED (logo_id ASC),

        -- One logo per clinic: uploading a new one replaces the old. A history of
        -- discarded logos is not something anybody has asked to keep.
        CONSTRAINT UQ_clinic_logos_tenant UNIQUE NONCLUSTERED (tenant_id ASC),

        CONSTRAINT FK_clinic_logos_tenant FOREIGN KEY (tenant_id)
            REFERENCES dbo.tenants (tenant_id),

        -- Mirrors the cap the API enforces, so a row written by something other than the
        -- API still cannot put a 40MB photograph on a prescription. 1MB is ample for a
        -- letterhead logo.
        CONSTRAINT CK_clinic_logos_size CHECK (size_bytes > 0 AND size_bytes <= 1048576),

        -- No SVG. It is a document format that can carry script, and this image is
        -- served back to a browser and drawn into a PDF; raster only is the safe answer.
        CONSTRAINT CK_clinic_logos_mime CHECK
            (mime_type IN (N'image/png', N'image/jpeg', N'image/webp'))
    );

    ALTER TABLE dbo.clinic_logos ADD CONSTRAINT DF_clinic_logos_uploaded
        DEFAULT (sysutcdatetime()) FOR uploaded_at;

    PRINT '  dbo.clinic_logos created';
END
ELSE
    PRINT '  dbo.clinic_logos already present';
GO

---------------------------------------------------------------- 3. a row per clinic
-- Pre-filled rather than blank. The address is taken from the clinic's primary branch,
-- which is where it already lives, and the phone and email from dbo.tenants. A clinic
-- that opens the Settings screen therefore finds its own details there to correct,
-- rather than an empty form it has to fill from nothing.
--
-- Only inserts. A clinic that already has a row has settings somebody chose, and this
-- script will not reach back over them.
INSERT INTO dbo.clinic_settings
    (tenant_id, clinic_display_name, address_line1, city, state, pincode, country,
     phone, email, prescription_template, show_logo, logo_height_mm,
     preprinted_top_margin_mm, created_at)
SELECT
    t.tenant_id,
    t.tenant_name,
    b.address_line1,
    b.city,
    b.state,
    b.pincode,
    N'India',
    COALESCE(t.contact_phone, b.phone),
    t.contact_email,
    N'Classic',
    1,
    18.0,
    45.0,
    SYSUTCDATETIME()
FROM dbo.tenants t
OUTER APPLY (
    -- The primary branch, or failing that the oldest active one. A clinic with no
    -- branch at all still gets a settings row, just without an address in it.
    SELECT TOP (1) x.address_line1, x.city, x.state, x.pincode, x.phone
      FROM dbo.branches x
     WHERE x.tenant_id = t.tenant_id
       AND x.is_deleted = 0
     ORDER BY x.is_primary DESC, x.is_active DESC, x.branch_id ASC
) b
WHERE t.is_deleted = 0
  AND NOT EXISTS (SELECT 1 FROM dbo.clinic_settings s WHERE s.tenant_id = t.tenant_id);

PRINT '  clinics given a settings row: ' + CAST(@@ROWCOUNT AS VARCHAR);
GO

---------------------------------------------------------------- 4. indexes
-- tenant_id is already covered by UQ_clinic_settings_tenant and UQ_clinic_logos_tenant,
-- which are the only way either table is ever queried. A further index would never be
-- read, so none is created.

---------------------------------------------------------------- report
SELECT 'clinic_settings rows : ' + CAST(COUNT(*) AS VARCHAR) FROM dbo.clinic_settings;
SELECT 'clinics without settings : ' + CAST(COUNT(*) AS VARCHAR)
  FROM dbo.tenants t
 WHERE t.is_deleted = 0
   AND NOT EXISTS (SELECT 1 FROM dbo.clinic_settings s WHERE s.tenant_id = t.tenant_id);
