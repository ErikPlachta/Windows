


## Get Events


#This example gets all entires with provider wildcard string Policy
Get-WinEvent -ListProvider *Policy*


#Example 1: Get event logs on the local computer
#This example displays the list of event logs that are available on the local computer. The names in the Log column are used with the LogName parameter to specify which log is searched for events.
Get-EventLog -List


#Example 2: Get recent entries from an event log on the local computer
#This example gets recent entries from the System event log.
Get-EventLog -LogName System -Newest 5


#Example 3: Find all sources for a specific number of entries in an event log
#This example shows how to find all of the sources that are included in the 1000 most recent entries in the System event log.
$Events = Get-EventLog -LogName System -Newest 10
$Events | Group-Object -Property Source -NoElement | Sort-Object -Property Count -Descending


#Example 4: Get error events from a specific event log
#This example gets error events from the System event log.
Get-EventLog -LogName System -EntryType Error


#Example 6: Get events from multiple computers
#This command gets the events from the System event log on three computers: Server01, Server02, and Server03.
Get-EventLog -LogName System -ComputerName station01, help-pc00

#Example 7: Get all events that include a specific word in the message
#This command gets all the events in the System event log that contain a specific word in the event's message. It's possible that your specified Message parameter's value is included in the message's content but isn't displayed on the PowerShell console.

Get-EventLog -LogName System -Message *posn*

#Example 8: Display the property values of an event
#This example shows how to display all of an event's properties and values

$A = Get-EventLog -LogName System -Newest 1
$A | Select-Object -Property *


#Example 9: Get events from an event log using a source and event ID
#This example gets events for a specified Source and Event ID.

Get-EventLog -LogName Application -Source Outlook | Where-Object {$_.EventID -eq 63} | Select-Object -Property Source, EventID, InstanceId, Message


#Example 10: Get events and group by a property
Get-EventLog -LogName System -UserName NT* | Group-Object -Property UserName -NoElement | Select-Object -Property Count, Name



##-----------------------------------------------##

##get Events by Get-EventLog
## https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-eventlog?view=powershell-5.1




#Get-EventLog -List

Get-WinEvent -