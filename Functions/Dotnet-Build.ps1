# .NET Build Functions
# Dotnet-Build, Dotnet-Publish, Dotnet-Clean

function Dotnet-Build {
    <#
    .SYNOPSIS
    Builds a .NET project with specified configuration and architecture.
    
    .DESCRIPTION
    Builds a .NET project using dotnet build with various configuration options.
    
    .PARAMETER ProjectPath
    Path to the .NET project file (.csproj) or solution file (.sln).
    
    .PARAMETER Configuration
    Build configuration (Debug, Release, etc.).
    
    .PARAMETER Architecture
    Target architecture (win-x64, win-x86, linux-x64, etc.).
    
    .PARAMETER Framework
    Target framework (net8.0, net7.0, etc.).
    
    .PARAMETER OutputPath
    Output directory for build artifacts.
    
    .PARAMETER Clean
    Clean before building.
    
    .PARAMETER Verbose
    Enable verbose output.
    
    .EXAMPLE
    Dotnet-Build -ProjectPath "MyProject.csproj" -Configuration "Release" -Architecture "win-x64"
    
    .EXAMPLE
    Dotnet-Build -ProjectPath "MySolution.sln" -Configuration "Debug" -Clean -Verbose
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProjectPath,
        
        [ValidateSet("Debug", "Release", "ReleaseOptimized", "ReleaseMinimal")]
        [string]$Configuration = "Release",
        
        [string]$Architecture = "win-x64",
        
        [string]$Framework,
        
        [string]$OutputPath,
        
        [switch]$Clean,
        
        [switch]$VerboseOutput
    )
    
    if (-not (Test-Path $ProjectPath)) {
        Write-Error "Project file not found: $ProjectPath"
        return $false
    }
    
    try {
        # Clean if requested
        if ($Clean) {
            Write-Host "Cleaning project..." -ForegroundColor Yellow
            dotnet clean $ProjectPath -c $Configuration
            if ($LASTEXITCODE -ne 0) {
                Write-Warning "Clean failed, continuing with build..."
            }
        }
        
        # Build the project
        Write-Host "Building $ProjectPath..." -ForegroundColor Green
        Write-Host "Configuration: $Configuration" -ForegroundColor Cyan
        Write-Host "Architecture: $Architecture" -ForegroundColor Cyan
        
        $buildArgs = @("build", $ProjectPath, "-c", $Configuration, "-r", $Architecture)
        
        if ($Framework) {
            $buildArgs += @("-f", $Framework)
            Write-Host "Framework: $Framework" -ForegroundColor Cyan
        }
        
        if ($OutputPath) {
            $buildArgs += @("-o", $OutputPath)
            Write-Host "Output: $OutputPath" -ForegroundColor Cyan
        }
        
        if ($VerboseOutput) {
            $buildArgs += "--verbosity", "detailed"
        }
        
        $buildOutput = dotnet $buildArgs 2>&1
        $buildExitCode = $LASTEXITCODE
        
        if ($buildExitCode -eq 0) {
            Write-Host "Build completed successfully" -ForegroundColor Green
            return $true
        }
        else {
            Write-Host "Build failed with exit code: $buildExitCode" -ForegroundColor Red
            Write-Host "Build output:" -ForegroundColor Yellow
            Write-Host $buildOutput
            return $false
        }
    }
    catch {
        Write-Error "Build failed: $_"
        return $false
    }
}

function Dotnet-Publish {
    <#
    .SYNOPSIS
    Publishes a .NET project with specified configuration and architecture.
    
    .DESCRIPTION
    Publishes a .NET project using dotnet publish with various configuration options.
    
    .PARAMETER ProjectPath
    Path to the .NET project file (.csproj) or solution file (.sln).
    
    .PARAMETER Configuration
    Build configuration (Debug, Release, etc.).
    
    .PARAMETER Architecture
    Target architecture (win-x64, win-x86, linux-x64, etc.).
    
    .PARAMETER Framework
    Target framework (net8.0, net7.0, etc.).
    
    .PARAMETER OutputPath
    Output directory for published artifacts.
    
    .PARAMETER SelfContained
    Create self-contained deployment.
    
    .PARAMETER SingleFile
    Create single-file deployment.
    
    .PARAMETER Trimmed
    Enable trimming for smaller deployment.
    
    .PARAMETER Clean
    Clean before publishing.
    
    .PARAMETER Verbose
    Enable verbose output.
    
    .EXAMPLE
    Dotnet-Publish -ProjectPath "MyProject.csproj" -Configuration "Release" -Architecture "win-x64" -SelfContained
    
    .EXAMPLE
    Dotnet-Publish -ProjectPath "MyProject.csproj" -Configuration "Release" -SingleFile -Trimmed
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProjectPath,
        
        [ValidateSet("Debug", "Release", "ReleaseOptimized", "ReleaseMinimal")]
        [string]$Configuration = "Release",
        
        [string]$Architecture = "win-x64",
        
        [string]$Framework,
        
        [string]$OutputPath,
        
        [switch]$SelfContained,
        
        [switch]$SingleFile,
        
        [switch]$Trimmed,
        
        [switch]$Clean,
        
        [switch]$VerboseOutput
    )
    
    if (-not (Test-Path $ProjectPath)) {
        Write-Error "Project file not found: $ProjectPath"
        return $false
    }
    
    try {
        # Clean if requested
        if ($Clean) {
            Write-Host "Cleaning project..." -ForegroundColor Yellow
            dotnet clean $ProjectPath -c $Configuration
            if ($LASTEXITCODE -ne 0) {
                Write-Warning "Clean failed, continuing with publish..."
            }
        }
        
        # Publish the project
        Write-Host "Publishing $ProjectPath..." -ForegroundColor Green
        Write-Host "Configuration: $Configuration" -ForegroundColor Cyan
        Write-Host "Architecture: $Architecture" -ForegroundColor Cyan
        
        $publishArgs = @("publish", $ProjectPath, "-c", $Configuration, "-r", $Architecture)
        
        if ($Framework) {
            $publishArgs += @("-f", $Framework)
            Write-Host "Framework: $Framework" -ForegroundColor Cyan
        }
        
        if ($OutputPath) {
            $publishArgs += @("-o", $OutputPath)
            Write-Host "Output: $OutputPath" -ForegroundColor Cyan
        }
        
        if ($SelfContained) {
            $publishArgs += "--self-contained", "true"
            Write-Host "Self-contained: true" -ForegroundColor Cyan
        }
        else {
            $publishArgs += "--self-contained", "false"
        }
        
        if ($SingleFile) {
            $publishArgs += "/p:PublishSingleFile=true"
            Write-Host "Single file: true" -ForegroundColor Cyan
        }
        
        if ($Trimmed) {
            $publishArgs += "/p:PublishTrimmed=true"
            Write-Host "Trimmed: true" -ForegroundColor Cyan
        }
        
        if ($Verbose) {
            $publishArgs += "--verbosity", "detailed"
        }
        
        # Add release optimizations
        if ($Configuration -eq "Release") {
            $publishArgs += @(
                "/p:OptimizeImplicitlyTriggeredBuild=true",
                "/p:EnableCompressionInSingleFile=true",
                "/p:DebugType=None",
                "/p:DebugSymbols=false"
            )
            
            # Additional optimizations for standalone builds
            if ($SelfContained) {
                $publishArgs += @(
                    "/p:TrimMode=link",
                    "/p:EnableUnsafeBinaryFormatterSerialization=false",
                    "/p:EnableUnsafeUTF7Encoding=false",
                    "/p:EventSourceSupport=false",
                    "/p:HttpActivityPropagationSupport=false",
                    "/p:InvariantGlobalization=true",
                    "/p:MetadataUpdaterSupport=false"
                )
            }
        }
        
        $publishOutput = dotnet $publishArgs 2>&1
        $publishExitCode = $LASTEXITCODE
        
        if ($publishExitCode -eq 0) {
            Write-Host "Publish completed successfully" -ForegroundColor Green
            
            # Try to extract output path from publish output
            $lines = $publishOutput -split "`n"
            foreach ($line in $lines) {
                if ($line -match ".* -> (.+\\publish\\)$") {
                    $extractedPath = $matches[1].Trim()
                    Write-Host "Published to: $extractedPath" -ForegroundColor Green
                    return $extractedPath
                }
            }
            
            return $true
        }
        else {
            Write-Host "Publish failed with exit code: $publishExitCode" -ForegroundColor Red
            Write-Host "Publish output:" -ForegroundColor Yellow
            Write-Host $publishOutput
            return $false
        }
    }
    catch {
        Write-Error "Publish failed: $_"
        return $false
    }
}

function Dotnet-Clean {
    <#
    .SYNOPSIS
    Cleans a .NET project build artifacts.
    
    .DESCRIPTION
    Removes build artifacts from a .NET project using dotnet clean.
    
    .PARAMETER ProjectPath
    Path to the .NET project file (.csproj) or solution file (.sln).
    
    .PARAMETER Configuration
    Build configuration to clean (Debug, Release, etc.).
    
    .PARAMETER Verbose
    Enable verbose output.
    
    .EXAMPLE
    Dotnet-Clean -ProjectPath "MyProject.csproj" -Configuration "Release"
    
    .EXAMPLE
    Dotnet-Clean -ProjectPath "MySolution.sln" -Verbose
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProjectPath,
        
        [ValidateSet("Debug", "Release", "ReleaseOptimized", "ReleaseMinimal")]
        [string]$Configuration = "Release",
        
        [switch]$VerboseOutput
    )
    
    if (-not (Test-Path $ProjectPath)) {
        Write-Error "Project file not found: $ProjectPath"
        return $false
    }
    
    try {
        Write-Host "Cleaning $ProjectPath..." -ForegroundColor Yellow
        Write-Host "Configuration: $Configuration" -ForegroundColor Cyan
        
        $cleanArgs = @("clean", $ProjectPath, "-c", $Configuration)
        
        if ($Verbose) {
            $cleanArgs += "--verbosity", "detailed"
        }
        
        $cleanOutput = dotnet $cleanArgs 2>&1
        $cleanExitCode = $LASTEXITCODE
        
        if ($cleanExitCode -eq 0) {
            Write-Host "Clean completed successfully" -ForegroundColor Green
            return $true
        }
        else {
            Write-Host "Clean failed with exit code: $cleanExitCode" -ForegroundColor Red
            Write-Host "Clean output:" -ForegroundColor Yellow
            Write-Host $cleanOutput
            return $false
        }
    }
    catch {
        Write-Error "Clean failed: $_"
        return $false
    }
}
