

# WSLLocation <span style="color: #409EFF; font-size: 0.6em; font-style: italic;">- Productivity Script</span>

## ℹ️ Introduction

**WSLLocation** is a PowerShell script that displays an overview of all WSL (Windows Subsystem for Linux) environments on your system. After you specify a WSL environment, it shows the key locations where it is stored.

## 🚀 Features

- Lists all available WSL distributions.
- Prompts for a WSL distribution name (with a default option).
- Displays registry locations and key details for the selected WSL environment.
- User-friendly, color-highlighted output.

## 🛠 Prerequisites

- Windows with PowerShell 5.1 or later.
- WSL installed and at least one WSL distribution available.
- The `reg` command available in your system `PATH`.

## 📦 Installation

1. Download or clone this repository.
2. Place `wsl-location.ps1` in your desired directory.

## ⚡ Usage

Open PowerShell, navigate to the script directory, and run:

```powershell
./wsl-location.ps1
```

You will see a list of all WSL distributions. Enter the WSL name when prompted (or press Enter to use the default).

## 📝 Example Output

``` bash
Available WSL distributions:
 - Ubuntu
 - Debian-clean
 - Alpine

Enter WSL name to inspect (press Enter to use default: Debian-clean):

Using command: reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Lxss" /s | findstr /i /c:Debian-clean

WSL RESULTS:
- DistributionName: Debian-clean
- BasePath: C:\Users\YourUser\AppData\Local\Packages\...
- Version: 2
- State: 1
```

## ❓ Troubleshooting

- If you see "Command 'reg' not found," ensure you are running PowerShell on Windows.
- If the WSL environment is not found, check the name and try again.

---
