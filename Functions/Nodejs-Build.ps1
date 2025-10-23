# Node.js Build Functions
# Nodejs-Build, Nodejs-Test, Nodejs-Install

function Nodejs-Build {
    <#
    .SYNOPSIS
    Builds a Node.js project using npm or yarn.
    
    .DESCRIPTION
    Builds a Node.js project with various build tools and configurations.
    
    .PARAMETER ProjectPath
    Path to the Node.js project directory.
    
    .PARAMETER PackageManager
    Package manager to use (npm, yarn, pnpm, bun).
    
    .PARAMETER Script
    Build script to run (default: build).
    
    .PARAMETER Production
    Build for production.
    
    .PARAMETER Clean
    Clean before building.
    
    .PARAMETER Verbose
    Enable verbose output.
    
    .EXAMPLE
    Nodejs-Build -ProjectPath "C:\MyProject" -PackageManager "npm"
    
    .EXAMPLE
    Nodejs-Build -ProjectPath "C:\MyProject" -Script "build:prod" -Production -Clean
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProjectPath,
        
        [ValidateSet("npm", "yarn", "pnpm", "bun")]
        [string]$PackageManager = "npm",
        
        [string]$Script = "build",
        
        [switch]$Production,
        
        [switch]$Clean,
        
        [switch]$VerboseOutput
    )
    
    if (-not (Test-Path $ProjectPath)) {
        Write-Error "Project directory not found: $ProjectPath"
        return $false
    }
    
    $originalLocation = Get-Location
    
    try {
        Set-Location $ProjectPath
        
        # Check if package.json exists
        if (-not (Test-Path "package.json")) {
            Write-Error "package.json not found in $ProjectPath"
            return $false
        }
        
        # Clean if requested
        if ($Clean) {
            Write-Host "Cleaning project..." -ForegroundColor Yellow
            $cleanScript = "clean"
            if ($PackageManager -eq "npm") {
                npm run $cleanScript 2>&1 | Out-Null
            }
            elseif ($PackageManager -eq "yarn") {
                yarn run $cleanScript 2>&1 | Out-Null
            }
            elseif ($PackageManager -eq "pnpm") {
                pnpm run $cleanScript 2>&1 | Out-Null
            }
            elseif ($PackageManager -eq "bun") {
                bun run $cleanScript 2>&1 | Out-Null
            }
        }
        
        # Build the project
        Write-Host "Building Node.js project..." -ForegroundColor Green
        Write-Host "Package manager: $PackageManager" -ForegroundColor Cyan
        Write-Host "Script: $Script" -ForegroundColor Cyan
        
        $buildArgs = @("run", $Script)
        
        if ($Production) {
            $buildArgs += "--production"
            Write-Host "Production build: true" -ForegroundColor Cyan
        }
        
        if ($VerboseOutput) {
            $buildArgs += "--verbose"
        }
        
        $buildOutput = $null
        $buildExitCode = 0
        
        if ($PackageManager -eq "npm") {
            $buildOutput = npm $buildArgs 2>&1 | Out-String
            $buildExitCode = $LASTEXITCODE
        }
        elseif ($PackageManager -eq "yarn") {
            $buildOutput = yarn $buildArgs 2>&1 | Out-String
            $buildExitCode = $LASTEXITCODE
        }
        elseif ($PackageManager -eq "pnpm") {
            $buildOutput = pnpm $buildArgs 2>&1 | Out-String
            $buildExitCode = $LASTEXITCODE
        }
        elseif ($PackageManager -eq "bun") {
            $buildOutput = bun $buildArgs 2>&1 | Out-String
            $buildExitCode = $LASTEXITCODE
        }
        
        if ($buildExitCode -eq 0) {
            Write-Host "Build completed successfully" -ForegroundColor Green
            return $true
        }
        else {
            Write-Host "Build failed with exit code: $buildExitCode" -ForegroundColor Red
            if ($buildOutput) {
                Write-Host "Build output:" -ForegroundColor Yellow
                Write-Host $buildOutput
            }
            return $false
        }
    }
    catch {
        Write-Error "Build failed: $_"
        return $false
    }
    finally {
        Set-Location $originalLocation
    }
}

function Nodejs-Test {
    <#
    .SYNOPSIS
    Runs tests for a Node.js project.
    
    .DESCRIPTION
    Runs tests using various test frameworks and package managers.
    
    .PARAMETER ProjectPath
    Path to the Node.js project directory.
    
    .PARAMETER PackageManager
    Package manager to use (npm, yarn, pnpm, bun).
    
    .PARAMETER Script
    Test script to run (default: test).
    
    .PARAMETER Coverage
    Generate test coverage report.
    
    .PARAMETER Watch
    Run tests in watch mode.
    
    .PARAMETER Verbose
    Enable verbose output.
    
    .EXAMPLE
    Nodejs-Test -ProjectPath "C:\MyProject" -PackageManager "npm"
    
    .EXAMPLE
    Nodejs-Test -ProjectPath "C:\MyProject" -Script "test:unit" -Coverage -Verbose
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProjectPath,
        
        [ValidateSet("npm", "yarn", "pnpm", "bun")]
        [string]$PackageManager = "npm",
        
        [string]$Script = "test",
        
        [switch]$Coverage,
        
        [switch]$Watch,
        
        [switch]$VerboseOutput
    )
    
    if (-not (Test-Path $ProjectPath)) {
        Write-Error "Project directory not found: $ProjectPath"
        return $false
    }
    
    $originalLocation = Get-Location
    
    try {
        Set-Location $ProjectPath
        
        # Check if package.json exists
        if (-not (Test-Path "package.json")) {
            Write-Error "package.json not found in $ProjectPath"
            return $false
        }
        
        # Check if tests directory exists
        $testsDir = Join-Path $ProjectPath "tests"
        if (-not (Test-Path $testsDir)) {
            Write-Warning "Tests directory not found, checking for test files..."
            $testFiles = Get-ChildItem -Path $ProjectPath -Filter "*.test.*" -Recurse -ErrorAction SilentlyContinue
            if ($testFiles.Count -eq 0) {
                Write-Warning "No test files found, skipping tests"
                return $true
            }
        }
        
        # Run tests
        Write-Host "Running Node.js tests..." -ForegroundColor Green
        Write-Host "Package manager: $PackageManager" -ForegroundColor Cyan
        Write-Host "Script: $Script" -ForegroundColor Cyan
        
        $testArgs = @("run", $Script)
        
        if ($Coverage) {
            $testArgs += "--coverage"
            Write-Host "Coverage: true" -ForegroundColor Cyan
        }
        
        if ($Watch) {
            $testArgs += "--watch"
            Write-Host "Watch mode: true" -ForegroundColor Cyan
        }
        
        if ($Verbose) {
            $testArgs += "--verbose"
        }
        
        $testOutput = $null
        $testExitCode = 0
        
        if ($PackageManager -eq "npm") {
            $testOutput = npm $testArgs 2>&1 | Out-String
            $testExitCode = $LASTEXITCODE
        }
        elseif ($PackageManager -eq "yarn") {
            $testOutput = yarn $testArgs 2>&1 | Out-String
            $testExitCode = $LASTEXITCODE
        }
        elseif ($PackageManager -eq "pnpm") {
            $testOutput = pnpm $testArgs 2>&1 | Out-String
            $testExitCode = $LASTEXITCODE
        }
        elseif ($PackageManager -eq "bun") {
            $testOutput = bun $testArgs 2>&1 | Out-String
            $testExitCode = $LASTEXITCODE
        }
        
        if ($testExitCode -eq 0) {
            Write-Host "Tests completed successfully" -ForegroundColor Green
            return $true
        }
        else {
            Write-Host "Tests failed with exit code: $testExitCode" -ForegroundColor Red
            if ($testOutput) {
                Write-Host "Test output:" -ForegroundColor Yellow
                Write-Host $testOutput
            }
            return $false
        }
    }
    catch {
        Write-Error "Tests failed: $_"
        return $false
    }
    finally {
        Set-Location $originalLocation
    }
}

function Nodejs-Install {
    <#
    .SYNOPSIS
    Installs dependencies for a Node.js project.
    
    .DESCRIPTION
    Installs dependencies using various package managers with different options.
    
    .PARAMETER ProjectPath
    Path to the Node.js project directory.
    
    .PARAMETER PackageManager
    Package manager to use (npm, yarn, pnpm, bun).
    
    .PARAMETER Production
    Install only production dependencies.
    
    .PARAMETER Dev
    Install only development dependencies.
    
    .PARAMETER Frozen
    Use frozen lockfile (yarn/pnpm only).
    
    .PARAMETER Verbose
    Enable verbose output.
    
    .EXAMPLE
    Nodejs-Install -ProjectPath "C:\MyProject" -PackageManager "npm"
    
    .EXAMPLE
    Nodejs-Install -ProjectPath "C:\MyProject" -PackageManager "yarn" -Frozen -Verbose
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProjectPath,
        
        [ValidateSet("npm", "yarn", "pnpm", "bun")]
        [string]$PackageManager = "npm",
        
        [switch]$Production,
        
        [switch]$Dev,
        
        [switch]$Frozen,
        
        [switch]$VerboseOutput
    )
    
    if (-not (Test-Path $ProjectPath)) {
        Write-Error "Project directory not found: $ProjectPath"
        return $false
    }
    
    $originalLocation = Get-Location
    
    try {
        Set-Location $ProjectPath
        
        # Check if package.json exists
        if (-not (Test-Path "package.json")) {
            Write-Error "package.json not found in $ProjectPath"
            return $false
        }
        
        # Install dependencies
        Write-Host "Installing Node.js dependencies..." -ForegroundColor Green
        Write-Host "Package manager: $PackageManager" -ForegroundColor Cyan
        
        $installArgs = @("install")
        
        if ($Production) {
            $installArgs += "--production"
            Write-Host "Production only: true" -ForegroundColor Cyan
        }
        
        if ($Dev) {
            $installArgs += "--dev"
            Write-Host "Development only: true" -ForegroundColor Cyan
        }
        
        if ($Frozen -and ($PackageManager -eq "yarn" -or $PackageManager -eq "pnpm")) {
            $installArgs += "--frozen-lockfile"
            Write-Host "Frozen lockfile: true" -ForegroundColor Cyan
        }
        
        if ($Verbose) {
            $installArgs += "--verbose"
        }
        
        $installOutput = $null
        $installExitCode = 0
        
        if ($PackageManager -eq "npm") {
            $installOutput = npm $installArgs 2>&1 | Out-String
            $installExitCode = $LASTEXITCODE
        }
        elseif ($PackageManager -eq "yarn") {
            $installOutput = yarn $installArgs 2>&1 | Out-String
            $installExitCode = $LASTEXITCODE
        }
        elseif ($PackageManager -eq "pnpm") {
            $installOutput = pnpm $installArgs 2>&1 | Out-String
            $installExitCode = $LASTEXITCODE
        }
        elseif ($PackageManager -eq "bun") {
            $installOutput = bun $installArgs 2>&1 | Out-String
            $installExitCode = $LASTEXITCODE
        }
        
        if ($installExitCode -eq 0) {
            Write-Host "Dependencies installed successfully" -ForegroundColor Green
            return $true
        }
        else {
            Write-Host "Installation failed with exit code: $installExitCode" -ForegroundColor Red
            if ($installOutput) {
                Write-Host "Install output:" -ForegroundColor Yellow
                Write-Host $installOutput
            }
            return $false
        }
    }
    catch {
        Write-Error "Installation failed: $_"
        return $false
    }
    finally {
        Set-Location $originalLocation
    }
}
