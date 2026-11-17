# Applying the database

One command brings a database up to the schema in this repository.

```powershell
./Apply-Database.ps1 -Server . -Database AyurvedicClinicMgmt -User user1 -Password xxx
```

It applies everything in `manifest.txt` that has not run yet, in order, and records what
it ran in `dbo.schema_versions`. Running it twice is safe — the second run has nothing to
do and says so.

## The three things worth knowing

**`manifest.txt` is the order.** Not the filenames, not alphabetical. The seeds depend on
each other and a number prefix would not have said why. A `.sql` file that changes a
database and is *not* in the manifest **fails the run** — which is the point, because
thirteen tenancy migrations went missing from the `.sqlproj` exactly because nothing
noticed they were absent.

**Adopting a database that already has the schema** — this laptop's, or anything restored
from it — needs `-Baseline` once:

```powershell
./Apply-Database.ps1 -Server . -Database AyurvedicClinicMgmt -User user1 -Password xxx -Baseline
```

That records all the scripts as applied without running any. Only use it on a database
that genuinely has had them applied; on a fresh one it would record a lie.

**See what would happen** with `-DryRun`. Nothing is changed and it lists what it would
apply.

## Azure

Same command, different server. SQL authentication for now; when the App Services get
managed identities (INF-004) this grows an `-AccessToken` parameter rather than changing
shape.

```powershell
./Apply-Database.ps1 `
  -Server sql-clinic-nonprod-xxxx.database.windows.net `
  -Database sqldb-clinic-dev -User x -Password y
```

## Building an empty database

`manifest.txt` cannot do it on its own — those scripts are migrations, they reshape tables
that must already exist, and `dbo/Tables` registers only 28 of 53. Two generated files
close that gap. Both are produced from a working database by the exporters next to them,
so regenerating them for QA and UAT is one command each.

```powershell
# once, from a machine with the working local database
./deploy/Export-BaselineSchema.ps1  -OutFile ./deploy/baseline-schema.sql
./deploy/Export-SharedCatalogue.ps1 -OutFile ./deploy/baseline-shared-data.sql
```

Then, against the empty database, in this order:

```powershell
sqlcmd -S <server> -d <database> -U <user> -P <pw> -b -i deploy/baseline-schema.sql
sqlcmd -S <server> -d <database> -U <user> -P <pw> -b -i deploy/baseline-shared-data.sql
./deploy/Apply-Database.ps1 -Server <server> -Database <database> -User <user> -Password <pw> -Baseline
```

Then provision the first clinic through the API (`POST /api/platform/clinics`), which
creates its branch, roles, access groups, access levels and menu/screen grants.

### Why `-Baseline`, and why the seeds do not run

`baseline-schema.sql` is scripted from a database that has already had all thirteen tenancy
migrations applied, so its schema *is* the post-migration schema. Replaying the migrations
over it does not work and must not be attempted: `07-tenant-lifecycle.sql` backfills
`status` from `is_active` and then drops `is_active`, so against a baseline where that
column is already gone it fails outright. `-Baseline` records all nineteen as applied
without running any, which is the honest record — that schema has had them.

The six seed scripts are skipped for the same reason, plus one of their own: they predate
tenancy and insert into `role_access_groups` without a `tenant_id`, which the migrations
made mandatory. Their reference data arrives two other ways — the shared catalogue
(`menus`, `screens`, `sections`, `section_fields`) from `baseline-shared-data.sql`, and
everything tenant-scoped from provisioning.

`baseline-shared-data.sql` holds only tables that have no `tenant_id`, which is deliberate:
no patient, billing or clinical data can be in it.

### Verified

The whole sequence was run against an empty database and then driven through the API: 81
tables and 243 foreign keys created, 99 catalogue rows loaded, 19 scripts recorded,
`GET /health` returned 200 `Healthy`, a clinic provisioned with 7 roles and **75 menu
grants and 33 screen grants**, and that clinic's admin signed in and read
`/api/Patients` (200, against 401 anonymous). Without `baseline-shared-data.sql` the two
grant counts are zero and the clinic has no menu.

### `baseline-schema.sql` runs once

It is not re-runnable. 192 of this schema's 252 column defaults are unnamed, so SQL Server
names them with a hash of the object id, and such a name differs between databases — the
`IF NOT EXISTS` guards around them look for names the target will never have, and a second
run tries to re-add defaults that are already there. If a run fails, drop the database and
start again. (Naming those 192 defaults in `dbo/Tables` would fix it, and would make
schema diffs stable; it is worth doing and is not done.)

## What this does not do yet

**`seed-access-rights-data.sql` has a hardcoded `USE [AyurvedicClinicMgmt]` on line 26.**
It therefore ignores the `-Database` it was given and writes to whatever database that name
resolves to on the server. Azure SQL refuses `USE`, so it fails safely there; against a
local or on-prem server it silently targets the wrong database. The other eighteen scripts
are clean. Worth removing before anyone runs that script by hand again.

## If a script fails

It stops at the failure and attempts nothing after it. Everything before it stays applied
and recorded, so fixing the script and running again picks up where it stopped. A script is
recorded only *after* it succeeds — recording first would hide a half-finished run from the
next deployment.

## `changed since it was applied`

A script whose contents no longer match what was recorded. Often harmless — a fixed comment
— but it means this database did not necessarily get what the file now says. Worth a look
before trusting the environment.
