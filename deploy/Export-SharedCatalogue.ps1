<#
    Scripts the rows of the shared catalogue - the product's own menu, screen, section
    and field definitions - into one file that can be run against a fresh database.

    Why this is separate from the schema: provisioning a clinic GRANTS access against
    these tables (it writes access_level_menus and access_level_screens) but never
    creates them, so a clinic provisioned into an empty database gets a working login
    and no menu. These rows are the product, not a clinic's data.

    Only tables with no tenant_id are exported, which is the point: nothing here can
    contain patient, billing or clinical data, so no clinic data leaves this machine.

    Idempotent per table: a table that already holds rows is left alone.
#>
[CmdletBinding()]
param(
    [string] $Server   = '.',
    [string] $Database = 'AyurvedicClinicMgmt',
    [Parameter(Mandatory)][string] $OutFile
)

$ErrorActionPreference = 'Stop'

# Parents before children: screens.menu_id -> menus, sections.screen_id -> screens,
# section_fields.section_id -> sections. subscription_plans is unrelated and last.
$ordered = @('menus', 'screens', 'sections', 'section_fields', 'subscription_plans')

$connStr = "Server=$Server;Database=$Database;Integrated Security=True;TrustServerCertificate=True;"
$conn = New-Object System.Data.SqlClient.SqlConnection $connStr
$conn.Open()

function Get-Rows {
    param([string] $Sql)
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = $Sql
    $cmd.CommandTimeout = 0
    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter $cmd
    $dt = New-Object System.Data.DataTable
    [void]$adapter.Fill($dt)
    # Unary comma: PowerShell enumerates a DataTable into its DataRows on output, which
    # would make every .Rows.Count below read zero and silently export nothing.
    return ,$dt
}

function Format-SqlLiteral {
    param($Value, [string] $TypeName)
    if ($null -eq $Value -or $Value -is [System.DBNull]) { return 'NULL' }
    switch ($TypeName) {
        'System.String'   { return "N'" + ($Value -replace "'", "''") + "'" }
        'System.Boolean'  { if ($Value) { return '1' } else { return '0' } }
        'System.DateTime' { return "'" + $Value.ToString('yyyy-MM-ddTHH:mm:ss.fff') + "'" }
        'System.Guid'     { return "'" + $Value.ToString() + "'" }
        'System.Byte[]'   { return '0x' + [System.BitConverter]::ToString($Value).Replace('-','') }
        default           { return [string]$Value }
    }
}

$sb = [System.Text.StringBuilder]::new()
[void]$sb.AppendLine("/*")
[void]$sb.AppendLine("    Shared catalogue rows for $Database - menus, screens, sections, fields.")
[void]$sb.AppendLine("    Generated $(Get-Date -Format 'yyyy-MM-dd HH:mm') from $Server by Export-SharedCatalogue.ps1.")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("    Run AFTER baseline-schema.sql and BEFORE provisioning the first clinic.")
[void]$sb.AppendLine("    Provisioning grants access against these rows; it does not create them, so a")
[void]$sb.AppendLine("    clinic provisioned without them gets a login and an empty menu.")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("    Only tables without tenant_id are here, so this file holds no clinic data.")
[void]$sb.AppendLine("    Each table is skipped if it already has rows, so re-running is safe.")
[void]$sb.AppendLine("*/")
[void]$sb.AppendLine("SET NOCOUNT ON;")
[void]$sb.AppendLine("SET XACT_ABORT ON;")
[void]$sb.AppendLine("GO")
[void]$sb.AppendLine("")

$total = 0
foreach ($table in $ordered) {
    $exists = Get-Rows "SELECT 1 FROM sys.tables WHERE name = '$table' AND SCHEMA_NAME(schema_id) = 'dbo'"
    if ($exists.Rows.Count -eq 0) { Write-Host "  skipped (no such table): $table" -ForegroundColor DarkGray; continue }

    # Refuse to export anything tenant-scoped, whatever the list above says.
    $tenantCol = Get-Rows "SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.$table') AND name = 'tenant_id'"
    if ($tenantCol.Rows.Count -gt 0) { throw "dbo.$table has a tenant_id and must not be exported as shared data." }

    $dt = Get-Rows "SELECT * FROM dbo.[$table]"
    if ($dt.Rows.Count -eq 0) { Write-Host "  $table - no rows" -ForegroundColor DarkGray; continue }

    $hasIdentity = (Get-Rows "SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('dbo.$table')").Rows.Count -gt 0

    # Computed columns cannot be inserted into.
    $computed = @((Get-Rows "SELECT name FROM sys.computed_columns WHERE object_id = OBJECT_ID('dbo.$table')").Rows | ForEach-Object { $_['name'] })
    $cols = @($dt.Columns | Where-Object { $computed -notcontains $_.ColumnName })
    $colList = ($cols | ForEach-Object { "[$($_.ColumnName)]" }) -join ', '

    [void]$sb.AppendLine("------------------------------------------------------------------ $table ($($dt.Rows.Count) rows)")
    [void]$sb.AppendLine("IF NOT EXISTS (SELECT 1 FROM dbo.[$table])")
    [void]$sb.AppendLine("BEGIN")
    if ($hasIdentity) { [void]$sb.AppendLine("    SET IDENTITY_INSERT dbo.[$table] ON;") }

    foreach ($row in $dt.Rows) {
        $vals = foreach ($c in $cols) { Format-SqlLiteral -Value $row[$c.ColumnName] -TypeName $c.DataType.FullName }
        [void]$sb.AppendLine("    INSERT INTO dbo.[$table] ($colList) VALUES (" + ($vals -join ', ') + ");")
    }

    if ($hasIdentity) { [void]$sb.AppendLine("    SET IDENTITY_INSERT dbo.[$table] OFF;") }
    [void]$sb.AppendLine("    PRINT '  $table seeded';")
    [void]$sb.AppendLine("END")
    [void]$sb.AppendLine("ELSE PRINT '  $table already has rows - left alone';")
    [void]$sb.AppendLine("GO")
    [void]$sb.AppendLine("")

    Write-Host "  $table - $($dt.Rows.Count) rows" -ForegroundColor Green
    $total += $dt.Rows.Count
}

$conn.Close()

$dir = Split-Path -Parent $OutFile
if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
[System.IO.File]::WriteAllText($OutFile, $sb.ToString(), (New-Object System.Text.UTF8Encoding $false))

Write-Host ""
Write-Host "  $total rows -> $OutFile" -ForegroundColor Cyan
Write-Host ""
