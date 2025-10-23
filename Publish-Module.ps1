# Publish BuildTools Module to PowerShell Gallery
# This script helps publish the module to the PowerShell Gallery

param(
    [Parameter(Mandatory = $true)]
    [string]$NuGetApiKey,
    
    [string]$Repository = "PSGallery",
    
    [switch]$WhatIf,
    
    [switch]$Force
)

$ErrorActionPreference = "Stop"

Write-Host "=== BuildTools Module Publisher ===" -ForegroundColor Cyan
Write-Host "Repository: $Repository" -ForegroundColor Gray
Write-Host "WhatIf: $WhatIf" -ForegroundColor Gray
Write-Host ""

# Check if we're in the right directory
if (-not (Test-Path "BuildTools.psd1")) {
    Write-Error "BuildTools.psd1 not found. Please run this script from the module root directory."
    exit 1
}

# Validate module
Write-Host "Validating module..." -ForegroundColor Yellow
try {
    Import-Module .\BuildTools.psd1 -Force
    Write-Host "✓ Module loads successfully" -ForegroundColor Green
}
catch {
    Write-Error "Failed to load module: $_"
    exit 1
}

# Check module version
$manifest = Import-PowerShellDataFile -Path "BuildTools.psd1"
Write-Host "Module Version: $($manifest.ModuleVersion)" -ForegroundColor Cyan

# Test basic functionality
Write-Host "Testing basic functionality..." -ForegroundColor Yellow
try {
    $timestamp = Get-UnixTimestamp
    if ($timestamp -gt 0) {
        Write-Host "✓ Get-UnixTimestamp works" -ForegroundColor Green
    }
    
    $gitignoreContent = Get-GitIgnoreTemplate -Type "CSharp"
    if ($gitignoreContent) {
        Write-Host "✓ Template system works" -ForegroundColor Green
    }
    
    Write-Host "✓ Basic functionality tests passed" -ForegroundColor Green
}
catch {
    Write-Error "Basic functionality test failed: $_"
    exit 1
}

# Publish module
Write-Host "Publishing module to $Repository..." -ForegroundColor Yellow

$publishParams = @{
    Path        = "."
    NuGetApiKey = $NuGetApiKey
    Repository  = $Repository
    Force       = $Force
}

if ($WhatIf) {
    $publishParams["WhatIf"] = $true
    Write-Host "Running in WhatIf mode - no actual publish will occur" -ForegroundColor Yellow
}

try {
    Publish-Module @publishParams
    Write-Host "✓ Module published successfully!" -ForegroundColor Green
    Write-Host "Module is now available at: https://www.powershellgallery.com/packages/BuildTools" -ForegroundColor Cyan
}
catch {
    Write-Error "Failed to publish module: $_"
    exit 1
}

Write-Host ""
Write-Host "=== Publish Complete ===" -ForegroundColor Green
Write-Host "Your module is now available for installation with:" -ForegroundColor Cyan
Write-Host "Install-Module BuildTools -Scope CurrentUser" -ForegroundColor White
