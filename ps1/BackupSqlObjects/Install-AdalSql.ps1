<#
.SYNOPSIS
    Installs ADALSQL.DLL required for Azure AD Integrated SQL authentication.

.DESCRIPTION
    Downloads and installs the Microsoft Active Directory Authentication Library for SQL Server (ADALSQL).
    Requires administrator privileges.

.EXAMPLE
    .\Install-AdalSql.ps1
#>

function Install-AdalSql {
    param()

    $dllPath = "$env:WINDIR\System32\adalsql.dll"
    if (Test-Path $dllPath) {
        Write-Host "ADALSQL.dll is already installed." -ForegroundColor Green
        return
    }

    $installerUrl = "https://download.microsoft.com/download/E/7/9/E79D47C2-1907-4AC6-8A3C-FF9AF125A64F/ADALSQL.msi"
    $tempPath = "$env:TEMP\ADALSQL.msi"

    Write-Host "Downloading ADALSQL installer..." -ForegroundColor Cyan
    try {
        Invoke-WebRequest -Uri $installerUrl -OutFile $tempPath -UseBasicParsing -ErrorAction Stop
    } catch {
        Write-Error "Failed to download installer: $_"
        return
    }

    Write-Host "Installing ADALSQL (you may be prompted for admin permissions)..." -ForegroundColor Yellow
    try {
        Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$tempPath`" /quiet /norestart" -Wait -Verb RunAs
        Write-Host "Installation complete. Verifying..." -ForegroundColor Cyan
    } catch {
        Write-Error "Installation failed: $_"
        return
    }

    if (Test-Path $dllPath) {
        Write-Host "ADALSQL.dll installed successfully." -ForegroundColor Green
    } else {
        Write-Warning "Installation completed but DLL was not found. Please reboot and check again."
    }
}

Install-AdalSql