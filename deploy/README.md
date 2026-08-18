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

## What this does not do yet

**It cannot build an empty database.** The scripts in `manifest.txt` are migrations — they
reshape tables that must already exist. The table definitions live in `dbo/Tables` and are
the `.sqlproj`'s business, and only 28 of 53 are currently registered there.

So a brand-new DEV database needs a baseline schema first, from a backup or an export of a
known-good database, and then this script from that point on. Closing that gap is its own
piece of work and needs `sqlpackage`, which is not installed here.

## If a script fails

It stops at the failure and attempts nothing after it. Everything before it stays applied
and recorded, so fixing the script and running again picks up where it stopped. A script is
recorded only *after* it succeeds — recording first would hide a half-finished run from the
next deployment.

## `changed since it was applied`

A script whose contents no longer match what was recorded. Often harmless — a fixed comment
— but it means this database did not necessarily get what the file now says. Worth a look
before trusting the environment.
