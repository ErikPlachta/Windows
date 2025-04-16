function Get-ConnectionString {
    <#
    .SYNOPSIS
        Generates a Microsoft.Data.SqlClient connection with an Azure AD access token.

    .DESCRIPTION
        Uses MSAL.PS to acquire an interactive login token for Azure SQL.
        Requires the MSAL.PS and Microsoft.Data.SqlClient libraries.

    .PARAMETER ServerName
        The fully qualified name of the Azure SQL server.

    .PARAMETER DatabaseName
        The database name to connect to.

    .OUTPUTS
        A connected Microsoft.Data.SqlClient.SqlConnection object with AccessToken set.

    .EXAMPLE
        $conn = Get-ConnectionString -ServerName "myserver.database.windows.net" -DatabaseName "mydb"
        $cmd = $conn.CreateCommand()
        $cmd.CommandText = "SELECT 1"
        $cmd.ExecuteScalar()
    #>

    param (
        [Parameter(Mandatory)]
        [string]$ServerName,

        [Parameter(Mandatory)]
        [string]$DatabaseName
    )

    # Use default public client ID and default Azure SQL scope
    $clientId = "04b07795-8ddb-461a-bbee-02f9e1bf7b46"
    $scope = "https://database.windows.net//.default"

    try {
        $tokenResponse = Get-MsalToken -ClientId $clientId -Scopes $scope -ErrorAction Stop
    } catch {
        Write-Error "Failed to get Azure AD token via MSAL: $_"
        return $null
    }

    try {
        Add-Type -AssemblyName "Microsoft.Data.SqlClient"
    } catch {
        Write-Error "Microsoft.Data.SqlClient is not installed. Run: Install-Package Microsoft.Data.SqlClient -Scope CurrentUser"
        return $null
    }

    $conn = New-Object Microsoft.Data.SqlClient.SqlConnection
    $conn.ConnectionString = "Server=tcp:$ServerName;Database=$DatabaseName;"
    $conn.AccessToken = $tokenResponse.AccessToken
    $conn
}