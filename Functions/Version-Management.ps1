# Version Management Functions
# Set-Version, Bump-Version, Update-Build

function Set-Version {
    <#
    .SYNOPSIS
    Sets version numbers in files using regex patterns.
    
    .DESCRIPTION
    Updates version numbers in specified files using regex patterns. Supports multiple file types and version formats.
    
    .PARAMETER Files
    Array of file paths to update.
    
    .PARAMETER Pattern
    Regex pattern to match version numbers in files.
    
    .PARAMETER NewVersion
    The new version number to set.
    
    .PARAMETER Backup
    Create backup files before updating.
    
    .EXAMPLE
    Set-Version -Files @("file1.cs", "file2.js") -Pattern "version.*(\d+\.\d+\.\d+\.\d+)" -NewVersion "1.2.3.4"
    
    .EXAMPLE
    Set-Version -Files @("AssemblyInfo.cs") -Pattern 'AssemblyVersion\("([^"]+)"\)' -NewVersion "2.0.0.0" -Backup
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Files,
        
        [Parameter(Mandatory = $true)]
        [string]$Pattern,
        
        [Parameter(Mandatory = $true)]
        [string]$NewVersion,
        
        [switch]$Backup
    )
    
    $results = @()
    
    foreach ($file in $Files) {
        if (-not (Test-Path $file)) {
            Write-Warning "File not found: $file"
            continue
        }
        
        try {
            $content = Get-Content $file -Raw
            
            if ($Backup) {
                $backupFile = "$file.backup"
                Copy-Item $file $backupFile -Force
                Write-Host "Created backup: $backupFile" -ForegroundColor Yellow
            }
            
            # Replace version using the pattern
            $newContent = $content -replace $Pattern, "`$1$NewVersion"
            
            if ($newContent -ne $content) {
                Set-Content $file -Value $newContent -NoNewline
                Write-Host "Updated version in $file to $NewVersion" -ForegroundColor Green
                $results += @{
                    File       = $file
                    Success    = $true
                    OldVersion = "Unknown"
                    NewVersion = $NewVersion
                }
            }
            else {
                Write-Warning "No version pattern found in $file"
                $results += @{
                    File    = $file
                    Success = $false
                    Error   = "Pattern not found"
                }
            }
        }
        catch {
            Write-Error "Failed to update $($file): $_"
            $results += @{
                File    = $file
                Success = $false
                Error   = $_.Exception.Message
            }
        }
    }
    
    return $results
}

function Bump-Version {
    <#
    .SYNOPSIS
    Bumps version numbers in files by incrementing the build number.
    
    .DESCRIPTION
    Reads current version from files using regex patterns and increments the build number (last component).
    
    .PARAMETER Files
    Array of file paths to update.
    
    .PARAMETER Pattern
    Regex pattern to match version numbers in files.
    
    .PARAMETER Backup
    Create backup files before updating.
    
    .EXAMPLE
    Bump-Version -Files @("file1.cs") -Pattern "version.*(\d+\.\d+\.\d+\.\d+)"
    
    .EXAMPLE
    Bump-Version -Files @("AssemblyInfo.cs") -Pattern 'AssemblyVersion\("([^"]+)"\)' -Backup
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Files,
        
        [Parameter(Mandatory = $true)]
        [string]$Pattern,
        
        [switch]$Backup
    )
    
    $results = @()
    
    foreach ($file in $Files) {
        if (-not (Test-Path $file)) {
            Write-Warning "File not found: $file"
            continue
        }
        
        try {
            $content = Get-Content $file -Raw
            
            if ($content -match $Pattern) {
                $oldVersion = $matches[1]
                $newVersion = Bump-VersionNumber -OldVersion $oldVersion
                
                if ($Backup) {
                    $backupFile = "$file.backup"
                    Copy-Item $file $backupFile -Force
                    Write-Host "Created backup: $backupFile" -ForegroundColor Yellow
                }
                
                # Replace version using the pattern
                $newContent = $content -replace $Pattern, "`$1${newVersion}"
                
                if ($newContent -ne $content) {
                    Set-Content $file -Value $newContent -NoNewline
                    Write-Host "Bumped version in $file`: $oldVersion -> $newVersion" -ForegroundColor Green
                    $results += @{
                        File       = $file
                        Success    = $true
                        OldVersion = $oldVersion
                        NewVersion = $newVersion
                    }
                }
                else {
                    Write-Warning "Failed to update version in $file"
                    $results += @{
                        File    = $file
                        Success = $false
                        Error   = "Content replacement failed"
                    }
                }
            }
            else {
                Write-Warning "No version pattern found in $file"
                $results += @{
                    File    = $file
                    Success = $false
                    Error   = "Pattern not found"
                }
            }
        }
        catch {
            Write-Error "Failed to bump version in $($file): $_"
            $results += @{
                File    = $file
                Success = $false
                Error   = $_.Exception.Message
            }
        }
    }
    
    return $results
}

function Update-Build {
    <#
    .SYNOPSIS
    Updates build timestamps in files using Unix timestamps.
    
    .DESCRIPTION
    Replaces build timestamps in files with the last modified time of the file in Unix timestamp format.
    
    .PARAMETER Files
    Array of file paths to update.
    
    .PARAMETER Pattern
    Regex pattern to match build timestamps in files.
    
    .PARAMETER UseCurrentTime
    Use current time instead of file modification time.
    
    .EXAMPLE
    Update-Build -Files @("file1.js") -Pattern "build:\s*(\d+)"
    
    .EXAMPLE
    Update-Build -Files @("index.ts") -Pattern "build:\s*(\d+)" -UseCurrentTime
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Files,
        
        [Parameter(Mandatory = $true)]
        [string]$Pattern,
        
        [switch]$UseCurrentTime
    )
    
    $results = @()
    
    foreach ($file in $Files) {
        if (-not (Test-Path $file)) {
            Write-Warning "File not found: $file"
            continue
        }
        
        try {
            $content = Get-Content $file -Raw
            
            if ($content -match $Pattern) {
                $oldTimestamp = $matches[1]
                
                if ($UseCurrentTime) {
                    $newTimestamp = Get-UnixTimestamp
                }
                else {
                    $newTimestamp = Get-FileUnixTimestamp -FilePath $file
                }
                
                # Replace timestamp using the pattern
                $newContent = $content -replace $Pattern, "`$1${newTimestamp}"
                
                if ($newContent -ne $content) {
                    Set-Content $file -Value $newContent -NoNewline
                    Write-Host "Updated build timestamp in $file`: $oldTimestamp -> $newTimestamp" -ForegroundColor Green
                    $results += @{
                        File         = $file
                        Success      = $true
                        OldTimestamp = $oldTimestamp
                        NewTimestamp = $newTimestamp
                    }
                }
                else {
                    Write-Warning "Failed to update timestamp in $file"
                    $results += @{
                        File    = $file
                        Success = $false
                        Error   = "Content replacement failed"
                    }
                }
            }
            else {
                Write-Warning "No timestamp pattern found in $file"
                $results += @{
                    File    = $file
                    Success = $false
                    Error   = "Pattern not found"
                }
            }
        }
        catch {
            Write-Error "Failed to update timestamp in $($file): $_"
            $results += @{
                File    = $file
                Success = $false
                Error   = $_.Exception.Message
            }
        }
    }
    
    return $results
}

# Helper function to bump version numbers
function Bump-VersionNumber {
    param([string]$OldVersion)
    
    $parts = $OldVersion -split '\.'
    
    # Ensure at least 4 parts
    if (-not $OldVersion -or ($OldVersion -notmatch '^\d+(\.\d+){0,3}$')) {
        $OldVersion = "1.0.0.0"
        $parts = $OldVersion -split '\.'
    }
    
    while ($parts.Count -lt 4) { 
        $parts += '0' 
    }
    
    $major = [int]$parts[0]
    $minor = [int]$parts[1]
    $patch = [int]$parts[2]
    $build = [int]$parts[3]
    
    $build++
    if ($build -gt 9) {
        $build = 0
        $patch++
    }
    
    # If patch ever needs to roll over, add logic here
    $newVersion = "$major.$minor.$patch.$build"
    Write-Host "Bumped Version: $OldVersion -> $newVersion"
    return $newVersion
}
