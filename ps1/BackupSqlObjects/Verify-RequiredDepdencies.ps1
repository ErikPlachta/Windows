Test-Path "$env:WINDIR\\System32\\adalsql.dll"
Test-Path "$env:WINDIR\\SysWOW64\\adalsql.dll"

$installerUrl = "https://download.microsoft.com/download/E/7/9/E79D47C2-1907-4AC6-8A3C-FF9AF125A64F/ADALSQL.msi"
$tempPath = "$env:TEMP\\ADALSQL.msi"

Invoke-WebRequest -Uri $installerUrl -OutFile $tempPath
Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$tempPath`" /quiet /norestart" -Wait -Verb RunAs

https://www.microsoft.com/en-us/download/details.aspx?id=48742


integrste
if (-not (Test-Path "$env:WINDIR\\System32\\adalsql.dll")) {
    $confirm = Read-Host "ADALSQL.dll is missing. Install it now? (Y/N)"
    if ($confirm -eq 'Y') {
        # Trigger download and install as above
    } else {
        Write-Warning "ADALSQL not installed. Azure AD auth will fail."
    }
}