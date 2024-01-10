##Author: Erik Plachta
##Purpose: Enable monitoring of Plug and Play events

$LogName = "Microsoft-Windows-DriverFrameworks-UserMode/Operational"
$CurrentConfig = Get-WinEvent -ListLog $LogName
If ($CurrentConfig.IsEnabled -eq $False) {
    $Log = New-Object System.Diagnostics.Eventing.Reader.EventLogConfiguration $LogName
    $Log.IsEnabled = $True
    $Log.SaveChanges()
    }