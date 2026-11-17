<#
    Scripts the table schema of a working local database into one file that can be run
    against an empty Azure SQL database.

    Why this exists: the scripts in deploy/manifest.txt are migrations - they reshape
    tables that must already exist - and the .sqlproj registers only 28 of 53 tables, so
    neither can build an empty database. The baseline has to come from a database that
    already works.

    Two passes, deliberately. Pass one writes every table with its primary keys, defaults,
    checks and indexes but NO foreign keys; pass two adds the foreign keys as ALTER TABLE
    statements at the end. Dependency ordering then does not matter at all, which is a
    great deal more robust than asking SMO to sort 53 tables correctly.

    Run it ONCE against an EMPTY database. It is not re-runnable, and deliberately not:
    192 of this schema's 252 column defaults are unnamed, so SQL Server names them with a
    hash of the object id (DF__access_gr__creat__38996AB5). Those names differ from one
    database to the next, so the IF NOT EXISTS guards SMO writes around them check for
    names that never exist in the target, and a second run tries to re-add 200-odd
    defaults that are already there. If a run fails, drop the database and start again -
    that is cheaper and more honest than pretending 322 constraints are idempotent.
#>
[CmdletBinding()]
param(
    [string] $Server   = '.',
    [string] $Database = 'AyurvedicClinicMgmt',
    [Parameter(Mandatory)][string] $OutFile
)

$ErrorActionPreference = 'Stop'

[void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.Smo')
[void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SmoExtended')
[void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.ConnectionInfo')

$srv = New-Object Microsoft.SqlServer.Management.Smo.Server $Server
$srv.ConnectionContext.StatementTimeout = 0

$db = $srv.Databases[$Database]
if ($null -eq $db) { throw "No database '$Database' on '$Server'." }

# dbo.schema_versions is excluded on purpose: Apply-Database.ps1 creates its own ledger
# with the exact definition it expects, and a scripted copy could drift from it.
$tables = @($db.Tables | Where-Object { -not $_.IsSystemObject -and $_.Schema -eq 'dbo' -and $_.Name -ne 'schema_versions' })
Write-Host ""
Write-Host "  $Database on $Server - $($tables.Count) tables" -ForegroundColor Cyan

function New-Options {
    $o = New-Object Microsoft.SqlServer.Management.Smo.ScriptingOptions
    $o.ScriptDrops         = $false
    $o.IncludeIfNotExists  = $true
    $o.ScriptSchema        = $true
    $o.ScriptData          = $false
    $o.NoFileGroup         = $true
    $o.ExtendedProperties  = $false
    $o.Triggers            = $false
    $o.WithDependencies    = $false
    $o.AnsiPadding         = $false
    $o.IncludeHeaders      = $false
    # Azure SQL Database: keeps ON [PRIMARY] and other on-premises-only syntax out.
    $o.TargetDatabaseEngineType = [Microsoft.SqlServer.Management.Common.DatabaseEngineType]::SqlAzureDatabase
    return $o
}

# ---------------------------------------------------------------- pass 1: tables
$tableOpts = New-Options
$tableOpts.DriPrimaryKey   = $true
$tableOpts.DriUniqueKeys   = $true
$tableOpts.DriChecks       = $true
$tableOpts.DriDefaults     = $true
$tableOpts.DriForeignKeys  = $false
$tableOpts.DriAllKeys      = $false
$tableOpts.DriAllConstraints = $false
$tableOpts.Indexes             = $true
$tableOpts.ClusteredIndexes    = $true
$tableOpts.NonClusteredIndexes = $true

$sb = [System.Text.StringBuilder]::new()
[void]$sb.AppendLine("/*")
[void]$sb.AppendLine("    Baseline table schema for $Database.")
[void]$sb.AppendLine("    Generated $(Get-Date -Format 'yyyy-MM-dd HH:mm') from $Server by Export-BaselineSchema.ps1.")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("    Run this against an EMPTY Azure SQL database, then run")
[void]$sb.AppendLine("    deploy/Apply-Database.ps1 against the same database to apply the")
[void]$sb.AppendLine("    migrations and seed the reference data.")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("    Tables first without foreign keys, then the foreign keys, so the order")
[void]$sb.AppendLine("    in which tables appear does not matter.")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("    RUN ONCE, against an EMPTY database. This is not re-runnable: most of this")
[void]$sb.AppendLine("    schema's column defaults are unnamed, SQL Server names those with a hash of")
[void]$sb.AppendLine("    the object id, and such a name differs between databases - so the guards")
[void]$sb.AppendLine("    around them look for names the target will never have. If this run fails,")
[void]$sb.AppendLine("    drop the database and start again rather than running it a second time.")
[void]$sb.AppendLine("*/")
[void]$sb.AppendLine("SET NOCOUNT ON;")
[void]$sb.AppendLine("SET XACT_ABORT ON;")
[void]$sb.AppendLine("GO")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("------------------------------------------------------------------ tables")
[void]$sb.AppendLine("")

$tableCount = 0
foreach ($t in ($tables | Sort-Object Name)) {
    foreach ($line in $t.Script($tableOpts)) {
        [void]$sb.AppendLine($line)
        [void]$sb.AppendLine("GO")
    }
    $tableCount++
}

# ---------------------------------------------------------------- pass 2: foreign keys
$fkOpts = New-Options
$fkOpts.DriForeignKeys = $true

[void]$sb.AppendLine("")
[void]$sb.AppendLine("------------------------------------------------------------------ foreign keys")
[void]$sb.AppendLine("")

$fkCount = 0
foreach ($t in ($tables | Sort-Object Name)) {
    foreach ($fk in $t.ForeignKeys) {
        foreach ($line in $fk.Script($fkOpts)) {
            [void]$sb.AppendLine($line)
            [void]$sb.AppendLine("GO")
        }
        $fkCount++
    }
}

$dir = Split-Path -Parent $OutFile
if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
[System.IO.File]::WriteAllText($OutFile, $sb.ToString(), (New-Object System.Text.UTF8Encoding $false))

$kb = [math]::Round((Get-Item $OutFile).Length / 1KB)
Write-Host "  $tableCount tables, $fkCount foreign keys -> $OutFile (${kb}KB)" -ForegroundColor Green
Write-Host ""
