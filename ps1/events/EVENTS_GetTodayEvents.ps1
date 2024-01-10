Get-EventLog system -after (get-date).AddDays(-1) | where {$_.InstanceId -eq 7001}

$today = get-date -Hour 0 -Minute 0;
Get-EventLog system -after $today | sort -Descending | select -First 1