function Get-OdbcConnection {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$ServerName,

        [Parameter(Mandatory)]
        [string]$DatabaseName
    )

    Add-Type -AssemblyName System.Data

    $connectionString = @"
Driver={ODBC Driver 18 for SQL Server};
Server=tcp:$ServerName;
Database=$DatabaseName;
Authentication=ActiveDirectoryIntegrated;
Encrypt=yes;
TrustServerCertificate=yes;
"@

    try {
        $conn = New-Object System.Data.Odbc.OdbcConnection $connectionString
        $conn.Open()
        Write-Host "Connection successful to $ServerName\$DatabaseName" -ForegroundColor Green
        return $conn
    } catch {
        Write-Error "ODBC connection failed: $($_.Exception.Message)"
        return $null
    }
}


function Invoke-OdbcQuery {
    <#
    .SYNOPSIS
        Executes a SQL query over an open ODBC connection and returns the result as a DataTable.

    .PARAMETER Connection
        The open OdbcConnection object.

    .PARAMETER Query
        The SQL query string to execute.

    .OUTPUTS
        System.Data.DataTable

    .EXAMPLE
        $table = Invoke-OdbcQuery -Connection $conn -Query "SELECT * FROM sys.objects"
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [System.Data.Odbc.OdbcConnection]$Connection,

        [Parameter(Mandatory)]
        [string]$Query
    )

    $command = $Connection.CreateCommand()
    $command.CommandText = $Query

    $adapter = New-Object System.Data.Odbc.OdbcDataAdapter $command
    $table = New-Object System.Data.DataTable
    [void]$adapter.Fill($table)

    return $table
}


# Define parameters
$server = "your-server.database.windows.net"
$database = "your-db"
$query = "SELECT * FROM sys.objects"
$outputFile = "C:\Temp\QueryResults.csv"

# Optional: Get previous timestamp if file already exists
if (Test-Path $outputFile) {
    $oldTimestamp = (Get-Item $outputFile).LastWriteTime
    Write-Host "Old file modified time: $oldTimestamp"
}

# Get connection and run query
$conn = Get-OdbcConnection -ServerName $server -DatabaseName $database
if ($conn) {
    $results = Invoke-OdbcQuery -Connection $conn -Query $query

    # Export results to CSV
    $results | Export-Csv -Path $outputFile -NoTypeInformation -Encoding UTF8

    # Get updated timestamp
    $newTimestamp = (Get-Item $outputFile).LastWriteTime
    Write-Host "New file modified time: $newTimestamp"

    # Check for timestamp change
    if ($oldTimestamp -ne $null) {
        if ($oldTimestamp -ne $newTimestamp) {
            Write-Host "File has changed." -ForegroundColor Green
        } else {
            Write-Host "No changes detected." -ForegroundColor Yellow
        }
    }

    $conn.Close()
}
