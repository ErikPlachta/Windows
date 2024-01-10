#https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/wevtutil

# select by LevelDisplayName
get-WinEvent -Logname Application -MaxEvents 300 | Where { $_.LevelDisplayName -eq "Error" -or $_.LevelDisplayName -eq "Warning"} | Format-Table -Property TimeCreated, Id, Message -AutoSize 

# select by Level property
# 2 - means Error
# 3 - means Warning
Get-WinEvent application -MaxEvents 300 | ?{$_.Level -eq 2 -or $_.Level -eq 3} | Out-File -FilePath c:\events.txt