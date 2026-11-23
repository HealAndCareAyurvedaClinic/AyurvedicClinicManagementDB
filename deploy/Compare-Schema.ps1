<#
.SYNOPSIS
    Compares the schema of two databases and reports the differences.

.DESCRIPTION
    Takes a normalised fingerprint of each database -- one line per table, column,
    default, check, key, index, foreign key and module -- and diffs them. See
    schema-fingerprint.sql for what is compared and why constraint names are mostly
    ignored (192 of this schema's defaults are unnamed, so their names are per-database
    hashes and would swamp a name-keyed diff).

    This answers the question the ledger cannot. dbo.schema_versions records what a
    database was *told* it has; this reports what it *actually* has. On a database built
    by Bootstrap-AzureDatabase.ps1 the two disagree, because that finishes with
    -Baseline, which records every manifest script as applied without running it.

.PARAMETER Left
.PARAMETER Right
    Each is 'server/database' -- for example '.' plus a database, or the Azure host.
    Use -LeftUser/-LeftPassword for SQL authentication, or omit for Windows.

.EXAMPLE
    # The two local databases
    ./deploy/Compare-Schema.ps1 -LeftServer . -LeftDatabase AyurvedicClinicMgmt `
                                -RightServer . -RightDatabase AyurvedicClinicMgmt_Test

.EXAMPLE
    # Local (all migrations applied) against Azure dev -- what is dev missing?
    ./deploy/Compare-Schema.ps1 `
        -LeftServer . -LeftDatabase AyurvedicClinicMgmt `
        -RightServer sql-clinic-nonprod-cin-hc01.database.windows.net `
        -RightDatabase sqldb-clinic-dev -RightUser sqldba -RightPassword '<pw>'

.NOTES
    Azure dev is serverless with a 60-minute auto-pause. The first connection after an
    idle period can take up to a minute while it resumes, or fail outright; retry.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string] $LeftServer,
    [Parameter(Mandatory)][string] $LeftDatabase,
    [string] $LeftUser,
    [string] $LeftPassword,

    [Parameter(Mandatory)][string] $RightServer,
    [Parameter(Mandatory)][string] $RightDatabase,
    [string] $RightUser,
    [string] $RightPassword,

    # Keep the two fingerprint files instead of discarding them.
    [string] $OutDir
)

$ErrorActionPreference = 'Stop'
$query = Join-Path $PSScriptRoot 'schema-fingerprint.sql'
if (-not (Test-Path $query)) { throw "No fingerprint query at $query" }

function Get-Fingerprint {
    param($Server, $Database, $User, $Password, $Label)

    $args = @('-S', $Server, '-d', $Database, '-C', '-b', '-y0', '-l', '120', '-i', $query)
    if ($User) { $args += @('-U', $User, '-P', $Password) } else { $args += '-E' }

    Write-Host "  reading $Label ($Database on $Server)" -ForegroundColor Cyan
    $out = & sqlcmd @args 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Could not read $Label`: $($out -join [Environment]::NewLine)"
    }

    # -y0 cannot be combined with -h -1, so sqlcmd emits a column header and a line of
    # dashes. Drop them, and any trailing blank line, rather than diffing them.
    @($out | Select-Object -Skip 2 | Where-Object { $_.Trim() -ne '' })
}

$left  = Get-Fingerprint $LeftServer  $LeftDatabase  $LeftUser  $LeftPassword  'left'
$right = Get-Fingerprint $RightServer $RightDatabase $RightUser $RightPassword 'right'

if ($OutDir) {
    if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir | Out-Null }
    $left  | Set-Content (Join-Path $OutDir 'left.txt')
    $right | Set-Content (Join-Path $OutDir 'right.txt')
}

Write-Host ""
Write-Host "  left  $LeftDatabase  - $($left.Count) schema facts"  -ForegroundColor Gray
Write-Host "  right $RightDatabase - $($right.Count) schema facts" -ForegroundColor Gray
Write-Host ""

$diff = Compare-Object -ReferenceObject $left -DifferenceObject $right

if (-not $diff) {
    Write-Host "  The two schemas are identical." -ForegroundColor Green
    exit 0
}

# '<=' is in the left only, '=>' in the right only. A changed column shows as one of
# each, which is the honest representation: the diff cannot know they are the same
# column, and showing both lines says more than guessing would.
$onlyLeft  = @($diff | Where-Object SideIndicator -eq '<=' | ForEach-Object InputObject)
$onlyRight = @($diff | Where-Object SideIndicator -eq '=>' | ForEach-Object InputObject)

if ($onlyLeft) {
    Write-Host "  In $LeftDatabase only -- $($onlyLeft.Count) " -ForegroundColor Yellow -NoNewline
    Write-Host "(missing from $RightDatabase):" -ForegroundColor Yellow
    $onlyLeft | ForEach-Object { Write-Host "    - $_" }
    Write-Host ""
}
if ($onlyRight) {
    Write-Host "  In $RightDatabase only -- $($onlyRight.Count) " -ForegroundColor Yellow -NoNewline
    Write-Host "(missing from $LeftDatabase):" -ForegroundColor Yellow
    $onlyRight | ForEach-Object { Write-Host "    + $_" }
    Write-Host ""
}

Write-Host "  $($diff.Count) differences." -ForegroundColor Yellow
exit 1
