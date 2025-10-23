# This program script creates a Markdown file of the available containers inside a network
# when the program is call without a parameter the default network `dev1-net' is use
# You can however call the script with a other network
#
#   Call syntax:
#       - TODO if I keno the correct name
#
# Output file name : docker-net-members-<network-name>.md


# Set a default value for the 'network' parameter.
[Parameter(Mandatory=$false)]
[string]$network = "dev1-net"

# Generate Markdown information for the first Markdown header
function Header {
    param (
        [Parameter(Mandatory=$true)]
        [string]$NetworkName
    )
    
    return "# Docker Network layout ``$NetworkName```n`n"
}

# Generate Markdown information of all container os the network and their status
# Used Docker command:
#   `docker ps -a --filter "network=dev1-net" --format "{{.Names}}: {{.Status}}"`
function Get-AllDockerContainers {
    param (
        [Parameter(Mandatory=$true)]
        [string]$NetworkName
    )

    $containers = docker ps -a --filter "network=$NetworkName" --format "{{.Names}}: {{.Status}} "
    $markdown_all = @()
    $markdown_all +="## All Containers on Board`n"
    $markdown_all +="These containers are part of the network, both **enabled** and **disabled**`n"
    $markdown_all +="| Container | Status |"  
    $markdown_all +="| --- | --- |"


    foreach ($container in $containers) {
        $name = $container.Split(":")[0]
        $status = $container.Split(":")[1].Trim()
        $markdown_all += "| $name | $status |"
    }

    return $markdown_all+"`n ---`n"
}

# Generate Markdown information of he running containers including details (Name, IP, Ports and image)
# Used Docker command:
#   `docker inspect dev1-net | ConvertFrom-Json`
function Get-ActiveDockerContainers {
    param (
        [Parameter(Mandatory=$true)]
        [string]$NetworkName
    )

    
    $containers = docker network inspect $network | ConvertFrom-Json
    $markdown_active = @()
    $markdown_active += "## Active Running Containers`n"
    $markdown_active += "These containers are  the **active** containers on the network: ``$network`` and their details"
    $markdown_active += ""
    $markdown_active += "| Container Name | IPv4 Address | Internal Ports | External Ports | Image | Status |"
    $markdown_active += "|----------------|--------------|----------------|----------------|-------|--------|"

    foreach ($container in $containers[0].Containers.PSObject.Properties.Value) {
        $name = $container.Name

        # Inspect container for ports, image, and status
        $inspect = docker inspect $name | ConvertFrom-Json

        $ports = $inspect[0].NetworkSettings.Ports
        $internalPorts = @()
        $externalPorts = @()

        if ($ports) {
            foreach ($p in $ports.PSObject.Properties) {
                $internalPorts += $p.Name -replace "/tcp","" -replace "/udp",""
                if ($p.Value) {
                    foreach ($binding in $p.Value) {
                        if ($binding.HostPort) {
                            $externalPorts += $binding.HostPort
                        }
                    }
                }
            }
        }

        $ip = $inspect[0].NetworkSettings.Networks.$network.IPAddress
        $image = $inspect[0].Config.Image
        $status = $inspect[0].State.Status

        $markdown_active += "| $name | $ip | $($internalPorts -join ', ') | $($externalPorts -join ', ') | $image | $status |"
    }
    return $markdown_active
}


# Call the functions
$outputfile="output/docker-net-members-" +$network +".md"
$_markdown_hdr= Header -NetworkName $network
$_markdown_all= Get-AllDockerContainers -NetworkName $network
$_markdown_active= Get-ActiveDockerContainers -NetworkName $network


# Ensure output directory exists
if (!(Test-Path -Path "output")) { New-Item -ItemType Directory -Path "output" | Out-Null }
# Write to file
($_markdown_hdr -join "`n")  + ($_markdown_all -join "`n")  +  ($_markdown_active -join "`n") | Out-File $outputfile -Encoding UTF8
Write-Host "✅ "+ $outputfile+ " generated"
