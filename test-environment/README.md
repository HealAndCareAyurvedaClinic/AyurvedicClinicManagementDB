# Test environment

A separate database with a known, restorable starting state, so a manual test
cycle always begins from the same place — and never touches the clinic's data.

Database: **`AyurvedicClinicMgmt_Test`**
Snapshot: `<SQL backup folder>\test-baseline.bak`

---

## The three things you will actually do

| When | Run | From |
|---|---|---|
| Once, to build it | `00` then `01` then `02` | see below |
| Between every test cycle | `03-reset-to-baseline.sql` | `master` |
| After deliberately changing the baseline | `02-snapshot-baseline.sql` | `master` |

**Reset takes about three seconds.** Run it before every cycle, not only when
something looks wrong — a cycle that starts on the previous cycle's leftovers is
not repeatable, and a defect found in it may not be reproducible.

---

## Building it the first time

**00 — create the database.** There is no script for this because it copies
whatever the schema currently is. From `master`:

```sql
BACKUP DATABASE AyurvedicClinicMgmt
  TO DISK = 'F:\SQLServer22\MSSQL16.MSSQLSERVER\MSSQL\Backup\_seed_source.bak'
  WITH INIT, COPY_ONLY, COMPRESSION;

RESTORE DATABASE AyurvedicClinicMgmt_Test
  FROM DISK = 'F:\SQLServer22\MSSQL16.MSSQLSERVER\MSSQL\Backup\_seed_source.bak'
  WITH MOVE 'AyurvedicClinicMgmt'     TO 'F:\...\DATA\AyurvedicClinicMgmt_Test.mdf',
       MOVE 'AyurvedicClinicMgmt_log' TO 'F:\...\DATA\AyurvedicClinicMgmt_Test_log.ldf',
       REPLACE, RECOVERY;

ALTER DATABASE AyurvedicClinicMgmt_Test SET RECOVERY SIMPLE;
```

**01 — seed the baseline.** Against `AyurvedicClinicMgmt_Test`:

```
sqlcmd -S . -U user1 -P *** -C -I -d AyurvedicClinicMgmt_Test -i 01-seed-test-baseline.sql
```

It clears every patient, visit, bill and stock row and rebuilds a known set. It
**refuses to run** against any database whose name does not end in `_Test`, so it
cannot be pointed at the clinic by accident.

**02 — take the snapshot.** Against `master`:

```
sqlcmd -S . -U user1 -P *** -C -I -d master -i 02-snapshot-baseline.sql
```

This writes the file that `03` restores from. Nothing can be reset until it exists.

---

## Pointing the application at it

The API takes its connection string from the environment, so nothing in the
repository changes:

```
ASPNETCORE_ENVIRONMENT=Development
ConnectionStrings__DefaultConnection=Data Source=.;Initial Catalog=AyurvedicClinicMgmt_Test;User Id=user1;Password=***;TrustServerCertificate=True;
```

Check which database is live before a cycle starts. Signing in as `divya` and
seeing more than five patients means the API is pointed at the clinic database,
not this one — **stop and fix that before testing anything**.

---

## What is in the baseline

**Logins** — password is the username followed by `@123`, except `admin`.

| Username | Password | Role | Menus |
|---|---|---|---|
| `chetan` | `chetan@123` | Admin | 30 |
| `divya` | `divya@123` | Receptionist | 17 |
| `anand` | `anand@123` | Doctor | 10 |
| `bhavna` | `bhavna@123` | Assistant Doctor | 10 |
| `esha` | `esha@123` | Therapist | 5 |
| `admin` | `admin123` | Admin | 30 |

**Patients** — five, with registration numbers `REG-T-0001` to `REG-T-0005`.

| Reg | Name | Notes |
|---|---|---|
| REG-T-0001 | Aarav Sharma | Has an appointment today |
| REG-T-0002 | Priya Nair | **Carries a known allergy** (Sulfa drugs); history marked complete |
| REG-T-0003 | Rohan Desai | The third row — `PAT-091` checks the right record opens |
| REG-T-0004 | Meera Iyer | No email, no emergency contact — the sparse case |
| REG-T-0005 | Vikram Rao | Oldest patient |

**Also present:** 2 doctors, 6 staff (including a male and a female therapist, so
the same-sex therapist rule can be tested), 4 medicines each with one batch,
2 suppliers, 3 appointments (two today, one last week, so the dashboard and
history are not empty), 3 Panchakarma therapies, 2 rooms, and a therapist
timetable for weekday mornings.

**Deliberately empty:** bills, payments, refunds, encounters, stock movements.
Test cases create those, and a reset must take them away again.

**Deliberately absent:** any name a test case creates — `Test Patient`,
`Full Fields`, `Allergy Test`, `Document Test`. If you see one of those in a
fresh baseline, the reset did not happen.

Appointment dates are relative to the day the baseline was seeded, so re-seed
(`01` then `02`) if "today's appointments" drift out of date.

---

## Changing the baseline

Everyone testing shares it, so change it deliberately:

1. Make the change in `01-seed-test-baseline.sql` — not by hand in the database,
   or the next rebuild loses it.
2. Run `01` against the test database.
3. Run `02` to take a new snapshot.
4. Tell the testers what changed; a case that names a patient may need updating.

---

## If something goes wrong

**The restore hangs.** Something is holding a connection. Stop the API and any
open SQL Server Management Studio query window, then run `03` again — it closes
connections itself, but an idle window can still get in the way.

**The database is stuck in single-user mode** after a failed restore:

```sql
ALTER DATABASE AyurvedicClinicMgmt_Test SET MULTI_USER;
```

**A login stops working.** Someone changed a password during a cycle. Reset.

**"The test database does not exist"** — build it with `00` and `01` first.
