# Complete Build Workflow Example
# Demonstrates how to use BuildTools module for a complete build and release process

# Import the module
Import-Module BuildTools -Force

# Configuration
$ProjectPath = "C:\MyProject"
$ProjectFile = "MyProject.csproj"
$Repository = "myuser/myapp"
$Version = "1.2.3.4"

Write-Host "=== Complete Build Workflow Example ===" -ForegroundColor Cyan
Write-Host "Project: $ProjectPath" -ForegroundColor Gray
Write-Host "Repository: $Repository" -ForegroundColor Gray
Write-Host "Version: $Version" -ForegroundColor Gray
Write-Host ""

# Step 1: Version Management
Write-Section "Version Management"
Write-Host "Setting version to $Version..." -ForegroundColor Green
$versionResult = Set-Version -Files @("$ProjectPath\AssemblyInfo.cs") -Pattern 'AssemblyVersion\("([^"]+)"\)' -NewVersion $Version
if ($versionResult) {
    Write-Success "Version set successfully"
} else {
    Write-Failure "Failed to set version"
    exit 1
}

# Step 2: Clean Build Artifacts
Write-Section "Clean Build Artifacts"
Write-Host "Cleaning build artifacts..." -ForegroundColor Green
Clear-BuildArtifacts -ProjectPath $ProjectPath -OutputPath "$ProjectPath\bin" -KillProcesses

# Step 3: .NET Build
Write-Section ".NET Build"
Write-Host "Building .NET project..." -ForegroundColor Green
$buildResult = Dotnet-Build -ProjectPath "$ProjectPath\$ProjectFile" -Configuration "Release" -Architecture "win-x64" -Clean -Verbose
if ($buildResult) {
    Write-Success "Build completed successfully"
} else {
    Write-Failure "Build failed"
    exit 1
}

# Step 4: .NET Publish
Write-Section ".NET Publish"
Write-Host "Publishing .NET project..." -ForegroundColor Green
$publishResult = Dotnet-Publish -ProjectPath "$ProjectPath\$ProjectFile" -Configuration "Release" -Architecture "win-x64" -SelfContained -SingleFile -Trimmed
if ($publishResult) {
    Write-Success "Publish completed successfully"
} else {
    Write-Failure "Publish failed"
    exit 1
}

# Step 5: Git Operations
Write-Section "Git Operations"
Write-Host "Committing changes..." -ForegroundColor Green
$commitResult = Git-CommitRepository -Path $ProjectPath -Message "Release v$Version" -AutoMessage
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
Write-Host "Creating GitHub release..." -ForegroundColor Green
$releaseResult = GitHub-CreateRelease -Repository $Repository -Tag "v$Version" -Title "Release v$Version" -Notes "Automated release for version $Version" -Assets @("$ProjectPath\bin\MyProject.exe")
if ($releaseResult) {
    Write-Success "GitHub release created successfully"
} else {
    Write-Failure "Failed to create GitHub release"
    exit 1
}

# Step 7: Docker Operations (Optional)
Write-Section "Docker Operations"
Write-Host "Checking Docker availability..." -ForegroundColor Green
if (Docker-StartIfNeeded) {
    Write-Host "Building Docker image..." -ForegroundColor Green
    $dockerResult = Docker-Build -ProjectPath $ProjectPath -Tag "myapp:$Version" -NoCache
    if ($dockerResult) {
        Write-Success "Docker image built successfully"
        
        Write-Host "Publishing Docker image..." -ForegroundColor Green
        $dockerPublishResult = Docker-Publish -ImageName "myapp" -Registry "dockerhub" -Username "myuser" -Tags @($Version, "latest")
        if ($dockerPublishResult) {
            Write-Success "Docker image published successfully"
        } else {
            Write-Failure "Failed to publish Docker image"
        }
    } else {
        Write-Failure "Docker build failed"
    }
} else {
    Write-Warning "Docker not available, skipping Docker operations"
}

# Summary
Write-Host ""
Write-Host "=== Build Workflow Complete ===" -ForegroundColor Green
Write-Host "Version: $Version" -ForegroundColor Cyan
Write-Host "Repository: $Repository" -ForegroundColor Cyan
Write-Host "Release: https://github.com/$Repository/releases/tag/v$Version" -ForegroundColor Cyan
Write-Host ""
