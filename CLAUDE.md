# CLAUDE.md

Guidance for Claude Code working in this repository.

## What this is

The SQL Server database for the Heal & Care Ayurvedic Clinic Management System — a
multi-tenant clinic SaaS. It is one of three repositories: this one, the ASP.NET Core API
(`AyurvedicClinicManagementAPI`) and the Angular UI (`ayurvedic-clinic-app`).

This repo holds the schema and the migrations that apply it. It is a `.sqlproj`, but the
project file is **not** how the database is built — see below.

---

## Read this before you read any schema file

Three files claim to describe the schema. Only one is true.

| File | Status |
| --- | --- |
| `deploy/baseline-schema.sql` | **The live schema.** 81 tables, 76 tenant foreign keys. Scripted from a database with every migration applied. |
| `dbo/Tables/*.sql` | **Stale — pre-tenancy.** 52 files, **zero** mention of `tenant_id`. |
| `dbo/Tables/DB_Scripts.sql` | **Dead.** A 68 KB, 49-table dump for a database called `ayur_clinic`. Not in the manifest. Never run it. |

`dbo/Tables/` predates the tenancy migrations, so it describes a schema that has not
existed since they landed. Concretely: `dbo/Tables/patients.sql` declares **30** columns;
the live `patients` table has **36**, plus `tenant_id` and `branch_id` that the file never
mentions. Reading it to answer "what columns does this table have" gives a wrong answer
that looks authoritative.

**To learn the real shape of a table, read `deploy/baseline-schema.sql`** (or query a live
database). Treat `dbo/Tables/` as historical, and `.sqlproj` registration as meaningless —
it lists 26 of the 53 files and has done for a long time.

---

## Applying the database

`deploy/README.md` is thorough and current. Read it rather than reconstructing the commands
here. The short version:

```powershell
./deploy/Apply-Database.ps1 -Server . -Database AyurvedicClinicMgmt -User user1 -Password xxx
```

Key points it explains in full, worth knowing before you touch anything:

- **`deploy/manifest.txt` is the running order**, not filenames and not alphabetical. A
  `.sql` file that changes a database and is absent from the manifest **fails the run**,
  deliberately.
- **`-Baseline`** adopts a database that already has the schema, recording scripts as
  applied without running them. On a fresh database it would record a lie.
- **`-DryRun`** lists what would run and changes nothing.
- **`baseline-schema.sql` is not re-runnable.** 192 of 252 column defaults are unnamed, so
  their generated names differ per database and the `IF NOT EXISTS` guards miss. If a run
  fails, drop the database and start over.
- **Never replay the tenancy migrations over a baseline.** `07-tenant-lifecycle.sql`
  backfills `status` from `is_active` then drops `is_active`; against a baseline that
  column is already gone and it fails outright.

Building an empty database (QA, UAT, a fresh Azure environment) is
`deploy/Bootstrap-AzureDatabase.ps1`, which runs the only three steps that work in the
only order that works.

---

## Making a change

1. Write `tenancy/NN-short-name.sql`, taking the next number.
2. **Add it to `deploy/manifest.txt`** in the position it must run. Forgetting this fails
   the check — which is the point; thirteen migrations once went missing from the
   `.sqlproj` because nothing noticed.
3. Make it idempotent and make it refuse rather than corrupt. The existing migrations guard
   with `IF EXISTS` and raise `THROW 51000`-range errors when a precondition does not hold
   (see `14-pharmacist-staff-type.sql`, `15-doctors-into-staff.sql`).
4. Apply it with `-DryRun` first, then for real, then confirm against a live database.

A schema change almost always needs the API and UI to follow. The order across the three
repos is **DB → API → UI**, deploying between each, because the API reads a schema that
must already exist and the UI reads an API contract that must already be deployed.

---

## Conventions

Tables and columns are **`snake_case`**, plural table names: `patients`, `patient_id`,
`registration_number`, `encounter_prescriptions`.

> ⚠️ The workspace-root `Claude.md` documents "Table naming: PascalCase singular
> (`Patient`, `Appointment`)" and standard columns `Id`, `TenantId`, `CreatedAt`,
> `UpdatedAt`, `IsDeleted`. **That does not describe this database** and never has.
> The API maps `snake_case` columns to PascalCase entities, which is probably where the
> confusion began. Follow the database.

Standard columns are conventional, not universal — measured across the 52 table files:
`created_at` in 42, `updated_at` in 38, `is_active` in 21, `is_deleted` in only 15. Do not
assume a table soft-deletes; check it.

`tenant_id` is added by the tenancy migrations, not by the original table definitions, so
it appears in `deploy/baseline-schema.sql` and not in `dbo/Tables/`.

---

## Column vocabularies are enforced here, and only here

153 `CHECK` constraints across 28 columns restrict values to a fixed set, and **most are
invisible to the API's OpenAPI document**. A value the API's own DTO accepts can still be
rejected by the database.

Three that have cost real time:

- `encounter_prescriptions.medicine_type` → `Classical_Ayurvedic, Patent_Ayurvedic, Herbal,
  Modern, Other` — the *system of medicine*. A different vocabulary from
  `current_medications.medicine_type` (`Allopathic`, …), despite the identical column name.
- `panchkarma_procedures.procedure_type` → the karma itself (`Vamana`, `Virechana`,
  `Basti`, `Nasya`, `Raktamokshana`, `Snehana`, `Swedana`, `Other`). Not a phase —
  `Purvakarma` and `Shodhana` are rejected.
- `medicines_master.form` → `Tablet, Capsule, Syrup, Powder, Oil, Ghrita, Asava_Arishta,
  Churna, Vati, Kwatha, Other`. Enforced only by a CHECK; OpenAPI says `string`.

**Before sending a value to any enum-ish column, check the generated reference**:
`.claude/skills/clinic-vocab/reference/vocabularies.md`, regenerated with
`.claude/skills/clinic-vocab/extract-vocabularies.py`. Guessing costs a round trip every
time.

---

## Inspecting a live database

```bash
sqlcmd -S <server> -d <database> -U <user> -P <pw> -C -b -h -1 -W -Q "SET NOCOUNT ON; <query>"
```

- `-b` makes a failed batch set a non-zero exit code. Without it a broken script looks
  like success.
- `-C` trusts the server certificate; required against the local instance and Azure.
- `-y0` stops long values being truncated to 256 characters — needed when reading
  constraint definitions or `nvarchar(max)` columns.
- Azure dev (`sqldb-clinic-dev`) is **serverless with a 60-minute auto-pause**. The first
  connection after an idle period fails or hangs while it resumes. That is not an outage;
  retry.

`test-environment/` holds a seed/snapshot/reset trio for a disposable local database.

---

## Known problems, not yet fixed

- **`seed-access-rights-data.sql` line 26 has a hardcoded `USE [AyurvedicClinicMgmt]`**,
  so it ignores `-Database` and writes to whatever that name resolves to on the server.
  Azure SQL refuses `USE` so it fails safely there; against a local server it silently
  targets the wrong database.
- **192 unnamed column defaults** make `baseline-schema.sql` single-use and schema diffs
  unstable. Naming them in `dbo/Tables` would fix both.
- `.sqlproj` registers 26 of 53 files and is not a reliable index of anything.
