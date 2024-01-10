$days = (Get-Date).AddHours(-96)
Get-WinEvent -LogName "Application" | Where {$_.TimeCreated -ge $days -and $_.LevelDisplayName -eq "Critical"}