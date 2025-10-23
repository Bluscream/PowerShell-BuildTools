# Install BuildTools Module
# This script helps install the BuildTools module from various sources

param(
    [ValidateSet("PowerShellGallery", "GitHub", "Local")]
    [string]$Source = "PowerShellGallery",
    
    [string]$GitHubUrl = "https://github.com/Bluscream/PowerShell-BuildTools",
    
    [string]$LocalPath,
    
    [ValidateSet("CurrentUser", "AllUsers")]
    [string]$Scope = "CurrentUser",
    
    [switch]$Force,
    
    [switch]$WhatIf
)

$ErrorActionPreference = "Stop"

Write-Host "=== BuildTools Module Installer ===" -ForegroundColor Cyan
Write-Host "Source: $Source" -ForegroundColor Gray
Write-Host "Scope: $Scope" -ForegroundColor Gray
Write-Host ""

switch ($Source) {
    "PowerShellGallery" {
        Write-Host "Installing from PowerShell Gallery..." -ForegroundColor Yellow
        
        $installParams = @{
            Name  = "BuildTools"
            Scope = $Scope
            Force = $Force
        }
        
        if ($WhatIf) {
            $installParams["WhatIf"] = $true
            Write-Host "Running in WhatIf mode - no actual install will occur" -ForegroundColor Yellow
        }
        
        try {
            Install-Module @installParams
            Write-Host "✓ BuildTools installed from PowerShell Gallery" -ForegroundColor Green
        }
        catch {
            Write-Error "Failed to install from PowerShell Gallery: $_"
            exit 1
        }
    }
    
    "GitHub" {
        Write-Host "Installing from GitHub..." -ForegroundColor Yellow
        
        if (-not $LocalPath) {
            $LocalPath = "$env:TEMP\BuildTools"
        }
        
        # Download from GitHub
        $zipUrl = "$GitHubUrl/archive/main.zip"
        $zipPath = "$env:TEMP\BuildTools.zip"
        
        try {
            Write-Host "Downloading from GitHub..." -ForegroundColor Yellow
            Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath
            
            Write-Host "Extracting module..." -ForegroundColor Yellow
            Expand-Archive -Path $zipPath -DestinationPath $LocalPath -Force
            
            # Find the module directory
            $moduleDir = Get-ChildItem -Path $LocalPath -Directory | Where-Object { $_.Name -like "*BuildTools*" } | Select-Object -First 1
            if (-not $moduleDir) {
                throw "Could not find BuildTools directory in extracted files"
            }
            
            # Copy to PowerShell modules directory
            $psModulePath = if ($Scope -eq "AllUsers") { 
                "$env:ProgramFiles\WindowsPowerShell\Modules\BuildTools" 
            }
            else { 
                "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\BuildTools" 
            }
            
            if (Test-Path $psModulePath) {
                Remove-Item -Path $psModulePath -Recurse -Force
            }
            
            Copy-Item -Path $moduleDir.FullName -Destination $psModulePath -Recurse -Force
            Write-Host "✓ BuildTools installed from GitHub to $psModulePath" -ForegroundColor Green
            
            # Cleanup
            Remove-Item -Path $zipPath -Force -ErrorAction SilentlyContinue
            Remove-Item -Path $LocalPath -Recurse -Force -ErrorAction SilentlyContinue
            
        }
        catch {
            Write-Error "Failed to install from GitHub: $_"
            exit 1
        }
    }
    
    "Local" {
        if (-not $LocalPath -or -not (Test-Path $LocalPath)) {
            Write-Error "LocalPath must be specified and exist for local installation"
            exit 1
        }
        
        Write-Host "Installing from local path: $LocalPath" -ForegroundColor Yellow
        
        $psModulePath = if ($Scope -eq "AllUsers") { 
            "$env:ProgramFiles\WindowsPowerShell\Modules\BuildTools" 
        }
        else { 
            "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\BuildTools" 
        }
        
        try {
            if (Test-Path $psModulePath) {
                Remove-Item -Path $psModulePath -Recurse -Force
            }
            
            Copy-Item -Path $LocalPath -Destination $psModulePath -Recurse -Force
            Write-Host "✓ BuildTools installed from local path to $psModulePath" -ForegroundColor Green
            
        }
        catch {
            Write-Error "Failed to install from local path: $_"
            exit 1
        }
    }
}

# Test installation
Write-Host "Testing installation..." -ForegroundColor Yellow
try {
    Import-Module BuildTools -Force
    $functions = Get-Command -Module BuildTools
    Write-Host "✓ Module loaded successfully with $($functions.Count) functions" -ForegroundColor Green
    
    # Test basic functionality
    $timestamp = Get-UnixTimestamp
    Write-Host "✓ Get-UnixTimestamp works: $timestamp" -ForegroundColor Green
    
}
catch {
    Write-Error "Module installation test failed: $_"
    exit 1
}

Write-Host ""
Write-Host "=== Installation Complete ===" -ForegroundColor Green
Write-Host "You can now use BuildTools with:" -ForegroundColor Cyan
Write-Host "Import-Module BuildTools" -ForegroundColor White
Write-Host ""
Write-Host "Available functions:" -ForegroundColor Cyan
Get-Command -Module BuildTools | Select-Object -First 5 | ForEach-Object { Write-Host "  - $($_.Name)" -ForegroundColor White }
Write-Host "  ... and more!" -ForegroundColor White
