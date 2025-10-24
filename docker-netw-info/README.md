
# Docker Network Information  <span style="color: #409EFF; font-size: 0.6em; font-style: italic;"> - Productivity Script</span>

## ℹ️ Introduction

Displays Docker containers in a specified network and related information such as: *Name*, *IPv4*, *Ports*, and *Status*.

## ⚡ Getting Started

- The script is called `docker-netw-members.ps1`. When executed without parameters, by default it will use the network `dev1-net`. You can also specify a different network as a parameter.
- A batch file (`docker-netw-members.bat`) is provided so that Windows users can double-click to execute the script (using the default network parameter).

### Example Usage

```powershell
./docker-netw-members.ps1               # Uses default network 'dev1-net'
./docker-netw-members.ps1 my-network    # Uses 'my-network' instead
```

Or, on Windows, double-click `docker-netw-members.bat` to run with the default network.

## ✅ Prerequisites

- Docker must be installed and running
- PowerShell 5+ (Windows)
