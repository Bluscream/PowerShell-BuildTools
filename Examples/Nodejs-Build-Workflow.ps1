# Node.js Build Workflow Example
# Demonstrates how to use BuildTools module for Node.js projects

# Import the module
Import-Module BuildTools -Force

# Configuration
$ProjectPath = "C:\MyNodeProject"
$PackageManager = "npm"
$Repository = "myuser/mynodeapp"

Write-Host "=== Node.js Build Workflow Example ===" -ForegroundColor Cyan
Write-Host "Project: $ProjectPath" -ForegroundColor Gray
Write-Host "Package Manager: $PackageManager" -ForegroundColor Gray
Write-Host "Repository: $Repository" -ForegroundColor Gray
Write-Host ""

# Step 1: Install Dependencies
Write-Section "Install Dependencies"
Write-Host "Installing Node.js dependencies..." -ForegroundColor Green
$installResult = Nodejs-Install -ProjectPath $ProjectPath -PackageManager $PackageManager -Verbose
if ($installResult) {
    Write-Success "Dependencies installed successfully"
} else {
    Write-Failure "Failed to install dependencies"
    exit 1
}

# Step 2: Run Tests
Write-Section "Run Tests"
Write-Host "Running tests..." -ForegroundColor Green
$testResult = Nodejs-Test -ProjectPath $ProjectPath -PackageManager $PackageManager -Script "test" -Coverage -Verbose
if ($testResult) {
    Write-Success "Tests completed successfully"
} else {
    Write-Failure "Tests failed"
    exit 1
}

# Step 3: Build Project
Write-Section "Build Project"
Write-Host "Building Node.js project..." -ForegroundColor Green
$buildResult = Nodejs-Build -ProjectPath $ProjectPath -PackageManager $PackageManager -Script "build" -Production -Clean -Verbose
if ($buildResult) {
    Write-Success "Build completed successfully"
} else {
    Write-Failure "Build failed"
    exit 1
}

# Step 4: Update Build Timestamp
Write-Section "Update Build Timestamp"
Write-Host "Updating build timestamp..." -ForegroundColor Green
$timestamp = Get-UnixTimestamp
$timestampResult = Update-Build -Files @("$ProjectPath\dist\index.js") -Pattern "build:\s*(\d+)" -UseCurrentTime
if ($timestampResult) {
    Write-Success "Build timestamp updated successfully"
} else {
    Write-Warning "Failed to update build timestamp, continuing..."
}

# Step 5: Git Operations
Write-Section "Git Operations"
Write-Host "Committing changes..." -ForegroundColor Green
$commitResult = Git-CommitRepository -Path $ProjectPath -Message "Build $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -AutoMessage
if ($commitResult) {
    Write-Success "Changes committed successfully"
} else {
    Write-Failure "Failed to commit changes"
    exit 1
}

Write-Host "Pushing changes..." -ForegroundColor Green
$pushResult = Git-PushRepository -Path $ProjectPath -Force -SetUpstream
if ($pushResult) {
    Write-Success "Changes pushed successfully"
} else {
    Write-Failure "Failed to push changes"
    exit 1
}

# Step 6: GitHub Release
Write-Section "GitHub Release"
$releaseTag = $timestamp
Write-Host "Creating GitHub release..." -ForegroundColor Green
$releaseResult = GitHub-CreateRelease -Repository $Repository -Tag $releaseTag -Title "Build $releaseTag" -Notes "Automated build - $releaseTag" -Assets @("$ProjectPath\dist\index.js")
if ($releaseResult) {
    Write-Success "GitHub release created successfully"
} else {
    Write-Failure "Failed to create GitHub release"
    exit 1
}

# Summary
Write-Host ""
Write-Host "=== Node.js Build Workflow Complete ===" -ForegroundColor Green
Write-Host "Build Tag: $releaseTag" -ForegroundColor Cyan
Write-Host "Repository: $Repository" -ForegroundColor Cyan
Write-Host "Release: https://github.com/$Repository/releases/tag/$releaseTag" -ForegroundColor Cyan
Write-Host ""
