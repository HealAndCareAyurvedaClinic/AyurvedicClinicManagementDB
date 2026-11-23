# One-off scripts

Scripts written for the data in **one specific database**, run by hand, once.

They are not migrations. A migration describes a change every database must get, in a
fixed order, recorded in `dbo.schema_versions`. These describe a repair to a particular
database's particular rows — an id remap, a backfill, a correction — and replaying them
somewhere else would be wrong.

So they are deliberately **not** in `deploy/manifest.txt`, and `Apply-Database.ps1`
excludes this directory from its "every script is registered" check. Nothing runs them
automatically. You run them, against the one database they name, with `sqlcmd`.

## Naming

`YYYY-MM-DD-<environment>-<what-it-does>.sql`

The date and environment are part of the name because that is the question asked later:
*what was done to DEV, and when?*

## Writing one

Follow what `tenancy/*.sql` already does:

- Guard the whole thing so a second run is a no-op.
- **Refuse rather than guess.** `THROW` with a message that says what is wrong and what
  to do about it. A script that silently skips the rows it does not understand leaves a
  database nobody can reason about.
- Wrap the changes in a transaction with `SET XACT_ABORT ON`.
- `PRINT` a count for each thing it changed, so the output is a record.
- Say in the header *why the normal migration could not be used*. That is the only
  reason the file exists, and it is the first thing the next person needs.

## What is here

Nothing at present.

`2026-11-22-dev-doctors-into-staff-with-data.sql` lived here until the doctors-into-staff
change was reverted. It repaired a database to a shape the schema no longer has, so it was
removed with the migration it belonged to. Both are in the history if that change is ever
revisited.
