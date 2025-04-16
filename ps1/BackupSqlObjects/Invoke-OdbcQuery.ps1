function Invoke-OdbcQueryToFile {
    <#
    .SYNOPSIS
        Executes a SQL query against Azure SQL using ODBC + SSO and writes result to file.

    .PARAMETER ServerName
        The fully qualified Azure SQL Server name (e.g., your-server.database.windows.net)

    .PARAMETER DatabaseName
        The database to connect to.

    .PARAMETER Query
        The SQL query to execute.

    .PARAMETER OutputFile
        Path to CSV output file. If provided, exports result and checks modified time.

    .EXAMPLE
        Invoke-OdbcQueryToFile -ServerName "your-server.database.windows.net" -DatabaseName "your-db" -Query "SELECT * FROM sys.tables" -OutputFile "C:\Temp\results.csv"
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$ServerName,

        [Parameter(Mandatory)]
        [string]$DatabaseName,

        [Parameter(Mandatory)]
        [string]$Query,

        [Parameter()]
        [string]$OutputFile
    )

    try {
        Add-Type -AssemblyName System.Data

        $connectionString = @"
Driver={ODBC Driver 18 for SQL Server};
Server=tcp:$ServerName;
Database=$DatabaseName;
Authentication=ActiveDirectoryIntegrated;
Encrypt=yes;
TrustServerCertificate=yes;
"@

        $conn = New-Object System.Data.Odbc.OdbcConnection $connectionString
        $conn.Open()

        $command = $conn.CreateCommand()
        $command.CommandText = $Query

        $adapter = New-Object System.Data.Odbc.OdbcDataAdapter $command
        $table = New-Object System.Data.DataTable
        [void]$adapter.Fill($table)

        if ($OutputFile) {
            if (Test-Path $OutputFile) {
                $oldTime = (Get-Item $OutputFile).LastWriteTime
                Write-Host "Previous file modified: $oldTime"
            }

            $table | Export-Csv -Path $OutputFile -NoTypeInformation -Encoding UTF8

            $newTime = (Get-Item $OutputFile).LastWriteTime
            Write-Host "New file modified: $newTime"

            if ($oldTime -and $oldTime -ne $newTime) {
                Write-Host "File was updated." -ForegroundColor Green
            } elseif ($oldTime) {
                Write-Host "File not changed." -ForegroundColor Yellow
            }
        } else {
            return $table
        }

        $conn.Close()
    } catch {
        Write-Error "Error executing query: $($_.Exception.Message)"
    }
}


Invoke-OdbcQueryToFile `
    -ServerName "your-server.database.windows.net" `
    -DatabaseName "your-db" `
    -Query "SELECT name FROM sys.tables" `
    -OutputFile "C:\Temp\tables.csv"
