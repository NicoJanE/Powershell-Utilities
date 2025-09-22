# sample:
# ./findp.ps1 "FIXED_SUBNET=172.16.0.0"                                 # All default extensions
# ./findp.ps1 -pattern "automatic close" -extensions *.json             # Specific extensions
# ./findp.ps1 -pattern "automatic close" -extensions *.json, *.md       # Specific extensions, multiple
# ./findp.ps1 "automatic close" *.json2                                 # Also OK


param (
    [string]$pattern,
    [string[]]$extensions = @()
)

$path = "D:\Docker Definitions\Docker-Template-Stacks"
$defaultExt = @("*.c", "*.cpp", "*.h", "*.md", "*.env", "*.json")


if (-not $extensions -or $extensions.Count -eq 0) {
    $ext = $defaultExt
}
else {
    $ext= $extensions
}

Clear-Host
Write-Host "  Searching projects for: " -NoNewline
Write-Host "$pattern `n" -ForegroundColor Red 

# Get-ChildItem -Path $path -Recurse -Include *.c, *.cpp, *.h, *.md, *.env, *.json |
Get-ChildItem -Path $path -Recurse -Include $ext |
Select-String -Pattern $pattern -CaseSensitive:$false |
ForEach-Object {
    $line = $_.Line
    $LineNumber = $_.LineNumber
    $lastIndex = 0

    # Walk through all matches in this line
    foreach ($m in $_.Matches) {
        
		
        # Write-Host `nFound at line: $LineNumber : $line.Substring( $lastIndex, $m.Index - $lastIndex) -NoNewline -ForegroundColor Yellow   #Details
		Write-Host `nFound at line: $LineNumber -NoNewline -ForegroundColor Yellow	# No line details
        # Print the match in red
        Write-Host `n`t$m.Value -ForegroundColor Red -NoNewline
        # Update cursor
        $lastIndex = $m.Index + $m.Length
    }

    # Print matching last item
    if ($lastIndex -lt $line.Length) {
        Write-Host $line.Substring($lastIndex)  -NoNewline
    }

    # Full path in green
    Write-Host "`nHere: $($_.Path)" -ForegroundColor Green 

	# Make a clickable "Click here" link


	$esc = [char]27
	$pathEscaped = ($_.Path -replace '\\','/')							# Convert path to file:// format
	$link = "$esc]8;;file:///$pathEscaped$esc\CTRL+Click$esc]8;;$esc\" 	# Build hyperlink
	Write-Host $link -ForegroundColor Cyan # -NoNewline    

}
