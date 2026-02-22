#!/usr/bin/env pwsh

# Build the Docker image for the oqtane application
# This script is designed to be run on Windows and will build the oqtane application,
# publish it, and save the published output as a zip file in the specified target directory. 
# The script accepts several parameters to customize the build and publish process.
# The script uses the `dotnet publish` command to build the application and then compresses the published output into a zip file.
# It should be noted that the script is intended to be run in a PowerShell environment and may not work correctly in other shells or environments.
# To run on linux or macOS, you may need to modify the script to use appropriate commands for those platforms.
# When successfully executed, the script will output the duration of the build and publish process, 
# and the published zip file will be located in the specified target directory with a name that includes the release version.
# Copy to zip file to you target environment and expand the zip file to get the published application ready for installation.
# Usage:
# .\publishOqtane.ps1 -Release "10.0.4" -RuntimeIdentifier "linux-x64" -SolutionBaseDir "C:\GitHub\Forks\oqtane.framework" -ImageTargetDir "C:\Trash\oqtane-images" -BuildConfiguration "Release"
# Parameters:
# -Release: The release version for the docker tag (mandatory)
# -SaveOnly: If set, only saves the image without building (optional)
# -NoSave: If set, does not save the image after building (optional)
[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, HelpMessage = "Release Version of oqtane build.")]
    [string]
    [Alias("rel")]
    $Release,
    # Runtime Identifier for the build
    [Parameter(Mandatory = $false)]
    [string]
    $RuntimeIdentifier = "linux-x64",
    # Solution Directory
    [Parameter(Mandatory = $false)] 
    [string]
    $SolutionBaseDir = "C:\GitHub\Forks\oqtane.framework",
    # Image Target Directory
    [Parameter(Mandatory = $false)]
    [string]
    $ImageTargetDir = "C:\Trash\oqtane-images",
    # Build Configuration
    [Parameter(Mandatory = $false)]
    [string]
    $BuildCOnfiguration = "Release"
)
if (-not $IsWindows) {
    Write-Host "This script is only supported on Windows." -ForegroundColor Red
    Exit -1
}
[DateTime]$startTime = ([System.DateTime]::Now)
$solutionDir = $SolutionBaseDir
Push-Location $solutionDir -StackName Initial
$releaseDir = Join-Path $ImageTargetDir  $Release
$publishDir = Join-Path $releaseDir "app" "publish" 
dotnet publish "Oqtane.Server/Oqtane.Server.csproj" -c $BuildCOnfiguration -o $publishDir /p:UseAppHost=false -r $RuntimeIdentifier --no-self-contained
if ($LASTEXITCODE -ne 0) {
    $now = Get-Date -Format u
    Write-Host "Build Ende um $($now)"
    Pop-Location -StackName Initial
    Exit -1
}
Compress-Archive -Path $publishDir\* -DestinationPath "$releaseDir\oqtane-$Release.zip" -Force
# expand-archive -Path ./oqtane-10.0.4.zip -DestinationPath app/
 
$now = Get-Date -Format u
[DateTime]$endTime = ([System.DateTime]::Now)
$duration = New-TimeSpan -Start $startTime -End $endTime
Write-Host "Finished $($now) - Duration ($duration) " -ForegroundColor Yellow
Pop-Location -StackName Initial
