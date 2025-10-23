# Utility Functions
# Get-Username, Get-FileUnixTimestamp, Clear-BuildArtifacts, etc.

function Get-Username {
    <#
    .SYNOPSIS
    Gets username for various services (GitHub, Docker, etc.).
    
    .DESCRIPTION
    Attempts to determine username for various services using environment variables, git remotes, or system username.
    
    .PARAMETER Service
    Service to get username for (github, docker).
    
    .EXAMPLE
    Get-Username -Service "github"
    
    .EXAMPLE
    Get-Username -Service "docker"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet("github", "docker")]
        [string]$Service
    )
    
    $service = $Service.ToLower()
    $username = $null
    
    switch ($service) {
        "github" {
            # 1. Prefer explicit environment variable
            if ($env:GITHUB_USERNAME) {
                Write-Host "Using GITHUB_USERNAME environment variable: $($env:GITHUB_USERNAME)"
                $username = $env:GITHUB_USERNAME
                break
            }
            
            # 2. Try to extract from git remote
            if (Test-Path ".git") {
                try {
                    $remotes = git remote -v 2>$null
                    foreach ($remote in $remotes) {
                        if ($remote -match "github\.com[:/]([^/]+)/") {
                            $username = $matches[1]
                            Write-Host "Extracted GitHub username '$username' from git remote"
                            break
                        }
                    }
                }
                catch {
                    Write-Warning "Failed to read git remotes: $_"
                }
                if ($username) { break }
            }
            
            # 3. Fallback to system username
            if ($env:USERNAME) {
                Write-Host "Falling back to system USERNAME: $($env:USERNAME)"
                $username = $env:USERNAME
                break
            }
            
            Write-Error "Could not determine GitHub username. Set GITHUB_USERNAME environment variable or ensure a valid git remote exists."
            return $null
        }
        "docker" {
            # 1. Prefer explicit environment variable
            if ($env:DOCKER_USERNAME) {
                Write-Host "Using DOCKER_USERNAME environment variable: $($env:DOCKER_USERNAME)"
                $username = $env:DOCKER_USERNAME
                break
            }
            
            # 2. Fallback to system username
            if ($env:USERNAME) {
                Write-Host "Falling back to system USERNAME: $($env:USERNAME)"
                $username = $env:USERNAME
                break
            }
            
            Write-Error "Could not determine Docker username. Set DOCKER_USERNAME environment variable or ensure USERNAME is set."
            return $null
        }
    }
    
    if ($username) {
        return $username.ToLower()
    }
    else {
        Write-Error "Could not determine username for service '$Service'."
        return $null
    }
}

function Get-FileUnixTimestamp {
    <#
    .SYNOPSIS
    Gets the Unix timestamp of a file's last write time.
    
    .DESCRIPTION
    Returns the Unix timestamp (seconds since epoch) of a file's last write time.
    
    .PARAMETER FilePath
    Path to the file.
    
    .EXAMPLE
    Get-FileUnixTimestamp -FilePath "C:\MyFile.txt"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )
    
    if (-not (Test-Path $FilePath)) {
        Write-Warning "File not found: $FilePath"
        return 0
    }
    
    $fileInfo = Get-Item $FilePath
    return Get-UnixTimestamp -Date $fileInfo.LastWriteTime
}

function Get-UnixTimestamp {
    <#
    .SYNOPSIS
    Gets the Unix timestamp for a given date.
    
    .DESCRIPTION
    Returns the Unix timestamp (seconds since epoch) for a given date.
    
    .PARAMETER Date
    Date to convert (default: current date).
    
    .EXAMPLE
    Get-UnixTimestamp
    
    .EXAMPLE
    Get-UnixTimestamp -Date (Get-Date "2024-01-01")
    #>
    [CmdletBinding()]
    param(
        [datetime]$Date = (Get-Date)
    )
    
    $epoch = Get-Date "01/01/1970"
    $timeSpan = $Date - $epoch
    return [Math]::Floor($timeSpan.TotalSeconds)
}

function Clear-BuildArtifacts {
    <#
    .SYNOPSIS
    Clears build artifacts and temporary files.
    
    .DESCRIPTION
    Removes build artifacts, temporary files, and cleans up build directories.
    
    .PARAMETER ProjectPath
    Path to the project directory.
    
    .PARAMETER OutputPath
    Path to the output directory.
    
    .PARAMETER KillProcesses
    Kill running processes that might be using files.
    
    .PARAMETER ProcessNames
    Names of processes to kill.
    
    .EXAMPLE
    Clear-BuildArtifacts -ProjectPath "C:\MyProject" -OutputPath "C:\MyProject\bin"
    
    .EXAMPLE
    Clear-BuildArtifacts -ProjectPath "C:\MyProject" -KillProcesses -ProcessNames @("dotnet", "node")
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProjectPath,
        
        [string]$OutputPath,
        
        [switch]$KillProcesses,
        
        [string[]]$ProcessNames = @("dotnet", "node", "npm", "yarn", "pnpm", "bun")
    )
    
    Write-Host "Performing comprehensive build cleanup..." -ForegroundColor Yellow
    
    # Kill processes if requested
    if ($KillProcesses) {
        foreach ($procName in $ProcessNames) {
            $procs = Get-Process -Name $procName -ErrorAction SilentlyContinue
            if ($procs) {
                Write-Host "Killing running process(es) named $procName..." -ForegroundColor Yellow
                foreach ($proc in $procs) {
                    try {
                        Stop-Process -Id $proc.Id -Force -ErrorAction Stop
                        Write-Host "Killed process $($proc.Id) ($($proc.ProcessName))" -ForegroundColor Green
                    }
                    catch {
                        Write-Host "Failed to kill process $($proc.Id): $_" -ForegroundColor Yellow
                    }
                }
            }
        }
    }
    
    # Remove build directories
    $directoriesToRemove = @()
    
    if ($OutputPath) {
        $directoriesToRemove += $OutputPath
    }
    
    $directoriesToRemove += @(
        "$ProjectPath\obj",
        "$ProjectPath\bin",
        "$ProjectPath\node_modules",
        "$ProjectPath\dist",
        "$ProjectPath\build",
        "$ProjectPath\out",
        "$ProjectPath\.next",
        "$ProjectPath\.nuxt",
        "$ProjectPath\coverage",
        "$ProjectPath\.nyc_output"
    )
    
    foreach ($dir in $directoriesToRemove) {
        if (Test-Path $dir) {
            Write-Host "Removing directory: $dir" -ForegroundColor Yellow
            try {
                Remove-Item -Path $dir -Recurse -Force -ErrorAction Stop
                if (-not (Test-Path $dir)) {
                    Write-Host "Successfully removed: $dir" -ForegroundColor Green
                }
                else {
                    Write-Host "Failed to remove: $dir" -ForegroundColor Red
                }
            }
            catch {
                Write-Host "Failed to remove $($dir): $_" -ForegroundColor Red
            }
        }
    }
    
    # Remove temporary files
    $tempFiles = Get-ChildItem -Path $ProjectPath -Filter "*.tmp" -Recurse -ErrorAction SilentlyContinue
    foreach ($file in $tempFiles) {
        try {
            Remove-Item -Path $file.FullName -Force -ErrorAction Stop
            Write-Host "Removed temp file: $($file.Name)" -ForegroundColor Green
        }
        catch {
            Write-Host "Failed to remove temp file $($file.Name): $_" -ForegroundColor Yellow
        }
    }
    
    Write-Host "Build cleanup completed" -ForegroundColor Green
}

function Get-FileSize {
    <#
    .SYNOPSIS
    Gets the size of a file in KB.
    
    .DESCRIPTION
    Returns the size of a file in kilobytes, rounded to 2 decimal places.
    
    .PARAMETER Path
    Path to the file.
    
    .EXAMPLE
    Get-FileSize -Path "C:\MyFile.txt"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )
    
    if (Test-Path $Path) {
        $size = (Get-Item $Path).Length
        return [math]::Round($size / 1KB, 2)
    }
    return 0
}

function Test-Command {
    <#
    .SYNOPSIS
    Tests if a command is available.
    
    .DESCRIPTION
    Tests if a command is available in the current environment.
    
    .PARAMETER Command
    Command to test.
    
    .PARAMETER Name
    Display name for the command.
    
    .EXAMPLE
    Test-Command -Command "git" -Name "Git"
    
    .EXAMPLE
    Test-Command -Command "docker" -Name "Docker"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Command,
        
        [Parameter(Mandatory = $true)]
        [string]$Name
    )
    
    Write-Host "Checking for $Name..." -ForegroundColor Yellow
    try {
        $version = & $Command --version 2>$null
        if ($LASTEXITCODE -ne 0) { 
            throw "$Name not found" 
        }
        $versionLine = if ($version -is [array]) { $version[0] } else { $version }
        Write-Host "$Name version: $versionLine" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "$Name is not installed or not in PATH" -ForegroundColor Red
        return $false
    }
}

function Write-Section {
    <#
    .SYNOPSIS
    Writes a formatted section header.
    
    .DESCRIPTION
    Writes a formatted section header with consistent styling.
    
    .PARAMETER Title
    Title of the section.
    
    .EXAMPLE
    Write-Section -Title "Building Project"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Title
    )
    
    Write-Host ""
    Write-Host "=== $Title ===" -ForegroundColor Cyan
}

function Write-Success {
    <#
    .SYNOPSIS
    Writes a success message.
    
    .DESCRIPTION
    Writes a success message with consistent styling.
    
    .PARAMETER Message
    Success message to write.
    
    .EXAMPLE
    Write-Success -Message "Build completed successfully"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )
    
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Failure {
    <#
    .SYNOPSIS
    Writes a failure message.
    
    .DESCRIPTION
    Writes a failure message with consistent styling.
    
    .PARAMETER Message
    Failure message to write.
    
    .EXAMPLE
    Write-Failure -Message "Build failed"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )
    
    Write-Host "[FAILURE] $Message" -ForegroundColor Red
}

function Write-Warning {
    <#
    .SYNOPSIS
    Writes a warning message.
    
    .DESCRIPTION
    Writes a warning message with consistent styling.
    
    .PARAMETER Message
    Warning message to write.
    
    .EXAMPLE
    Write-Warning -Message "File not found"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )
    
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Info {
    <#
    .SYNOPSIS
    Writes an info message.
    
    .DESCRIPTION
    Writes an info message with consistent styling.
    
    .PARAMETER Message
    Info message to write.
    
    .EXAMPLE
    Write-Info -Message "Processing files"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )
    
    Write-Host "$Message" -ForegroundColor Yellow
}
