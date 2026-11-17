# CI/CD — database (Dev)

Companion to [`deploy/README.md`](../deploy/README.md), which explains what
`Apply-Database.ps1` does. This covers running it from GitHub Actions instead of a laptop.

GitHub Actions rather than Azure DevOps, for the same reason as the API repo: the code,
the PRs and the reviews are already on GitHub, and App Service / Azure SQL both support
OIDC federated login, so no long-lived Azure credential has to be stored.

| Workflow | Trigger | Does |
|---|---|---|
| [`db-ci.yml`](../.github/workflows/db-ci.yml) | PR into `develop`/`main` | `-ValidateOnly`: every `.sql` that changes a database is in `deploy/manifest.txt`, and the manifest names nothing missing. No database, no credentials, seconds. |
| [`db-cd-dev.yml`](../.github/workflows/db-cd-dev.yml) | push to `develop`/`main` touching `tenancy/`, `seed-*.sql` or `deploy/` | opens the SQL firewall for the runner, logs a dry run, applies pending migrations, closes the firewall |

## Read this before the first run

**The pipeline cannot create the DEV database from nothing.** Everything in `manifest.txt`
is a migration — it reshapes tables that must already exist. The table definitions live in
`dbo/Tables` and are the `.sqlproj`'s business, where only 28 of 53 are currently
registered. So the first run against an empty `sqldb-clinic-dev` will fail on
`tenancy/01-add-tenant-and-branch.sql`, correctly, because there is nothing to alter.

One-time bootstrap, by hand:

1. Get the baseline schema into `sqldb-clinic-dev` — export it from a known-good database
   (the laptop's `AyurvedicClinicMgmt`) with `sqlpackage` or the SSMS "Generate Scripts"
   wizard, and run it against the Azure database.
2. If that export already *included* the tenancy changes, run the applier once with
   `-Baseline` against DEV so the ledger records them as applied rather than re-running
   them. If it was a pre-tenancy schema, skip this — let the pipeline apply them.
3. From then on the pipeline owns it.

Closing that gap properly — registering all 53 tables in the `.sqlproj` so an empty
database can be built from source — is its own piece of work and is the thing that makes
QA and UAT provisionable without a laptop in the loop.

## Deployment order

Apply the database **before** the API. A migration that adds a column is harmless to the
running old API; an API that expects a column the database has not got is not. The two
repos deploy independently today, so this is a sequencing rule to follow by hand: merge and
let `db-cd-dev` finish, then merge the API. Wiring the API's deploy to wait on the
database's would need a cross-repo `repository_dispatch` and a PAT — worth doing once the
sequence actually gets tight, not before.

## One-time Azure setup

The identity, federated credential and `dev` environment from the API repo's
`docs/cicd-setup.md` are reused, with two additions.

**A federated credential for this repo.** The subject is per-repository, so the DEV one
covers the API repo only:

```bash
RG=rg-clinic-nonprod-cin-01
IDENTITY=id-github-clinic-api-dev-cin-01
SQLSERVER=sql-clinic-nonprod-cin-01
SUB=161e349a-d1a6-4061-b6af-b3c50b962dd9

az identity federated-credential create \
  --name github-db-dev-environment \
  --identity-name "$IDENTITY" \
  --resource-group "$RG" \
  --issuer https://token.actions.githubusercontent.com \
  --subject "repo:HealAndCareAyurvedaClinic/AyurvedicClinicManagementDB:environment:dev" \
  --audiences api://AzureADTokenExchange
```

**Rights to manage firewall rules** on the SQL server, which is all the deploy job asks of
Azure itself — the schema change goes over SQL auth, not ARM:

```bash
PRINCIPAL_ID=$(az identity show -n "$IDENTITY" -g "$RG" --query principalId -o tsv)

az role assignment create \
  --assignee-object-id "$PRINCIPAL_ID" \
  --assignee-principal-type ServicePrincipal \
  --role "SQL Server Contributor" \
  --scope "/subscriptions/$SUB/resourceGroups/$RG/providers/Microsoft.Sql/servers/$SQLSERVER"
```

## One-time GitHub setup

An Environment named exactly **`dev`** in *this* repository.

Variables:

| Variable | Value |
|---|---|
| `AZURE_CLIENT_ID` | client id of `id-clinic-api-dev-cin-01` |
| `AZURE_TENANT_ID` | `e6dfbdf2-f817-4873-9cb1-1f88fc637153` |
| `AZURE_SUBSCRIPTION_ID` | `161e349a-d1a6-4061-b6af-b3c50b962dd9` |
| `AZURE_RESOURCE_GROUP` | the SQL server's resource group |
| `AZURE_SQL_SERVER` | short name, e.g. `sql-clinic-nonprod-cin-01` — not the FQDN |
| `AZURE_SQL_DATABASE` | `sqldb-clinic-dev` |

Secrets — these genuinely are secrets, unlike the OIDC ids above:

| Secret | Value |
|---|---|
| `SQL_ADMIN_USER` | a SQL login with DDL rights on the DEV database |
| `SQL_ADMIN_PASSWORD` | its password |

Then require the **`Validate manifest`** check to pass on PRs into `develop` and `main`.

## Why the firewall opens and closes

GitHub's hosted runners have dynamic public IPs and are not Azure, so the SQL server's
"Allow Azure services and resources to access this server" setting does not admit them.
The job adds a single-IP rule named `gh-<run id>`, and removes it in an `always()` step so
a failed deploy does not leave the hole behind. The alternative — whitelisting GitHub's
published ranges permanently — is thousands of addresses standing open.

If you ever see a `gh-*` rule lying around on the SQL server, a run was killed between
opening and closing it; it is safe to delete.

## Known follow-ups

- **SQL authentication.** `deploy/README.md` already anticipates this: once the App
  Services have managed identities, the applier grows an `-AccessToken` parameter and
  `SQL_ADMIN_USER` / `SQL_ADMIN_PASSWORD` can be deleted. A password in GitHub secrets is
  the weakest link in this pipeline.
- **`develop` does not exist** in this repo yet; DEV deploys from `main` until it does.
- **28 of 53 tables are registered in the `.sqlproj`** — see the bootstrap note above.
- **No QA/UAT.** They are a copy of the deploy job with their own environment, their own
  federated credential subject, and a required reviewer on `uat`.
