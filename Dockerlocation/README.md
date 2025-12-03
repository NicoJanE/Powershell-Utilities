
# Docker-location  <span style="color: #409EFF; font-size: 0.6em; font-style: italic;"> - Productivity Script</span>

## ℹ️ Introduction

**Docker-locations** is a PowerShell script that displays an overview of all Docker containers on your system. After you specify a container, it shows the most important mount locations (bind mounts and volumes) for that container

## 🚀 Features

- Lists all Docker containers with their IDs, status, and names.
- Prompts for a container ID or name (with a default option).
- Displays all mounts (binds and volumes) for the selected container.
- Shows container details (full ID and name).
- User-friendly output with color highlights.

## 🛠 Prerequisites

- Windows with PowerShell 5.1 or later.
- Docker Desktop installed and running.
- Docker CLI available in your system PATH.

## 📦 Installation

1. Download or clone this repository.
1. Place docker-location.ps1 in your desired directory.

## ⚡ Usage

Open PowerShell, navigate to the script directory, and run: `./docker-location.ps1`
You will see a list of all Docker containers. Enter the container ID or name when prompted (or press Enter to use the default).

<br>
