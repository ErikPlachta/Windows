# Example for ensuring Pester is installed
& "$PSScriptRoot\Install-RequiredModules.ps1" -RequiredModules @("Pester")

<#
.SYNOPSIS
    Ensures required PowerShell modules are installed for the local user.

.DESCRIPTION
    Checks for the presence of required modules (like Pester). 
    Installs any that are missing into the current user scope.

.PARAMETER RequiredModules
    A list of module names to check and install.

.EXAMPLE
    Install-RequiredModules -RequiredModules @("Pester", "Az.Accounts")
#>

param (
    [string[]]$RequiredModules = @("Pester")
)

foreach ($module in $RequiredModules) {
    $installed = Get-Module -ListAvailable -Name $module

    if (-not $installed) {
        Write-Host "Installing missing module: $module" -ForegroundColor Yellow
        try {
            Install-Module -Name $module -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop
            Write-Host "Module '$module' installed successfully." -ForegroundColor Green
        } catch {
            Write-Error "Failed to install module '$module': $_"
        }
    } else {
        Write-Host "Module '$module' is already installed." -ForegroundColor Cyan
    }
}