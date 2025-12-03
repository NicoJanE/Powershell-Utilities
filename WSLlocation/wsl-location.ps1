<#
========================================================================================================================================================

.SYNOPSIS
   ./wsl-location.ps1

.DESCRIPTION
    Shows the locations used by the WSL environment. Program ask for the WSL name

.INSTRUCTIONS
    To find your WSL ID or name, run:
        wsll -l -v
    
.NOTE
    Executing commands:
	1. CMdLet Execution 							-> runs a "PowerShell cmdlet" to see if docker exists
	
	External  command execution
	2.1	docker inspect $ContainerId					-> Execute External executable	
	2.2 	& docker inspect $ContainerId			-> Execute External executable (same)	
	2.3	"docker.exe" inspect $ContainerId			-> External executable (same)	
	BEST											-> Enables WriteHost and execute of command (Others will interpolate the command while outputting)
	2.4	cmdText = 'docker inspect $ContainerId'
		$inspect = Invoke-Expression $cmdText		-> Must use Invoke-Expression for string	
		Write-Host "Using command22:" "$cmdText"	-> This is now possible
	
    (2>$null									    -> Add this to the command to supress stderr)

=========================================================================================================================================================    
#>


## Create key value from the output of the command
function Parse-KeyValueLines {
    param(
        [string[]]$Lines,
        [string]$KeyValuePattern = '^(.+?)\s+REG_SZ\s+(.+)$'
    )

    $result = @()

    foreach ($line in $Lines) {
        if ($line -match $KeyValuePattern) {
            $result += [PSCustomObject]@{
                Key   = $matches[1].Trim()
                Value = $matches[2].Trim()
            }
        }
    }

    return $result
}


function Display-WSLs {
	
	$cmdText = 'wsl -l'	
	#Write-Host "Using command:" "$cmdText"	-ForegroundColor Cyan		# Display used command
	$inspect = Invoke-Expression $cmdText			                    # Execute used command
	
	# Split by line breaks and trim
    $lines = $inspect -split "`r?`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" }
    Write-Host "Available WSL distributions:" -ForegroundColor Yellow
	Write-Host "------------------------------------------------------------------"    -ForegroundColor Yellow
    foreach ($line in $lines) {
        Write-Host " - $line" -ForegroundColor Yellow
    }
	Write-Host "`n`n"
	
	
}


# Introduction text
Clear-Host
Write-Host "__________________________________________________________________" -ForegroundColor Green
Write-Host ""
Write-Host "        		WSL Location INSPECTOR " -ForegroundColor Green
Write-Host "__________________________________________________________________"  -ForegroundColor Green
Write-Host ""
Write-Host "This script inspects the WSL Environment for the used locations:`n" -ForegroundColor Green -NoNewLine
Write-Host "You can enter the WSL name or use the default defined `n" -ForegroundColor Green -NoNewLine
Write-Host ""


Display-WSLs

# --- Set default container ID ---
$defaultWSL = "Debian-clean"
$inputId = Read-Host "Enter WSL name to inspect (press Enter to use default: $defaultWSL)"
$WSLName = if ([string]::IsNullOrWhiteSpace($inputId)) { $defaultWSL } else { $inputId }
#Write-Host "`tUsing WSL $WSLName`n" -ForegroundColor Cyan


# Check if command: 'reg' is available
if (-not (Get-Command reg -ErrorAction SilentlyContinue)) {
    Write-Host "Command 'reg' not found." -ForegroundColor Red
    exit 1
}



# --- Run WSL 'reg' command to get detailed information ---
try {
    $cmdText = 'reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Lxss" /s | findstr /i /c:$WSLName'	
	Write-Host "Using command: " -NoNewLine
	Write-Host "$cmdText" -ForegroundColor Cyan		# Display used command
	$inspect = Invoke-Expression $cmdText			# Execute used command

    if (-not $inspect) {
        Write-Host "WSL environment '$WSLName' not found. Please check the input name." -ForegroundColor Red
        exit 1
    }
	
	# Output the  Results
    if ($inspect.Count -eq 0) {
        Write-Host "`nNo results found." -ForegroundColor Red
    } else {
        Write-Host "`nWSL RESULTS:" -ForegroundColor Green
		Write-Host "-------------------------------------------------------`n"  -ForegroundColor Green

		$parsed = Parse-KeyValueLines -Lines $inspect
		foreach ($item in $parsed) {
			Write-Host "`t- $($item.Key): $($item.Value)" -ForegroundColor Green
		}
		
    }
}
catch {
    Write-Host "Error inspecting WSL environment '$WSLName': $_" -ForegroundColor Red
}

Read-Host "`n`nPress Enter to exit"
