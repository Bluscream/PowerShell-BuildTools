# Template Usage Example
# Demonstrates how to use the new template system for creating project files

# Import the module
Import-Module BuildTools -Force

# Configuration
$ProjectPath = "C:\MyNewProject"
$ProjectName = "MyAwesomeModule"
$ProjectDescription = "A powerful PowerShell module for automation"
$Author = "John Doe"
$License = "MIT"
$RepoUrl = "https://github.com/johndoe/my-awesome-module"

Write-Host "=== Template Usage Example ===" -ForegroundColor Cyan
Write-Host "Project: $ProjectName" -ForegroundColor Gray
Write-Host "Path: $ProjectPath" -ForegroundColor Gray
Write-Host ""

# Create project directory
if (-not (Test-Path $ProjectPath)) {
    New-Item -ItemType Directory -Path $ProjectPath -Force | Out-Null
    Write-Host "Created project directory: $ProjectPath" -ForegroundColor Green
}

# Step 1: Create README file
Write-Section "Create README"
$readmeResult = New-ReadmeFile -Path $ProjectPath -Type "PowerShell" -ProjectName $ProjectName -ProjectDescription $ProjectDescription -License $License -RepoUrl $RepoUrl -Force
if ($readmeResult) {
    Write-Success "README.md created successfully"
}
else {
    Write-Failure "Failed to create README.md"
}

# Step 2: Create LICENSE file
Write-Section "Create LICENSE"
$licenseResult = New-LicenseFile -Path $ProjectPath -Type $License -Author $Author -Force
if ($licenseResult) {
    Write-Success "LICENSE created successfully"
}
else {
    Write-Failure "Failed to create LICENSE"
}

# Step 3: Create .gitignore file
Write-Section "Create .gitignore"
$gitignoreResult = New-GitIgnoreFile -Path $ProjectPath -Type "CSharp" -Force
if ($gitignoreResult) {
    Write-Success ".gitignore created successfully"
}
else {
    Write-Failure "Failed to create .gitignore"
}

# Step 4: Create Git repository with templates
Write-Section "Create Git Repository"
$gitResult = Git-CreateRepository -Path $ProjectPath -GitIgnore "CSharp" -License $License -InitialCommit
if ($gitResult) {
    Write-Success "Git repository created successfully"
}
else {
    Write-Failure "Failed to create Git repository"
}

# Step 5: Demonstrate template content retrieval
Write-Section "Template Content Examples"

# Get different .gitignore templates
Write-Host "Available .gitignore templates:" -ForegroundColor Yellow
$gitignoreTypes = @("CSharp", "Node", "Python", "Java", "Go", "Rust")
foreach ($type in $gitignoreTypes) {
    $content = Get-GitIgnoreTemplate -Type $type
    if ($content) {
        $lineCount = ($content -split "`n").Count
        Write-Host "  - $type`: $lineCount lines" -ForegroundColor Cyan
    }
}

# Get different license templates
Write-Host "`nAvailable license templates:" -ForegroundColor Yellow
$licenseTypes = @("MIT", "GPL", "Apache", "BSD", "Unlicense")
foreach ($type in $licenseTypes) {
    $content = Get-LicenseTemplate -Type $type -Author $Author
    if ($content) {
        $lineCount = ($content -split "`n").Count
        Write-Host "  - $type`: $lineCount lines" -ForegroundColor Cyan
    }
}

# Get different README templates
Write-Host "`nAvailable README templates:" -ForegroundColor Yellow
$readmeTypes = @("Default", "PowerShell", "Nodejs")
foreach ($type in $readmeTypes) {
    $content = Get-ReadmeTemplate -Type $type -ProjectName $ProjectName -ProjectDescription $ProjectDescription
    if ($content) {
        $lineCount = ($content -split "`n").Count
        Write-Host "  - $type`: $lineCount lines" -ForegroundColor Cyan
    }
}

# Step 6: Show created files
Write-Section "Created Files"
$createdFiles = Get-ChildItem -Path $ProjectPath -File
foreach ($file in $createdFiles) {
    $size = [math]::Round($file.Length / 1KB, 2)
    Write-Host "  - $($file.Name): $size KB" -ForegroundColor Green
}

# Summary
Write-Host ""
Write-Host "=== Template Usage Complete ===" -ForegroundColor Green
Write-Host "Project created at: $ProjectPath" -ForegroundColor Cyan
Write-Host "Files created: $($createdFiles.Count)" -ForegroundColor Cyan
Write-Host ""
Write-Host "You can now customize the generated files as needed!" -ForegroundColor Yellow
