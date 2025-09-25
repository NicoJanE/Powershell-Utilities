param(
    [string]$WSLfile = ".\WSLfile"
)
$DebugPreference = "Continue"

# WHAT
# ------------------------------------------------------------------------------------------------------------------------------
#   This is a Docker-like script that parses a WSLfile (similar to a Dockerfile) and executes commands in the WSL environment.
#   It currently supports the following features:
#     - By default it reads the 'WSLfile'for the instructions, but you can also provide your own file by using the WSLfile parameter.  wsl-parser WSLfile "D:\PowerShell\Projects\OPEN_SOURCE\Powershell-utilities\WSLFile\WSlfile"
#     - Indicate a target WSL Distro and User (DISTRO USER)
#     - Create a new Debian WSL Distro (DISTRO_DEBIAN_NEW)
#     - Install Packages in the WSL (RUN)
#     - Copy files from Windows to WSL (COPY)
#     - Set environment variables in the WSL environment (ENV)
#
# Run with: 
#  - powershell.exe -ExecutionPolicy Bypass -File .\wsl-parser.ps1
#  - powershell.exe -ExecutionPolicy Bypass -File .\wsl-parser.ps1  "path\to\your\WSLfile"
#
# Convert it to Executable (See als Appendix II in README.d)
#   - ps2exe wsl-parser.ps1 wsl-parser.ps1
#   - Now it can be use like: `wsl-parser.ps1`
#
#   For more information see the `README.md` file
#
# ------------------------------------------------------------------------------------------------------------------------------
# NOTE:                                                                 
#
#	"I Tried to add the task functions into a class named tasks. But encountered a Powershell bug that prevented me to continue 
#   with this approach. Bug report and can be found here:" should be "I tried to add the task functions into a class named 'tasks'. 
#   However, I encountered a PowerShell bug that prevented me from continuing with this approach. A bug report can be found here:
#
#		https://github.com/PowerShell/PowerShell/issues/26067
#		Bug in PowerShell 5.1 and 7.5.3
#
#   	This turned out to be a WSL issue (TODO Report it)
# ----------------------------------------------------------------------------


# ============================================================================
# Global State Variables used for setting up your WSL environment
# ============================================================================
#   Used WSL Distribution or new WSL distribution to create
$Global:Distro = $null
#   User name in the WSL distribution to use
$Global:User = $null
#   Working directory to use in the WSL distribution
$Global:WSLWorkDir = $null


# Internal array with environment variable, see: Task_SetEnv
$Global:WSLEnv = @{}



# ============================================================================
# Private Supporting Functions
# ============================================================================



# Private supporting function - Execute commands in WSL with environment 
# and workdir
function Private_RunInWSL {
    param([string]$Command)

    if (-not $Global:Distro) { throw "DISTRO must be set before RUN." }
    # Prepend WORKDIR if set
    if ($Global:WSLWorkDir) {
        $Command = "cd $Global:WSLWorkDir && $Command"
    }

    # Combine environment setup with the actual command
    $fullCommand = "source ~/.bashrc; $Command"
    if ($Global:User) {
        # Write-Host ">> Requires privilege permissions (disabled!"    -ForegroundColor DarkYellow

        # Sudo will be indicated by the input program we don't use it implicitly here
        # wsl -d $Global:Distro -- sudo -E -u $Global:User bash -c $fullCommand
        wsl -d $Global:Distro -u $Global:User -- bash -c $fullCommand
    } else {        
        wsl -d $Global:Distro -- bash -c $fullCommand
    }
    write-Host ""
}

# ============================================================================
# Public Task Functions
#
# ============================================================================

# Public Task - Execute command in WSL
function Task_Run {
    param([string]$Command)
    Write-Host ">> RUN in WSL: " -ForegroundColor Green -NoNewline
    Write-Host "$Command" 
    Private_RunInWSL $Command
}
# Public Task - Execute command.
function Task_CMDRun {
    param([string]$Command)
    Write-Host `n`n>> Execute ">> : " -ForegroundColor Green -NoNewline
    Write-Host  $Command 
    Invoke-Expression $Command
}

function Task_Copy {
    param(
        [string]$Source,   
        [string]$Target    
    )

    if (-not $Global:Distro) { throw "DISTRO must be set before COPY." }

    # Normalize WSL target path
    $TargetWSL = $Target.Replace("\", "/").TrimEnd("/")

    # Include files and folders recursively
    $items = Get-ChildItem -Path $Source -Recurse

    if ($items.Count -eq 0) { 
        Write-Warning "No files or folders found: $Source"
        return
    }

    foreach ($item in $items) {
        # Relative path inside source folder
        $relPath = $item.FullName.Substring((Resolve-Path $Source).Path.Length).TrimStart('\')
        $destWSL = "/$TargetWSL/$relPath" -replace '\\','/'

        # Convert Windows path to WSL path
        $drive, $rest = $item.FullName -split ":", 2
        $drive = $drive.ToLower()
        $rest = $rest -replace '\\','/'
        $sourceWSL = "/mnt/$drive$rest"

        if ($item.PSIsContainer) {
            # Create directory in WSL
            Private_RunInWSL "mkdir -p '$destWSL'"
        } else {
            # Ensure parent directory exists
            $dir = [System.IO.Path]::GetDirectoryName($destWSL) -replace '\\','/'
            Private_RunInWSL "mkdir -p '$dir'"

            # Copy the file
            Private_RunInWSL "cp '$sourceWSL' '$destWSL'"
        }

        Write-Host ">> COPY " -ForegroundColor Green -NoNewline
        Write-Host "($Global:Distro): " -NoNewline -ForegroundColor Yellow
        Write-Host "$($item.FullName) -> $destWSL"
    }
}



# Public Task - Set environment variable
function Task_SetEnv {
    param([string]$Name, [string]$Value)
    $Global:WSLEnv[$Name] = $Value
    Write-Host ">> ENV: " -NoNewline -ForegroundColor Green
    Write-Host "$Name=$Value"
    
}
function Task_EnvApply {    
    $envCommands = ""
    foreach ($kv in $Global:WSLEnv.GetEnumerator()) {
        # Remove existing entries for this variable first, then add the new one
        $envCommands += "sed -i '/^export " + $kv.Key + "=/d' ~/.bashrc; "
        $envCommands += "echo 'export " + $kv.Key + "=\`"" + $kv.Value + "\`"' >> ~/.bashrc; "
    }
    Private_RunInWSL $envCommands
    write-Host ">> Environment variables set in: " -ForegroundColor Green -NoNewline
    write-Host " ~/.bashrc" 

}

# Public Task - Set distro
function Task_SetDistro {
    param([string]$distro)
    $Global:Distro = $distro
    Write-Host ">> Using distro: " -NoNewline -ForegroundColor Yellow
    Write-Host "$Global:Distro"
}

# Public Task - Set user
function Task_SetUser {
    param([string]$user)
    $Global:User = $user
    Write-Host ">> Using user: " -NoNewline -ForegroundColor Yellow
    Write-Host "$Global:User" -NoNewline
}
1
# Public Task - Set working directory
function Task_SetWorkDir {
    param([string]$workdir)
    $Global:WSLWorkDir = $workdir
    Write-Host ">> WORKDIR set to: $Global:WSLWorkDir"
}

# Creates a new Debian-based WSL distro the name and user are provided in the WSLfile
function Task_Distro_Debian_New {
    param([string]$distroArgs)
    Write-Host ">> Executing >> Creating new Debian WSL with args: $distroArgs"
    Task_CMDRun  "WSL --install Debian --no-launch --name $Global:Distro $distroArgs"
    # Create user and password
    Task_CMDRun "wsl -d $Global:Distro -u root -- adduser $Global:User"
    # MAke user a sudo user
    Task_CMDRun "wsl -d $Global:Distro -u root -- usermod -aG sudo $Global:User"                
}
function Task_Description {
    param([string]$description)
    $description = $description.Replace('`', "`n")
    Write-Host "Description: " -ForegroundColor Yellow
    Write-Host "$description`n"
}



function Write-Header {
    param(
        [string]$Title = "WSL Setup Script",
        [string]$Subtitle = "Automated Environment Initialization"
    )
    clear-host
    $width = 120
    $topLeft    = [char]0x250C  # ┌
    $horizontal = [char]0x2500  # ─
    $topRight   = [char]0x2510  # ┐
    $bottomLeft = [char]0x2514  # └
    $bottomRight= [char]0x2518  # ┘
    $vertical   = [char]0x2502  # │
    $BackColor = "DarkGray"
    $foregroundColor = "Green"

    # 1e Line
    $line    = "$topLeft" + "".PadRight($width - 2, $horizontal) + "$topRight"
    Write-Host ""
    Write-Host $line -ForegroundColor $foregroundColor -BackgroundColor $BackColor

    # Title Line
    $titleLine = "$vertical" + $Title.PadLeft(([int](($width - 2 + $Title.Length)/2))).PadRight($width - 2) + "$vertical"
    Write-Host $titleLine -ForegroundColor $foregroundColor -BackgroundColor $BackColor

    # Subtitle Line
    $subtitleLine = $Subtitle.PadLeft(([int](($width - 2 + $Subtitle.Length)/2))).PadRight($width - 2) 
    Write-Host "$vertical" -ForegroundColor $foregroundColor -NoNewline -BackgroundColor $BackColor
    Write-Host $subtitleLine -ForegroundColor Yellow -NoNewline -BackgroundColor $BackColor
    Write-Host "$vertical" -ForegroundColor $foregroundColor -BackgroundColor $BackColor

    # Bottom Line
    $Line = "$bottomLeft" + "".PadRight($width - 2, $horizontal) + "$bottomRight"
    Write-Host $line -ForegroundColor $foregroundColor -BackgroundColor $BackColor
    Write-Host ""
}


# ============================================================================
# Main Parsing Logic
# ============================================================================

# Main - Parse the input file and execute tasks
Write-Header

Get-Content $WSLfile | ForEach-Object {
    $line = $_.Trim()
    if ($line -eq "" -or $line.StartsWith("#")) { return }

    if ($line -match "^DISTRO\s+(\S+)$") {
        Task_SetDistro $Matches[1]
    }
    elseif ($line -match "^USER\s+(\S+)$") {
        Task_SetUser $Matches[1]
    }
    elseif ($line -match "^RUN\s+(.*)$") {
        # Fix PowerShell variable expansion by converting \$ back to $
        $command = $Matches[1] -replace '\\(\$)', '$1'
        Task_Run $command
    }
    elseif ($line -match "^COPY\s+(\S+)\s+(\S+)$") {
        Task_Copy $Matches[1] $Matches[2]
    }
    elseif ($line -match "^ENV\s+(\S+)=(.*)$") {
        Task_SetEnv $Matches[1] $Matches[2]
    }
    elseif ($line -match "^ENV_APPLY") {
        Task_EnvApply
    }
    elseif ($line -match "^WORKDIR\s+(\S+)$") {
        Task_SetWorkDir $Matches[1]
    }
    elseif( $line -match "^DISTRO_DEBIAN_NEW\s+(.+)$"){
        $distroArgs = $Matches[1]
        Task_Distro_Debian_New $distroArgs
    }
    elseif( $line -match "^DESCRIPTION\s+(.+)$"){        
        $description = $Matches[1]        
        Task_Description $description        
    }
    else {
        Write-Warning "Unknown instruction: $line"
    }
}