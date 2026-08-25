<#
.SYNOPSIS
    Brings a database up to the schema in this repository.

.DESCRIPTION
    Applies every script in deploy/manifest.txt, in order, skipping any already applied,
    and records what it ran in dbo.schema_versions.

    Written because the scripts were applied by hand. That was workable against one
    database on one laptop and stops being workable at three environments: the same
    scripts, in the right order, three times, with nothing recording what had already
    run. Drift between QA and UAT would not have been a risk but a certainty, and schema
    drift is a miserable thing to diagnose from a failing test.

    The scripts are all written to be idempotent, so re-running one is safe. The version
    table is not there to make them safe — it is there so an environment can say what it
    is running, and so a deployment does not take longer every time.

.PARAMETER Baseline
    Records every script as applied WITHOUT running any of them. For adopting a database
    that already has the schema — this laptop's, for one. Never use it on a database that
    has not actually had the scripts applied.

.EXAMPLE
    ./Apply-Database.ps1 -Server . -Database AyurvedicClinicMgmt -User user1 -Password xxx -DryRun
    ./Apply-Database.ps1 -Server . -Database AyurvedicClinicMgmt -Integrated -Baseline
    ./Apply-Database.ps1 -Server sql-clinic-nonprod.database.windows.net -Database sqldb-clinic-dev -User x -Password y
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string] $Server,
    [Parameter(Mandatory)][string] $Database,
    [string] $User,
    [string] $Password,
    [switch] $Integrated,
    [switch] $DryRun,
    [switch] $Baseline
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$manifestPath = Join-Path $PSScriptRoot 'manifest.txt'

if (-not $Integrated -and (-not $User -or -not $Password)) {
    throw "Give either -Integrated, or both -User and -Password."
}

# sqlcmd rather than a SQL client library: it is already on any machine with SQL tooling,
# it is on the Microsoft-hosted build agents, and it understands GO — which matters,
# because these scripts use batch separators and splitting on them by hand is a known
# way to break DDL that must stand alone in its own batch.
$sqlcmd = (Get-Command sqlcmd -ErrorAction SilentlyContinue).Source
if (-not $sqlcmd) { throw "sqlcmd is not on PATH. Install the SQL Server command line tools." }

$auth = if ($Integrated) { @('-E') } else { @('-U', $User, '-P', $Password) }
# -b so a failing script fails this script. Without it sqlcmd reports the error and
# exits zero, and a broken deployment looks like a successful one.
$common = @('-S', $Server, '-d', $Database, '-C', '-b') + $auth

function Invoke-Sql {
    param([string] $Query, [switch] $NoHeaders)
    $args = $common + @('-Q', $Query)
    if ($NoHeaders) { $args += @('-h', '-1', '-W') }
    $out = & $sqlcmd @args 2>&1
    if ($LASTEXITCODE -ne 0) { throw ($out | Out-String) }
    return $out
}

function Invoke-SqlFile {
    param([string] $Path)
    # -i, not -Q with the file contents: sqlcmd handles the file's own batching and
    # encoding, and error line numbers then point at the real file.
    $out = & $sqlcmd @($common + @('-i', $Path)) 2>&1
    if ($LASTEXITCODE -ne 0) { throw ($out | Out-String) }
    return $out
}

function Get-Checksum {
    param([string] $Path)
    (Get-FileHash -Path $Path -Algorithm SHA256).Hash
}

Write-Host ""
Write-Host "  $Database on $Server" -ForegroundColor Cyan
Write-Host ""

# ------------------------------------------------------------------ the manifest
if (-not (Test-Path $manifestPath)) { throw "No manifest at $manifestPath" }

$planned = Get-Content $manifestPath |
    ForEach-Object { $_.Trim() } |
    Where-Object { $_ -and -not $_.StartsWith('#') }

# Anything that changes a database and is not in the manifest is a script somebody will
# forget to run. Table definitions are the .sqlproj's business, and these two are tools
# rather than migrations.
$notMigrations = @('restore.sql')
$onDisk = Get-ChildItem -Path $root -Filter *.sql -Recurse |
    Where-Object {
        $_.FullName -notmatch '\\(bin|obj|dbo|test-environment)\\' -and
        $notMigrations -notcontains $_.Name
    } |
    ForEach-Object { (Resolve-Path -Relative -Path $_.FullName -RelativeBasePath $root) -replace '^\.[\\/]','' -replace '\\','/' }

$unregistered = $onDisk | Where-Object { $planned -notcontains $_ }
if ($unregistered) {
    Write-Host "  These scripts are not in the manifest:" -ForegroundColor Red
    $unregistered | ForEach-Object { Write-Host "     $_" -ForegroundColor Red }
    Write-Host ""
    throw "Every script that changes a database must be in deploy/manifest.txt, in the order it runs."
}

$missing = $planned | Where-Object { -not (Test-Path (Join-Path $root $_)) }
if ($missing) { throw "The manifest names scripts that do not exist: $($missing -join ', ')" }

# ------------------------------------------------------------------ the ledger
Invoke-Sql -Query @"
IF OBJECT_ID('dbo.schema_versions', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.schema_versions (
        script_name  NVARCHAR(260) NOT NULL CONSTRAINT PK_schema_versions PRIMARY KEY,
        checksum     CHAR(64)      NOT NULL,
        applied_at   DATETIME2     NOT NULL CONSTRAINT DF_schema_versions_at DEFAULT (SYSUTCDATETIME()),
        applied_by   NVARCHAR(128) NOT NULL CONSTRAINT DF_schema_versions_by DEFAULT (SUSER_SNAME()),
        duration_ms  INT           NULL
    );
END
"@ | Out-Null

$appliedRows = Invoke-Sql -NoHeaders -Query `
    "SET NOCOUNT ON; SELECT script_name + '|' + checksum FROM dbo.schema_versions;"

$applied = @{}
foreach ($row in $appliedRows) {
    $line = "$row".Trim()
    if ($line -and $line.Contains('|')) {
        $parts = $line.Split('|', 2)
        $applied[$parts[0].Trim()] = $parts[1].Trim()
    }
}

# ------------------------------------------------------------------ what needs doing
$todo = @()
$drifted = @()

foreach ($script in $planned) {
    $full = Join-Path $root $script
    $hash = Get-Checksum $full

    if ($applied.ContainsKey($script)) {
        # A script that changed after it was applied is worth saying out loud. It is not
        # necessarily wrong — a fixed typo in a comment is harmless — but it means this
        # database did not necessarily get what the file now says.
        if ($applied[$script] -ne $hash) { $drifted += $script }
        continue
    }
    $todo += [pscustomobject]@{ Script = $script; Path = $full; Checksum = $hash }
}

foreach ($d in $drifted) {
    Write-Host "  changed since it was applied: $d" -ForegroundColor Yellow
}
if ($drifted) { Write-Host "" }

if (-not $todo) {
    Write-Host "  Already up to date — $($applied.Count) scripts applied." -ForegroundColor Green
    Write-Host ""
    exit 0
}

Write-Host "  $($todo.Count) to apply:" -ForegroundColor Cyan
$todo | ForEach-Object { Write-Host "     $($_.Script)" }
Write-Host ""

if ($DryRun) {
    Write-Host "  Dry run — nothing was changed." -ForegroundColor Yellow
    Write-Host ""
    exit 0
}

# ------------------------------------------------------------------ apply
$failed = $null

foreach ($item in $todo) {
    $label = $item.Script.PadRight(46)

    if ($Baseline) {
        Write-Host "  recorded  $label" -ForegroundColor DarkGray
        $ms = 0
    }
    else {
        Write-Host -NoNewline "  applying  $label"
        $watch = [System.Diagnostics.Stopwatch]::StartNew()
        try {
            Invoke-SqlFile -Path $item.Path | Out-Null
            $watch.Stop()
            $ms = [int]$watch.ElapsedMilliseconds
            Write-Host " ok  ${ms}ms" -ForegroundColor Green
        }
        catch {
            $watch.Stop()
            Write-Host " FAILED" -ForegroundColor Red
            Write-Host ""
            Write-Host ($_.Exception.Message) -ForegroundColor Red
            $failed = $item.Script
            break
        }
    }

    # Recorded only after it succeeded. A script that failed halfway must be able to run
    # again — recording it first would hide the failure from the next deployment.
    $name = $item.Script.Replace("'", "''")
    Invoke-Sql -Query @"
INSERT INTO dbo.schema_versions (script_name, checksum, duration_ms)
VALUES ('$name', '$($item.Checksum)', $ms);
"@ | Out-Null
}

Write-Host ""

if ($failed) {
    Write-Host "  Stopped at $failed. Nothing after it was attempted." -ForegroundColor Red
    Write-Host "  Fix it and run again — everything before it stays applied." -ForegroundColor Red
    Write-Host ""
    exit 1
}

if ($Baseline) {
    Write-Host "  Baselined: $($todo.Count) scripts recorded as applied, none run." -ForegroundColor Green
} else {
    Write-Host "  Done: $($todo.Count) applied." -ForegroundColor Green
}
Write-Host ""
