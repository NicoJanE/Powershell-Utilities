#Requires -Version 5.1

#  This file is part of: **Powershell-utilities**_
#     Copyright (c) July 2025 Nico Jan Eelhart.
#     This source code is licensed under the MIT License found in the  'LICENSE.md' file in the root directory of this source tree.
#----------------------------------------------------------------------------------------------------------------------------------

# Usage:
#   .\command.ps1 
#
# This script schedules a system command (default shutdown) which is executed after a user-specified number of 
# seconds (default: 3600 seconds). During the countdown, the user can cancel the command by pressing any key or CTRL-C
#
#----------------------------------------------------------------------------------------------------------------------------------

# These defaults will be used incase the 'input.txt' has no values 
#
# My apologies.
# The previous versions of the script included the shutdown command by default, which wasn't very convenient. That has now been changed,Notepad will open the command.txt file instead.
# Sorry again if this caused any trouble for anyone.
# $Global:COMMAND_EXE = "shutdown.exe"
# $Global:COMMAND_ARGS_TEMPLATE = "/s", "/f", "/d", "p:0:0", "/t","1"
$Global:COMMAND_EXE = "notepad.exe"
$Global:COMMAND_ARGS_TEMPLATE= "command.txt" 
$Global:fileUsed = 0
$file_Command = ".\command.txt"

# Read 'command.txt' values if available and override: COMMAND_EXE and COMMAND_ARGS_TEMPLATE
function Set-GlobalCommandFromFile {
    param (
        [string]$FilePath
    )

    if (-Not (Test-Path $FilePath)) {
        Write-Error "File '$FilePath' not found."
        return
    }
    $lines = Get-Content $FilePath | Where-Object { $_ -match ':' }

    foreach ($line in $lines) {
        if(!$line.StartsWith('#') ){
            $key, $value = $line -split ":", 2
            $key = $key.Trim()
            $value = $value.Trim()

            switch ($key.ToLower()) {
                "command" { 
                    # Strip surrounding quotes if present
                    $value = $value.Trim('"')
                    $Global:COMMAND_EXE = $value
                    $Global:fileUsed++
                }                
                "args" {
                     try {
                        # Wrap in array syntax and parse safely
                        $scriptBlock = [ScriptBlock]::Create("@($value)")
                        $parsed = $scriptBlock.Invoke()
                        $Global:COMMAND_ARGS_TEMPLATE = $parsed
                        $Global:fileUsed++
                    }
                    catch {
                        Write-Error "Failed to parse arguments from command.txt: $_"
                        exit 1
                    }
                }
                default{
                     Write-Warning "Unknown key: $key" 
                }
            }
    }

    }
}


# Start main
clear-Host
# check if command.txt has other command and args, if so use them otherwise use program defaults
Set-GlobalCommandFromFile -FilePath "$file_Command"

# Show from where the command and arguments are used
if($fileUsed -eq 2){
    Write-Host ([char]0x2705) "Using command and args from: FILE ('$file_Command')"
}
else{
    Write-Host ([char]0x2705) "File ('$file_Command') empty. Using command and args from: PROGRAM ($file_Command) "
}

# Prompt user for number of seconds until shutdown
$time = Read-Host "Enter a number of seconds  (enter uses default: 3600 seconds)"
if ([string]::IsNullOrWhiteSpace($time)) {
    Write-Host ([char]0x2705) "No input provided. Using default timer value 3600 seconds"
	$SecondsToWait = 3600
}
elseif ($time -as [int]) {
	$SecondsToWait = [int]$time
}

# Validate minimum wait time
if ($SecondsToWait -lt 1) {
    Write-Host ([char]0x26D4) " Error: The time must be at least 1 second." -ForegroundColor Red
    exit 1
}

Write-Host "`nPress any key to cancel shutdown..." -ForegroundColor Yellow
Write-Host ([char]0x25B6) " Countdown running, you can still cancel later by closing the window or pressing a key.`n"
$endTime = (Get-Date).AddSeconds($SecondsToWait)

# Show countdown in terminal (with cancel option) at fixed position
$pos = $Host.UI.RawUI.CursorPosition
$pos.X = 0
$pos.Y = $pos.Y - 1
do {
    $remaining = [math]::Ceiling(($endTime - (Get-Date)).TotalSeconds)
	$Host.UI.RawUI.CursorPosition = $pos
	Write-Host " " ([char]0x2713) "Command ($COMMAND_EXE) scheduled to run in: " -BackgroundColor DarkGray -ForegroundColor Yellow -NoNewline 
    Write-Host " $remaining seconds " -BackgroundColor DarkGray -ForegroundColor DarkGreen 

    # Wait up to 1 second in 100ms increments, checking for key press
    for ($i = 0; $i -lt 10; $i++) {
        Start-Sleep -Milliseconds 100
        if ([System.Console]::KeyAvailable) {            
            [void][System.Console]::ReadKey($true)            
            Write-Host "`n" ([char]0x26D4) "Command canceled by user!, press any key to return to prompt" -ForegroundColor Green			
            [System.Console]::ReadKey($true) 
            exit 0
        }
    }

} while ((Get-Date) -lt $endTime)

# Time to execute the command! Countdown done, execute the command and, notify the user
$warningSymbol = [string]::Concat([char]0xD83D, [char]0xDED1)
Write-Host " $warningSymbol System command now in progress: $COMMAND_EXE should now been excuted`n`n ." -ForegroundColor Magenta
if (-not ($COMMAND_ARGS_TEMPLATE -is [System.Array])) {
    & $COMMAND_EXE $COMMAND_ARGS_TEMPLATE
}
elseif ($COMMAND_ARGS_TEMPLATE.Count -eq 1) {
    & $COMMAND_EXE $COMMAND_ARGS_TEMPLATE[0]
} else {
    & $COMMAND_EXE @COMMAND_ARGS_TEMPLATE
}