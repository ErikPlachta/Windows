function Get-OdbcConnection {
    <#
    .SYNOPSIS
        Creates and returns an ODBC connection to Azure SQL using SSO (Active Directory Integrated Authentication).

    .DESCRIPTION
        Uses the ODBC Driver 17 or 18 for SQL Server to connect to an Azure SQL Database using
        Active Directory Integrated authentication (SSO on Azure AD-joined machines).

    .PARAMETER ServerName
        The fully qualified Azure SQL Server name (e.g., your-server.database.windows.net)

    .PARAMETER DatabaseName
        The name of the database to connect to.

    .EXAMPLE
        $conn = Get-OdbcConnection -ServerName "your-server.database.windows.net" -DatabaseName "your-db"
        $cmd = $conn.CreateCommand()
        $cmd.CommandText = "SELECT TOP 1 name FROM sys.objects"
        $cmd.ExecuteScalar()
    #>

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
TrustServerCertificate=no;
"@

    try {
        $conn = New-Object System.Data.Odbc.OdbcConnection
        $conn.ConnectionString = $connectionString
        $conn.Open()
        return $conn
    } catch {
        Write-Error "ODBC connection failed: $_"
        return $null
    }
}