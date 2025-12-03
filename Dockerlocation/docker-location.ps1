<#
=========================================================================================================================================================    
.SYNOPSIS
    Shows the bind mounts and volumes of a Docker container.

.DESCRIPTION
    This script inspects a Docker container (by ID or name) and lists all its mounts
    â€” including bind mounts and named volumes â€” in full detail.
    You can pass the container ID or name as a parameter, or it will use a default.

.INSTRUCTIONS
    To find your container ID or name, run:
        docker ps -a
    Then copy the value from the â€œCONTAINER IDâ€ or â€œNAMESâ€ column.

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
	
    (2>$null									    -> Add this to the command to suppress stderr)


=========================================================================================================================================================    
#>


function Display-DockerContainer {
	
	$cmdText = 'docker ps -a --format "table {{.ID}}\t{{.Status}}\t{{.Names}}"'
	# Write-Host "`tUsing command:" "$cmdText`n" -ForegroundColor Cyan	# Display used command
	$inspect = Invoke-Expression $cmdText			                    # Execute used command
	
	# Split by line breaks and trim
    $lines = $inspect -split "`r?`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" }
    Write-Host "Available Docker Container ID'ds:" -ForegroundColor Yellow
	Write-Host "------------------------------------------------------------------------------------------------------------------"    -ForegroundColor Yellow
    foreach ($line in $lines) {
        Write-Host " - $line" -ForegroundColor Yellow
    }
	Write-Host "`n`n"
	
	
}

# Introduction text
Clear-Host
Write-Host "------------------------------------------------------------------------------------------------------------------" -ForegroundColor Green
Write-Host ""
Write-Host "                                    DOCKER MOUNT INSPECTOR " -ForegroundColor Green
Write-Host "------------------------------------------------------------------------------------------------------------------"  -ForegroundColor Green
Write-Host ""
Write-Host "This script inspects the Docker container:" -ForegroundColor Green -NoNewLine
Write-Host "    $ContainerId" -ForegroundColor Cyan
Write-Host "It displays all mounts (binds and volumes) defined for that container." -ForegroundColor Green
Write-Host ""

# Show the available Docker containers
Display-DockerContainer

# --- Set default container ID ---
$defaultContainer = "128bde95a367"
Write-Host "Enter container ID or name (press Enter to use default: $defaultContainer)" -ForegroundColor White
$inputId = Read-Host
$ContainerId = if ([string]::IsNullOrWhiteSpace($inputId)) { $defaultContainer } else { $inputId }
##Write-Host "Using container ID (short): $ContainerId" -ForegroundColor Cyan

# Check if Docker command is available 
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "Docker CLI not found. Please ensure Docker Desktop is installed and available in PATH." -ForegroundColor Red
    exit 1
}

# Run docker inspect
try {
    $inspect = docker inspect $ContainerId 2>$null
    if (-not $inspect) {
        Write-Host "Container '$ContainerId' not found. Please check the ID or name." -ForegroundColor Red
        exit 1
    }
	# Parse container info
	$containerInfo = ($inspect | ConvertFrom-Json)[0]
	
    $mounts = ($inspect | ConvertFrom-Json)[0].Mounts

    if ($mounts.Count -eq 0) {
        Write-Host "`nNo mounts found for container '$ContainerId'." -ForegroundColor Yellow
    } else {
        Write-Host "`nMOUNT RESULTS for container: $ContainerId " -ForegroundColor DarkYellow
		Write-Host "------------------------------------------------------------------------------------------------------------------"    -ForegroundColor Yellow
		$mounts |Select-Object Type, Source, Destination, Mode, RW | Format-Table -AutoSize | Out-Host
		
		#  Show container ID + name
		Write-Host "Details" 
		Write-Host "- Container full ID: $($containerInfo.Id)" 
		if ($null -ne $containerInfo.Name) {
			Write-Host "- Container Name: $($containerInfo.Name.TrimStart('/')) `n"
		} else {
			Write-Host "Container Name: <unknown>" -ForegroundColor Yellow
		}
    }
}
catch {
    Write-Host "Error inspecting container '$ContainerId': $_" -ForegroundColor Red
}

Read-Host "`n`nPress Enter to exit"
