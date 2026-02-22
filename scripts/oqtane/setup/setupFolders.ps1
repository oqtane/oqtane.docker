#!/usr/bin/env pwsh
[CmdletBinding()]
param (
    # Copy the default appsettings.override.json to the target folder if it does not exist
    [Parameter(Mandatory = $false, HelpMessage = "Copy the default appsettings.override.json to the target folder, even if it already exists.")]
    [switch]
    $CopyAppSettingsOverride,
    # Remove all existing files in the target folder before copying the default appsettings.override.json
    [Parameter(Mandatory = $false, HelpMessage = "Remove all existing files in the target folder before creating the folder structure.")]
    [switch]
    $RemoveExistingFiles

)

if ($RemoveExistingFiles) {
    sudo rm -rf /srv/oqtane/*
}
# Create the necessary folder structure for the oqtane application and set appropriate permissions
sudo mkdir -p /srv/oqtane/app
sudo mkdir -p /srv/oqtane/ini
sudo mkdir -p /srv/oqtane/mysql
sudo mkdir -p /srv/caddy/html
sudo chmod -R 775 /srv/oqtane/app
sudo chmod -R 775 /srv/oqtane/ini
sudo cp oqtane_502.html /srv/caddy/html/oqtane_502.html
if ([System.IO.File]::Exists("/srv/oqtane/ini/appsettings.override.json") -eq $true -and $CopyAppSettingsOverride -eq $false) {
    Write-Host "appsettings.override.json already exists, skipping copy." -ForegroundColor Yellow
}
else {  
    sudo cp appsettings.override.json /srv/oqtane/ini/appsettings.override.json
}
# Set ownership of the created folders to the caddy user and group
# it is assumed that the caddy is running with the caddy user and group, which is the default configuration for caddy on linux.
sudo chown -R caddy:caddy /srv/caddy/html

