##Author: Erik Plachta
##Date: 06/01/2021
##Purpose: Enable monitoring on Windows Events related to Plug and Play Devices for POS Nation Support Customers so we can undersatnd issues and provide better service.

##Enable Auditing on Driver Frameworks Events 
$LogName = "Microsoft-Windows-DriverFrameworks-UserMode/Operational"
$CurrentConfig = Get-WinEvent -ListLog $LogName
If ($CurrentConfig.IsEnabled -eq $False) {
    $Log = New-Object System.Diagnostics.Eventing.Reader.EventLogConfiguration $LogName
    $Log.IsEnabled = $True
    $Log.SaveChanges()
}

##Enable Auditting on Plug and Play Device events
auditpol /set /subcategory:"Plug and Play Events","Removable Storage","Handle Manipulation" /success:enable /failure:enable