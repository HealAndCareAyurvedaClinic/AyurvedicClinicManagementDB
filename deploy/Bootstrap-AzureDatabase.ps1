<#
.SYNOPSIS
    Brings an EMPTY database up to a usable environment, in one command.

.DESCRIPTION
    The three steps of a bootstrap, in the only order that works:

        1. baseline-schema.sql       the 83 tables, their keys and indexes
        2. baseline-shared-data.sql  the 99 rows of menu/screen/section catalogue
        3. Apply-Database.ps1 -Baseline   records the 24 manifest scripts as applied

    Step 3 records rather than runs, and that is not a shortcut. baseline-schema.sql is
    scripted from a database that already has all seventeen tenancy migrations, so its
    schema IS the post-migration schema. Replaying them fails:
    07-tenant-lifecycle.sql backfills status from is_active and then drops is_active, so
    against a baseline where that column is already gone it has nothing to read. The six
    seed scripts are skipped for the same reason plus one of their own - they predate
    tenancy and insert into role_access_groups without a tenant_id, which the migrations
    made mandatory. Their data arrives from the catalogue in step 2 and from provisioning
    a clinic afterwards.

    Afterwards, provision the first clinic through the API
    (POST /api/platform/clinics with the X-Provisioning-Key header), which creates its
    branch, roles, access groups, access levels and the menu/screen grants.

.PARAMETER Force
    Proceed even though the database already has tables. Off by default: this script
    writes a schema, and writing one over an environment somebody is using is not
    something to do by accident.

.EXAMPLE
    ./Bootstrap-AzureDatabase.ps1 `
      -Server sql-clinic-nonprod-cin-hc01.database.windows.net `
      -Database sqldb-clinic-dev -User sqldba -Password '<pw>'

    ./Bootstrap-AzureDatabase.ps1 -Server . -Database ScratchDb -Integrated
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string] $Server,
    [Parameter(Mandatory)][string] $Database,
    [string] $User,
    [string] $Password,
    [switch] $Integrated,
    [switch] $Force
)

$ErrorActionPreference = 'Stop'
$here = $PSScriptRoot

if (-not $Integrated -and (-not $User -or -not $Password)) {
    throw "Give either -Integrated, or both -User and -Password."
}

$sqlcmd = (Get-Command sqlcmd -ErrorAction SilentlyContinue).Source
if (-not $sqlcmd) { throw "sqlcmd is not on PATH. Install the SQL Server command line tools." }

$auth = if ($Integrated) { @('-E') } else { @('-U', $User, '-P', $Password) }
# -l 120: a serverless database that has auto-paused needs time to resume before it will
# accept a login at all. -b so a failing script fails this one.
$common = @('-S', $Server, '-d', $Database, '-C', '-b', '-l', '120') + $auth

$schema    = Join-Path $here 'baseline-schema.sql'
$catalogue = Join-Path $here 'baseline-shared-data.sql'
$applier   = Join-Path $here 'Apply-Database.ps1'
foreach ($f in @($schema, $catalogue, $applier)) {
    if (-not (Test-Path $f)) { throw "Missing $f" }
}

function Invoke-Scalar {
    param([string] $Query)
    $out = & $sqlcmd @($common + @('-h', '-1', '-W', '-Q', "SET NOCOUNT ON; $Query")) 2>&1
    if ($LASTEXITCODE -ne 0) { throw ($out | Out-String) }
    return ("$out" -split "`n" | Where-Object { $_.Trim() } | Select-Object -Last 1).Trim()
}

Write-Host ""
Write-Host "  $Database on $Server" -ForegroundColor Cyan
Write-Host ""

# ------------------------------------------------------------------ wake it up
# The connection attempt is itself what resumes a paused serverless database, and the
# first few are refused with "not currently available" while that happens. This is
# expected, not a fault, so it is retried - but a login failure is final and is not.
Write-Host -NoNewline "  connecting"
$tableCount = $null
for ($i = 1; $i -le 8; $i++) {
    try {
        $tableCount = [int](Invoke-Scalar "SELECT COUNT(*) FROM sys.tables;")
        break
    }
    catch {
        $msg = "$($_.Exception.Message)"
        if ($msg -match 'not currently available|is paused|try again|timeout expired') {
            Write-Host -NoNewline "."
            Start-Sleep -Seconds 20
            continue
        }
        Write-Host " failed" -ForegroundColor Red
        Write-Host ""
        Write-Host $msg -ForegroundColor Red
        exit 1
    }
}
if ($null -eq $tableCount) {
    Write-Host " gave up" -ForegroundColor Red
    Write-Host "  The database never finished resuming. Try again in a few minutes." -ForegroundColor Red
    exit 1
}
Write-Host " ok" -ForegroundColor Green

# ------------------------------------------------------------------ refuse to clobber
if ($tableCount -gt 0 -and -not $Force) {
    Write-Host ""
    Write-Host "  This database already has $tableCount tables." -ForegroundColor Yellow
    Write-Host "  Bootstrapping is for an empty one. Nothing was changed." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  If it is already bootstrapped there is nothing to do. If it is half-built," -ForegroundColor DarkGray
    Write-Host "  drop and recreate it rather than running this over the top: baseline-schema.sql" -ForegroundColor DarkGray
    Write-Host "  is not re-runnable, because most of this schema's column defaults are unnamed" -ForegroundColor DarkGray
    Write-Host "  and SQL Server names those differently in every database." -ForegroundColor DarkGray
    Write-Host ""
    exit 2
}

# ------------------------------------------------------------------ 1. schema
Write-Host -NoNewline "  1/3  tables, keys and indexes   "
$out = & $sqlcmd @($common + @('-i', $schema)) 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "FAILED" -ForegroundColor Red
    Write-Host ($out | Out-String) -ForegroundColor Red
    Write-Host "  Drop and recreate the database before trying again." -ForegroundColor Red
    exit 1
}
Write-Host "ok" -ForegroundColor Green

# ------------------------------------------------------------------ 2. catalogue
Write-Host -NoNewline "  2/3  shared catalogue rows      "
$out = & $sqlcmd @($common + @('-i', $catalogue)) 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "FAILED" -ForegroundColor Red
    Write-Host ($out | Out-String) -ForegroundColor Red
    exit 1
}
Write-Host "ok" -ForegroundColor Green

# ------------------------------------------------------------------ 3. ledger
Write-Host -NoNewline "  3/3  recording the manifest     "
# A hashtable, not an array: splatting an array passes its elements positionally, so
# '-Baseline' would arrive as a value rather than as the switch it is.
$applierParams = @{ Server = $Server; Database = $Database; Baseline = $true }
if ($Integrated) {
    $applierParams['Integrated'] = $true
} else {
    $applierParams['User'] = $User
    $applierParams['Password'] = $Password
}
# *>&1, not 2>&1: the applier reports progress with Write-Host, which goes to the
# information stream and would otherwise print through the middle of this line.
$out = & $applier @applierParams *>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "FAILED" -ForegroundColor Red
    Write-Host ($out | Out-String) -ForegroundColor Red
    exit 1
}
Write-Host "ok" -ForegroundColor Green

# ------------------------------------------------------------------ verify
$tables    = Invoke-Scalar "SELECT COUNT(*) FROM sys.tables;"
$fks       = Invoke-Scalar "SELECT COUNT(*) FROM sys.foreign_keys;"
$catalogueRows = Invoke-Scalar @"
SELECT (SELECT COUNT(*) FROM dbo.menus) + (SELECT COUNT(*) FROM dbo.screens)
     + (SELECT COUNT(*) FROM dbo.sections) + (SELECT COUNT(*) FROM dbo.section_fields);
"@
$ledger    = Invoke-Scalar "SELECT COUNT(*) FROM dbo.schema_versions;"
$tenants   = Invoke-Scalar "SELECT COUNT(*) FROM dbo.tenants;"

Write-Host ""
Write-Host "  tables          $tables      (expected 84, the 83 plus the ledger)"
Write-Host "  foreign keys    $fks     (expected 246)"
Write-Host "  catalogue rows  $catalogueRows      (expected 99)"
Write-Host "  recorded        $ledger      (expected 24)"
Write-Host "  clinics         $tenants       (expected 0 - provisioning creates the first)"
Write-Host ""

if ($tables -eq '84' -and $catalogueRows -eq '99' -and $ledger -eq '24') {
    Write-Host "  Done. Provision the first clinic through POST /api/platform/clinics." -ForegroundColor Green
} else {
    Write-Host "  Finished, but the numbers are not what was expected - worth a look." -ForegroundColor Yellow
}
Write-Host ""
