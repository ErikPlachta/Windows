<#
    .SYNOPSIS
        Retrieves BlueScreen events, if any, along potentially related events proceeding the error event from the Windows Event Log.

    .DESCRIPTION
        This script fetches BlueScreen events (Event ID 1001) from the System log and can also retrieve related events within a specified time window before each BlueScreen event. The script provides options for displaying the output in HTML format, saving to a file, and limiting the number of events processed.

    .PARAMETER nBluescreenEvents
        The number of most recent BlueScreen events to process. Default is all available events.

    .PARAMETER relatedEventLevels
        The Event Level of related events to search for. Default value is '1,2', where 1 is Critical, 2 is Error events.

    .PARAMETER minutesBefore
        The number of minutes before a BlueScreen event to search for related events. Default is all available history.

    .PARAMETER hoursBefore
        The number of hours before a BlueScreen event to search for related events. Default is null.

    .PARAMETER daysBefore
        The number of days before a BlueScreen event to search for related events. Default is null.

    .PARAMETER displayAsHtml
        Boolean value to display results in HTML format. Default is false.

    .PARAMETER saveToFile
        Boolean value to save results to a file. Default is false.

    .EXAMPLE
        Get-WindowsEvents-Bluescreen -nBluescreenEvents 5 -minutesBefore 5 -displayAsHtml $true
        Retrieves the last 5 BlueScreen events within the last 5 minutes and displays the results in HTML format.

    .EXAMPLE
        Get-WindowsEvents-Bluescreen -saveToFile $true -nBluescreenEvents 5
        Retrieves the last 5 BlueScreen events and saves the results to a specified file.

    .NOTES
        Version:        0.1.0
        Author:         Erik Plachta
        Creation Date:  20220901
        Purpose/Change: Initial commit. Created to debug Windows Bluescreen Events.

#>

Function Get-WindowsEvents-Bluescreen {
    param (
        # How many events to look up
         [Parameter(Mandatory = $false)] [ValidateRange(1, [int]::MaxValue)] [System.Int32] $nBluescreenEvents = [int]::MaxValue


        # Level of Related Events to look for.
        ,[Parameter(Mandatory = $false)] [String] $relatedEventLevels = '1,2'
        # Duration to look for events prior to bluescreen.
        ,[Parameter(Mandatory = $false)] [ValidateRange(1, [int]::MaxValue)] [System.Int32] $minutesBefore = [int]::MaxValue
        ,[Parameter(Mandatory = $false)] [ValidateRange(1, [int]::MaxValue)] [System.Int32] $hoursBefore = $null
        ,[Parameter(Mandatory = $false)] [ValidateRange(1, [int]::MaxValue)] [System.Int32] $daysBefore = $null

        # Output Results
        ,[Parameter(Mandatory = $false)] [System.Boolean] $displayAsHtml = $false
        ,[Parameter(Mandatory = $false)] [System.Boolean] $saveToFile = $false
    )

    # Calculate the time span based on the input parameters
    $TimeSpan = New-TimeSpan -Minutes ($minutesBefore -as [int]) -Hours ($hoursBefore -as [int]) -Days ($daysBefore -as [int])

    # Hash table to store events
    $EventHashTable = @{}

    # Fetch the BlueScreen events (Event ID 1001 in the System log) and limit by nBluescreenEvents
    $BlueScreenEvents = Get-WinEvent -FilterHashtable @{LogName='System'; ID=1001} -MaxEvents $nBluescreenEvents -ErrorAction SilentlyContinue

    # Check if any BlueScreen events were found, and if none exit.
    if ($BlueScreenEvents -eq $null -or $BlueScreenEvents.Count -eq 0) {
        Write-Host "No BlueScreen events found."
        return
    }

    # Process each BlueScreen event
    foreach ($Event in $BlueScreenEvents) {
        # Create a key for each event in the hash table
        $EventKey = "BlueScreen Event at $($Event.TimeCreated)"

        # Initialize an array to hold related events
        $EventHashTable[$EventKey] = @($Event)

        # Check if a timespan is defined and search for related events within this window
        if ($minutesBefore -ne [int]::MaxValue -or $hoursBefore -ne $null -or $daysBefore -ne $null) {
            $StartTime = $Event.TimeCreated - $TimeSpan
            $EndTime = $Event.TimeCreated

            # Retrieve related events in the specified time window
            $RelatedEvents = Get-WinEvent -FilterHashtable @{LogName='System'; StartTime=$StartTime; EndTime=$EndTime; Level=$relatedEventLevels}

            # Add related events to the hash table under the corresponding BlueScreen event
            $EventHashTable[$EventKey] += $RelatedEvents
        }
    }

    # Output processing based on user selections for HTML display or console output
    if ($displayAsHtml) {
        # Convert hash table to HTML format
         $HtmlTable = ConvertTo-HTMLTable -HashTable $EventHashTable

        # Save to file or display in the default browser based on user choice
        if ($saveToFile) {
            # Prompt user for file path and save HTML content
            $filePath = Read-Host "Please enter the path to save the HTML file"
            [System.IO.File]::WriteAllText($filePath, $HtmlTable)
            Write-Host "File saved to $filePath"
        } else {
            # Write HTML content to a temporary file and open in the default browser
            $TempFile = [System.IO.Path]::GetTempFileName() + ".html"
            [System.IO.File]::WriteAllText($TempFile, $HtmlTable)
            Start-Process $TempFile
        }
    } else {
        # Display results in the console
        foreach ($Key in $EventHashTable.Keys) {
            Write-Host "$Key"
            foreach ($Event in $EventHashTable[$Key]) {
                Write-Host "Time: $($Event.TimeCreated) - Event ID: $($Event.Id) - Description: $($Event.Message)"
            }
            Write-Host "--------------------------------------------------"
        }
    }
}

# Example usage of getting last bluescreen events, along with all related events that lead up to
Get-WindowsEvents-Bluescreen -nBluescreenEvents 1 -minutesBefore 5 -displayAsHtml $true