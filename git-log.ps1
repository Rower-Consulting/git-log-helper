# Initialize empty hashtable
$contributors = @{}

# Collect last and first contributions
git log --pretty=format:'%an|%cd' --date=iso-strict | ForEach-Object {
    $data = $_ -split '\|'
    $name, $date = $data[0], $data[1]

    try {
        $parsedDate = [DateTime]::Parse($date)
        $formattedDate = $parsedDate.ToString("yyyy-MM-ddTHH:mm:ss") + $parsedDate.ToString("zzz")
    } catch {
        Write-Host "Error parsing date for ${name}: $date"
        continue
    }

    if (-not $contributors.ContainsKey($name)) {
        $contributors[$name] = @{"First"=$formattedDate; "Last"=$formattedDate}
    }
    else {
        $contributors[$name]["First"] = $formattedDate
    }
}

# Generate CSV in memory
$results = @("User,FirstContribution,LastContribution")
$contributors.Keys | ForEach-Object {
    $user = $_
    $first = $contributors[$user]["First"]
    $last = $contributors[$user]["Last"]
    $results += "$user,$first,$last"
}


# Output CSV to console
$csvData = $results -join "`r`n"
Write-Host $csvData
# Output CSV to time stamped file
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$filename = "path/to/your/output/gitlog_${timestamp}.csv"
$csvData | Out-File -FilePath $filename