# Setup GitHub Repository for BuildTools Module
# This script helps set up the GitHub repository for publishing

param(
    [Parameter(Mandatory = $true)]
    [string]$GitHubUsername,
    
    [string]$RepositoryName = "PowerShell-BuildTools",
    
    [string]$Description = "A comprehensive PowerShell module for build automation, version management, and publishing workflows",
    
    [switch]$Public = $true,
    
    [switch]$InitializeGit = $true,
    
    [switch]$CreateInitialCommit = $true
)

$ErrorActionPreference = "Stop"

Write-Host "=== GitHub Repository Setup for BuildTools ===" -ForegroundColor Cyan
Write-Host "Repository: $GitHubUsername/$RepositoryName" -ForegroundColor Gray
Write-Host "Description: $Description" -ForegroundColor Gray
Write-Host "Public: $Public" -ForegroundColor Gray
Write-Host ""

# Check if we're in the right directory
if (-not (Test-Path "BuildTools.psd1")) {
    Write-Error "BuildTools.psd1 not found. Please run this script from the module root directory."
    exit 1
}

# Check if git is available
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error "Git is not installed or not in PATH."
    exit 1
}

# Check if GitHub CLI is available
$hasGhCli = Get-Command gh -ErrorAction SilentlyContinue
if (-not $hasGhCli) {
    Write-Warning "GitHub CLI (gh) not found. You'll need to create the repository manually."
    Write-Host "Please go to https://github.com/new and create a repository named '$RepositoryName'" -ForegroundColor Yellow
    Write-Host "Then run: git remote add origin https://github.com/$GitHubUsername/$RepositoryName.git" -ForegroundColor Yellow
}
else {
    Write-Host "Creating GitHub repository..." -ForegroundColor Yellow
    
    $repoArgs = @(
        "repo", "create", $RepositoryName,
        "--description", $Description,
        "--public" = $Public
    )
    
    if (-not $Public) {
        $repoArgs = $repoArgs -replace "--public", "--private"
    }
    
    try {
        gh $repoArgs
        Write-Host "✓ Repository created successfully" -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to create repository: $_"
        exit 1
    }
}

# Initialize git if requested
if ($InitializeGit) {
    Write-Host "Initializing git repository..." -ForegroundColor Yellow
    
    if (Test-Path ".git") {
        Write-Host "Git repository already exists" -ForegroundColor Yellow
    }
    else {
        git init
        git branch -M main
        Write-Host "✓ Git repository initialized" -ForegroundColor Green
    }
    
    # Add remote origin
    $remoteUrl = "https://github.com/$GitHubUsername/$RepositoryName.git"
    git remote add origin $remoteUrl
    Write-Host "✓ Remote origin added: $remoteUrl" -ForegroundColor Green
}

# Create initial commit if requested
if ($CreateInitialCommit) {
    Write-Host "Creating initial commit..." -ForegroundColor Yellow
    
    # Add all files
    git add .
    
    # Create commit
    git commit -m "Initial commit: BuildTools PowerShell module v1.0.0

- Comprehensive build automation and version management
- Git operations with template support
- .NET, Node.js, and Docker build functions
- GitHub release management
- Template system with external files
- Utility functions for file operations
- Complete documentation and examples"
    
    Write-Host "✓ Initial commit created" -ForegroundColor Green
    
    # Push to GitHub
    Write-Host "Pushing to GitHub..." -ForegroundColor Yellow
    git push -u origin main
    Write-Host "✓ Code pushed to GitHub" -ForegroundColor Green
}

# Create initial release
Write-Host "Creating initial release..." -ForegroundColor Yellow
try {
    gh release create v1.0.0 --title "BuildTools v1.0.0" --notes "Initial release of BuildTools PowerShell module

## Features
- Version management functions
- Git operations with templates
- Build automation for .NET, Node.js, and Docker
- GitHub release management
- Comprehensive utility functions
- Template system with external files

## Installation
\`\`\`powershell
Install-Module BuildTools -Scope CurrentUser
\`\`\`" --latest
    Write-Host "✓ Initial release created" -ForegroundColor Green
} catch {
    Write-Warning "Failed to create release: $_"
    Write-Host "You can create the release manually at: https://github.com/$GitHubUsername/$RepositoryName/releases/new" -ForegroundColor Yellow
}

# Display next steps
Write-Host ""
Write-Host "=== Setup Complete ===" -ForegroundColor Green
Write-Host "Repository URL: https://github.com/$GitHubUsername/$RepositoryName" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Set up PowerShell Gallery API key in GitHub Secrets:" -ForegroundColor White
Write-Host "   - Go to: https://github.com/$GitHubUsername/$RepositoryName/settings/secrets/actions" -ForegroundColor White
Write-Host "   - Add secret: POWERSHELLGALLERY_API_KEY" -ForegroundColor White
Write-Host ""
Write-Host "2. Test the module:" -ForegroundColor White
Write-Host "   Import-Module BuildTools" -ForegroundColor White
Write-Host "   Get-Command -Module BuildTools" -ForegroundColor White
Write-Host ""
Write-Host "3. Publish to PowerShell Gallery:" -ForegroundColor White
Write-Host "   .\Publish-Module.ps1 -NuGetApiKey 'YOUR_API_KEY'" -ForegroundColor White
Write-Host ""
Write-Host "4. Users can install with:" -ForegroundColor White
Write-Host "   Install-Module BuildTools -Scope CurrentUser" -ForegroundColor White
