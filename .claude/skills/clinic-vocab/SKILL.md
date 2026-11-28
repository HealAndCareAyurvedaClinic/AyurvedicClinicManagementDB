---
name: clinic-vocab
description: The fixed value-sets this database enforces with CHECK constraints — medicine_type, procedure_type, form, bill_type, appointment_status, dispense_status and 119 more. Use before sending any coded value to the clinic API or database, before writing a seed or test fixture, when a write fails with a constraint violation or an unhelpful 400, and when adding or widening a coded column. Most of these are invisible to the API's OpenAPI document, which types them as plain strings.
---

# Column vocabularies

## Why this exists

This schema restricts 127 columns to fixed sets of values, almost all enforced **only** by a
SQL Server `CHECK` constraint. The API's OpenAPI document types those columns as `string`,
so the allowed values appear nowhere a caller can read them. A value the API's own DTO
accepts can still be rejected by the database, and the failure arrives as a constraint
violation naming the constraint rather than the values.

Guessing is expensive and the guesses are plausible. Real examples:

- `procedure_type` sounds like a phase of treatment, so `Purvakarma` and `Shodhana` seem
  right. Both are rejected — the column holds the *karma itself*: `Vamana`, `Virechana`,
  `Basti`, `Nasya`, `Raktamokshana`, `Snehana`, `Swedana`, `Other`.
- `medicine_type` on a prescription sounds like a dosage form, so `Churna` or `Tablet` seem
  right. It is the *system of medicine*: `Classical_Ayurvedic`, `Patent_Ayurvedic`,
  `Herbal`, `Modern`, `Other`.
- `medicines_master.form` **is** the dosage form, and is enforced by a CHECK that OpenAPI
  does not describe at all.

## How to use it

**Read [`reference/vocabularies.md`](reference/vocabularies.md) before sending a coded
value.** It lists every vocabulary grouped by table, and opens with the columns whose name
is ambiguous across tables.

Check the table, not just the column name. Four column names carry **different vocabularies
in different tables**:

| Column | and it means something different in |
| --- | --- |
| `medicine_type` | `encounter_prescriptions` vs `current_medications` |
| `payment_status` | `appointments` vs `payments` |
| `status` | `follow_up_schedule` vs `tenants` |
| `action_type` | `appointment_history` vs `audit_log` |

## Keeping it current

`reference/vocabularies.md` is generated. Do not edit it by hand.

```bash
python .claude/skills/clinic-vocab/extract-vocabularies.py           # regenerate
python .claude/skills/clinic-vocab/extract-vocabularies.py --check   # fail if stale
```

It reads `deploy/baseline-schema.sql`, which is the only file describing the live schema —
`dbo/Tables/*.sql` is pre-tenancy and stale. **Regenerate after any migration that adds or
widens a coded column**, and consider wiring `--check` into CI so a widened constraint
cannot land without the reference following it.

## When the reference and the API disagree

They are two separate rules over the same column and either can be the wrong one:

- **API stricter than the database** — a value the database would accept is refused before
  it gets there. Widen the DTO's `RegularExpression`.
- **API looser than the database** — the request passes validation and fails on write, with
  a constraint violation instead of a readable message. Widen the CHECK with a migration,
  or tighten the DTO.

A migration that widens a CHECK is only half the change: the API DTO and any UI dropdown
hold their own copies of the same list. Find them before calling it done.

> ⚠️ `deploy/baseline-schema.sql` currently **predates migrations 14 and 15** — it has no
> `Pharmacist` staff type and still carries the `doctors` table. Vocabularies touched by
> those two migrations are therefore reported as they were *before* them. Re-export the
> baseline (`deploy/Export-BaselineSchema.ps1`) from a database that has all 15 applied,
> then regenerate this reference.
