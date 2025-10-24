
# Countdown Executor  <span style="color: #409EFF; font-size: 0.6em; font-style: italic;"> - Productivity Script</span>

## ℹ️ Introduction

Runs a Windows command from PowerShell after a configurable countdown timer. Useful for scheduling actions such as hibernation, shutdown, or launching programs.

## ⚡ Getting Started

- The script is called `Execute command after countdown.ps1`.
- You can specify the command and its arguments in a text file named `command.txt` (placed in the same directory as the script). The first line should contain the command to execute.
- The user can enter the countdown duration in seconds (default is 3600 seconds, i.e., one hour).
- By default, the command is set to hibernate if no command is specified.

### Example `command.txt` file

```
shutdown /s /t 0
```

### Example Usage

```powershell
./Execute command after countdown.ps1      # Uses default countdown and command
./Execute command after countdown.ps1 1800 # Runs after 1800 seconds (30 minutes)
```

## ✅ Prerequisites

- PowerShell 5+
