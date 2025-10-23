# Docker Operations Functions
# Docker-Build, Docker-Publish, Docker-StartIfNeeded

function Docker-Build {
    <#
    .SYNOPSIS
    Builds Docker images with specified configurations.
    
    .DESCRIPTION
    Builds Docker images using Dockerfile with various build options and configurations.
    
    .PARAMETER ProjectPath
    Path to the project directory containing Dockerfile.
    
    .PARAMETER Dockerfile
    Path to the Dockerfile (default: Dockerfile).
    
    .PARAMETER Tag
    Tag for the Docker image.
    
    .PARAMETER BuildArgs
    Build arguments to pass to Docker build.
    
    .PARAMETER Platform
    Target platform for the build.
    
    .PARAMETER NoCache
    Build without using cache.
    
    .PARAMETER Pull
    Always attempt to pull a newer version of the base image.
    
    .PARAMETER Verbose
    Enable verbose output.
    
    .EXAMPLE
    Docker-Build -ProjectPath "C:\MyProject" -Tag "myapp:latest"
    
    .EXAMPLE
    Docker-Build -ProjectPath "C:\MyProject" -Dockerfile "Dockerfile.prod" -Tag "myapp:1.0" -NoCache
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProjectPath,
        
        [string]$Dockerfile = "Dockerfile",
        
        [Parameter(Mandatory = $true)]
        [string]$Tag,
        
        [hashtable]$BuildArgs = @{},
        
        [string]$Platform,
        
        [switch]$NoCache,
        
        [switch]$Pull,
        
        [switch]$VerboseOutput
    )
    
    if (-not (Test-Path $ProjectPath)) {
        Write-Error "Project directory not found: $ProjectPath"
        return $false
    }
    
    $dockerfilePath = Join-Path $ProjectPath $Dockerfile
    if (-not (Test-Path $dockerfilePath)) {
        Write-Error "Dockerfile not found: $dockerfilePath"
        return $false
    }
    
    # Ensure Docker is running
    if (-not (Docker-StartIfNeeded)) {
        Write-Error "Docker is not available"
        return $false
    }
    
    $originalLocation = Get-Location
    
    try {
        Set-Location $ProjectPath
        
        Write-Host "Building Docker image..." -ForegroundColor Green
        Write-Host "Project: $ProjectPath" -ForegroundColor Cyan
        Write-Host "Dockerfile: $Dockerfile" -ForegroundColor Cyan
        Write-Host "Tag: $Tag" -ForegroundColor Cyan
        
        $buildArgs = @("build", "-f", $Dockerfile, "-t", $Tag)
        
        if ($Platform) {
            $buildArgs += @("--platform", $Platform)
            Write-Host "Platform: $Platform" -ForegroundColor Cyan
        }
        
        if ($NoCache) {
            $buildArgs += "--no-cache"
            Write-Host "No cache: true" -ForegroundColor Cyan
        }
        
        if ($Pull) {
            $buildArgs += "--pull"
            Write-Host "Pull: true" -ForegroundColor Cyan
        }
        
        if ($VerboseOutput) {
            $buildArgs += "--progress=plain"
        }
        
        # Add build arguments
        foreach ($key in $BuildArgs.Keys) {
            $buildArgs += @("--build-arg", "${key}=$($BuildArgs[$key])")
        }
        
        # Add context
        $buildArgs += "."
        
        $buildOutput = docker $buildArgs 2>&1 | Out-String
        $buildExitCode = $LASTEXITCODE
        
        if ($buildExitCode -eq 0) {
            Write-Host "Docker image built successfully: $Tag" -ForegroundColor Green
            return $true
        }
        else {
            Write-Host "Docker build failed with exit code: $buildExitCode" -ForegroundColor Red
            if ($buildOutput) {
                Write-Host "Build output:" -ForegroundColor Yellow
                Write-Host $buildOutput
            }
            return $false
        }
    }
    catch {
        Write-Error "Docker build failed: $_"
        return $false
    }
    finally {
        Set-Location $originalLocation
    }
}

function Docker-Publish {
    <#
    .SYNOPSIS
    Publishes Docker images to registries.
    
    .DESCRIPTION
    Publishes Docker images to Docker Hub, GitHub Container Registry, or other registries.
    
    .PARAMETER ImageName
    Name of the Docker image to publish.
    
    .PARAMETER Registry
    Target registry (dockerhub, ghcr, custom).
    
    .PARAMETER Username
    Username for the registry.
    
    .PARAMETER Password
    Password or token for the registry.
    
    .PARAMETER Tags
    Array of tags to publish.
    
    .PARAMETER Latest
    Also tag as latest.
    
    .PARAMETER Verbose
    Enable verbose output.
    
    .EXAMPLE
    Docker-Publish -ImageName "myapp" -Registry "dockerhub" -Username "myuser" -Tags @("1.0", "latest")
    
    .EXAMPLE
    Docker-Publish -ImageName "myapp" -Registry "ghcr" -Username "myuser" -Tags @("1.0") -Latest
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ImageName,
        
        [ValidateSet("dockerhub", "ghcr", "custom")]
        [string]$Registry = "dockerhub",
        
        [string]$Username,
        
        [SecureString]$Password,
        
        [string[]]$Tags = @("latest"),
        
        [switch]$Latest,
        
        [switch]$VerboseOutput
    )
    
    # Ensure Docker is running
    if (-not (Docker-StartIfNeeded)) {
        Write-Error "Docker is not available"
        return $false
    }
    
    try {
        # Get username if not provided
        if (-not $Username) {
            $Username = Get-Username -Service "docker"
            if (-not $Username) {
                Write-Error "Could not determine Docker username"
                return $false
            }
        }
        
        # Determine registry URL
        $registryUrl = switch ($Registry) {
            "dockerhub" { "$Username/$ImageName" }
            "ghcr" { "ghcr.io/$Username/$ImageName" }
            "custom" { $ImageName }
        }
        
        Write-Host "Publishing Docker image..." -ForegroundColor Green
        Write-Host "Image: $ImageName" -ForegroundColor Cyan
        Write-Host "Registry: $Registry" -ForegroundColor Cyan
        Write-Host "Full name: $registryUrl" -ForegroundColor Cyan
        
        $success = $true
        
        # Tag and push each tag
        foreach ($tag in $Tags) {
            $fullTag = "${registryUrl}:$tag"
            
            Write-Host "Tagging image as $fullTag..." -ForegroundColor Yellow
            docker tag $ImageName $fullTag
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "Pushing $fullTag..." -ForegroundColor Yellow
                docker push $fullTag
                
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "Successfully pushed $fullTag" -ForegroundColor Green
                }
                else {
                    Write-Host "Failed to push $fullTag" -ForegroundColor Red
                    $success = $false
                }
            }
            else {
                Write-Host "Failed to tag $fullTag" -ForegroundColor Red
                $success = $false
            }
        }
        
        # Tag as latest if requested
        if ($Latest -and $Tags -notcontains "latest") {
            $latestTag = "${registryUrl}:latest"
            
            Write-Host "Tagging image as $latestTag..." -ForegroundColor Yellow
            docker tag $ImageName $latestTag
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "Pushing $latestTag..." -ForegroundColor Yellow
                docker push $latestTag
                
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "Successfully pushed $latestTag" -ForegroundColor Green
                }
                else {
                    Write-Host "Failed to push $latestTag" -ForegroundColor Red
                    $success = $false
                }
            }
            else {
                Write-Host "Failed to tag $latestTag" -ForegroundColor Red
                $success = $false
            }
        }
        
        if ($success) {
            Write-Host "Docker image published successfully" -ForegroundColor Green
            return $true
        }
        else {
            Write-Host "Some operations failed" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Error "Docker publish failed: $_"
        return $false
    }
}

function Docker-StartIfNeeded {
    <#
    .SYNOPSIS
    Ensures Docker is running and starts it if needed.
    
    .DESCRIPTION
    Checks if Docker daemon is running and attempts to start it if not available.
    
    .EXAMPLE
    Docker-StartIfNeeded
    #>
    [CmdletBinding()]
    param()
    
    Write-Host "Checking Docker status..." -ForegroundColor Yellow
    
    # Check if Docker daemon is accessible
    try {
        docker info --format "{{.ServerVersion}}" 2>$null | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Docker daemon is running" -ForegroundColor Green
            return $true
        }
    }
    catch {
        Write-Host "Docker daemon not accessible" -ForegroundColor Yellow
    }
    
    Write-Host "Docker daemon not running. Checking Docker service..." -ForegroundColor Yellow
    
    # Check and start Docker Windows service if needed
    try {
        $dockerService = Get-Service -Name "com.docker.service" -ErrorAction SilentlyContinue
        if ($dockerService) {
            if ($dockerService.Status -ne "Running") {
                Write-Host "Starting Docker service (com.docker.service)..." -ForegroundColor Yellow
                Start-Service -Name "com.docker.service" -ErrorAction Stop
                Write-Host "Docker service started successfully" -ForegroundColor Green
                
                # Wait a moment for the service to fully start
                Start-Sleep -Seconds 3
                
                # Check if Docker daemon is now accessible
                try {
                    docker info --format "{{.ServerVersion}}" 2>$null | Out-Null
                    if ($LASTEXITCODE -eq 0) {
                        Write-Host "Docker daemon is now running after service start" -ForegroundColor Green
                        return $true
                    }
                }
                catch {
                    Write-Host "Docker daemon still not accessible after service start" -ForegroundColor Yellow
                }
            }
            else {
                Write-Host "Docker service is already running" -ForegroundColor Green
            }
        }
        else {
            Write-Host "Docker service (com.docker.service) not found" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "Failed to manage Docker service: $_" -ForegroundColor Yellow
    }
    
    Write-Host "Attempting to start Docker Desktop..." -ForegroundColor Yellow
    
    # Try to start Docker Desktop application
    $dockerDesktopPaths = @(
        "${env:ProgramFiles}\Docker\Docker\Docker Desktop.exe",
        "${env:ProgramFiles(x86)}\Docker\Docker\Docker Desktop.exe",
        "${env:LOCALAPPDATA}\Programs\Docker\Docker\Docker Desktop.exe"
    )
    
    $dockerStarted = $false
    foreach ($path in $dockerDesktopPaths) {
        if (Test-Path $path) {
            Write-Host "Starting Docker Desktop from: $path"
            try {
                Start-Process -FilePath $path -ErrorAction Stop
                $dockerStarted = $true
                break
            }
            catch {
                Write-Host "Failed to start Docker Desktop from $($path): $_" -ForegroundColor Yellow
            }
        }
    }
    
    if (-not $dockerStarted) {
        Write-Host "Could not find Docker Desktop executable. Trying to start via Start-Process..." -ForegroundColor Yellow
        try {
            Start-Process "Docker Desktop" -ErrorAction Stop
            $dockerStarted = $true
        }
        catch {
            Write-Host "Failed to start Docker Desktop: $_" -ForegroundColor Yellow
        }
    }
    
    if ($dockerStarted) {
        Write-Host "Docker Desktop starting... waiting for daemon to be ready..." -ForegroundColor Yellow
        
        # Wait for Docker daemon to be ready (up to 60 seconds)
        $maxWaitTime = 60
        $waitTime = 0
        $interval = 2
        
        while ($waitTime -lt $maxWaitTime) {
            Start-Sleep -Seconds $interval
            $waitTime += $interval
            
            try {
                docker info --format "{{.ServerVersion}}" 2>$null | Out-Null
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "Docker daemon is now ready!" -ForegroundColor Green
                    return $true
                }
            }
            catch {
                # Continue waiting
            }
            
            Write-Host "Still waiting for Docker daemon... ($waitTime/$maxWaitTime seconds)" -ForegroundColor Yellow
        }
        
        Write-Host "Docker daemon did not start within $maxWaitTime seconds" -ForegroundColor Red
        return $false
    }
    
    Write-Host "Failed to start Docker Desktop" -ForegroundColor Red
    return $false
}
