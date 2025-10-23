# GitHub Operations Functions
# GitHub-CreateRelease, GitHub-Publish

function GitHub-CreateRelease {
    <#
    .SYNOPSIS
    Creates a GitHub release with assets.
    
    .DESCRIPTION
    Creates a GitHub release using the GitHub CLI with specified assets and metadata.
    
    .PARAMETER Repository
    GitHub repository in format "owner/repo" or just "repo" (uses current user).
    
    .PARAMETER Tag
    Release tag (e.g., "v1.0.0").
    
    .PARAMETER Title
    Release title.
    
    .PARAMETER Notes
    Release notes/description.
    
    .PARAMETER Assets
    Array of asset file paths to upload.
    
    .PARAMETER Prerelease
    Mark as prerelease.
    
    .PARAMETER Draft
    Create as draft.
    
    .PARAMETER Target
    Target branch for the release.
    
    .PARAMETER Verbose
    Enable verbose output.
    
    .EXAMPLE
    GitHub-CreateRelease -Repository "myuser/myapp" -Tag "v1.0.0" -Title "Release v1.0.0" -Assets @("app.exe", "app.dll")
    
    .EXAMPLE
    GitHub-CreateRelease -Repository "myapp" -Tag "v1.0.0-beta" -Prerelease -Draft
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Repository,
        
        [Parameter(Mandatory = $true)]
        [string]$Tag,
        
        [string]$Title,
        
        [string]$Notes,
        
        [string[]]$Assets = @(),
        
        [switch]$Prerelease,
        
        [switch]$Draft,
        
        [string]$Target,
        
        [switch]$VerboseOutput
    )
    
    # Check if gh CLI is available
    if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
        Write-Error "GitHub CLI (gh) is not installed or not in PATH."
        return $false
    }
    
    # Get GitHub username if repository doesn't include owner
    if ($Repository -notlike "*/*") {
        $githubUsername = Get-Username -Service "github"
        if (-not $githubUsername) {
            Write-Error "Could not determine GitHub username"
            return $false
        }
        $Repository = "$githubUsername/$Repository"
    }
    
    try {
        Write-Host "Creating GitHub release..." -ForegroundColor Green
        Write-Host "Repository: $Repository" -ForegroundColor Cyan
        Write-Host "Tag: $Tag" -ForegroundColor Cyan
        
        # Build gh release create command
        $releaseArgs = @("release", "create", $Tag)
        
        if ($Title) {
            $releaseArgs += @("--title", $Title)
        }
        
        if ($Notes) {
            $releaseArgs += @("--notes", $Notes)
        }
        
        if ($Prerelease) {
            $releaseArgs += "--prerelease"
        }
        
        if ($Draft) {
            $releaseArgs += "--draft"
        }
        
        if ($Target) {
            $releaseArgs += @("--target", $Target)
        }
        
        if ($VerboseOutput) {
            $releaseArgs += "--verbose"
        }
        
        # Add assets
        foreach ($asset in $Assets) {
            if (Test-Path $asset) {
                $releaseArgs += $asset
            }
            else {
                Write-Warning "Asset file not found: $asset"
            }
        }
        
        # Add repository
        $releaseArgs += "--repo", $Repository
        
        # Create release
        $releaseOutput = gh $releaseArgs 2>&1 | Out-String
        $releaseExitCode = $LASTEXITCODE
        
        if ($releaseExitCode -eq 0) {
            Write-Host "GitHub release created successfully" -ForegroundColor Green
            if ($releaseOutput) {
                Write-Host "Release output:" -ForegroundColor Cyan
                Write-Host $releaseOutput
            }
            return $true
        }
        else {
            Write-Host "GitHub release creation failed with exit code: $releaseExitCode" -ForegroundColor Red
            if ($releaseOutput) {
                Write-Host "Release output:" -ForegroundColor Yellow
                Write-Host $releaseOutput
            }
            return $false
        }
    }
    catch {
        Write-Error "GitHub release creation failed: $_"
        return $false
    }
}

function GitHub-Publish {
    <#
    .SYNOPSIS
    Publishes a GitHub release with assets in parallel.
    
    .DESCRIPTION
    Creates a GitHub release and uploads assets in parallel for better performance.
    
    .PARAMETER Repository
    GitHub repository in format "owner/repo" or just "repo" (uses current user).
    
    .PARAMETER Tag
    Release tag (e.g., "v1.0.0").
    
    .PARAMETER Title
    Release title.
    
    .PARAMETER Notes
    Release notes/description.
    
    .PARAMETER Assets
    Array of asset file paths to upload.
    
    .PARAMETER Prerelease
    Mark as prerelease.
    
    .PARAMETER Draft
    Create as draft.
    
    .PARAMETER Target
    Target branch for the release.
    
    .PARAMETER Parallel
    Upload assets in parallel (default: true).
    
    .PARAMETER Verbose
    Enable verbose output.
    
    .EXAMPLE
    GitHub-Publish -Repository "myuser/myapp" -Tag "v1.0.0" -Title "Release v1.0.0" -Assets @("app.exe", "app.dll")
    
    .EXAMPLE
    GitHub-Publish -Repository "myapp" -Tag "v1.0.0-beta" -Prerelease -Parallel
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Repository,
        
        [Parameter(Mandatory = $true)]
        [string]$Tag,
        
        [string]$Title,
        
        [string]$Notes,
        
        [string[]]$Assets = @(),
        
        [switch]$Prerelease,
        
        [switch]$Draft,
        
        [string]$Target,
        
        [switch]$Parallel,
        
        [switch]$VerboseOutput
    )
    
    # Check if gh CLI is available
    if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
        Write-Error "GitHub CLI (gh) is not installed or not in PATH."
        return $false
    }
    
    # Get GitHub username if repository doesn't include owner
    if ($Repository -notlike "*/*") {
        $githubUsername = Get-Username -Service "github"
        if (-not $githubUsername) {
            Write-Error "Could not determine GitHub username"
            return $false
        }
        $Repository = "$githubUsername/$Repository"
    }
    
    try {
        Write-Host "Publishing to GitHub..." -ForegroundColor Green
        Write-Host "Repository: $Repository" -ForegroundColor Cyan
        Write-Host "Tag: $Tag" -ForegroundColor Cyan
        
        # Create release first
        $releaseSuccess = GitHub-CreateRelease -Repository $Repository -Tag $Tag -Title $Title -Notes $Notes -Prerelease:$Prerelease -Draft:$Draft -Target $Target -Verbose:$Verbose
        
        if (-not $releaseSuccess) {
            Write-Error "Failed to create GitHub release"
            return $false
        }
        
        # Upload assets if provided
        if ($Assets.Count -gt 0) {
            Write-Host "Uploading assets..." -ForegroundColor Green
            
            if ($Parallel -or $true) {
                # Upload assets in parallel
                $uploadJobs = @()
                
                foreach ($asset in $Assets) {
                    if (Test-Path $asset) {
                        Write-Host "Starting upload for asset: $asset" -ForegroundColor Yellow
                        $job = Start-Job -ScriptBlock {
                            param($assetPath, $tag, $repo)
                            try {
                                $output = gh release upload $tag $assetPath --repo $repo 2>&1
                                $exitCode = $LASTEXITCODE
                                return @{
                                    Name     = [System.IO.Path]::GetFileName($assetPath)
                                    ExitCode = $exitCode
                                    Output   = $output
                                }
                            }
                            catch {
                                return @{
                                    Name     = [System.IO.Path]::GetFileName($assetPath)
                                    ExitCode = 1
                                    Output   = $_.Exception.Message
                                }
                            }
                        } -ArgumentList $asset, $Tag, $Repository
                        $uploadJobs += $job
                    }
                    else {
                        Write-Warning "Asset file not found: $asset"
                    }
                }
                
                # Wait for all uploads to complete and collect results
                Write-Host "Waiting for all asset uploads to complete..." -ForegroundColor Yellow
                $results = $uploadJobs | Wait-Job | Receive-Job
                
                # Report results
                $successCount = 0
                foreach ($result in $results) {
                    if ($result.ExitCode -eq 0) {
                        Write-Host "Successfully uploaded: $($result.Name)" -ForegroundColor Green
                        $successCount++
                    }
                    else {
                        Write-Host "Failed to upload: $($result.Name)" -ForegroundColor Red
                        if ($result.Output) {
                            Write-Host "  Error: $($result.Output)" -ForegroundColor Red
                        }
                    }
                }
                
                # Clean up jobs
                $uploadJobs | Remove-Job
                
                if ($successCount -eq $Assets.Count) {
                    Write-Host "All assets uploaded successfully" -ForegroundColor Green
                    return $true
                }
                else {
                    Write-Host "Some assets failed to upload" -ForegroundColor Yellow
                    return $false
                }
            }
            else {
                # Upload assets sequentially
                $successCount = 0
                foreach ($asset in $Assets) {
                    if (Test-Path $asset) {
                        Write-Host "Uploading asset: $asset" -ForegroundColor Yellow
                        $uploadOutput = gh release upload $Tag $asset --repo $Repository 2>&1
                        $uploadExitCode = $LASTEXITCODE
                        
                        if ($uploadExitCode -eq 0) {
                            Write-Host "Successfully uploaded: $asset" -ForegroundColor Green
                            $successCount++
                        }
                        else {
                            Write-Host "Failed to upload: $asset" -ForegroundColor Red
                            if ($uploadOutput) {
                                Write-Host "  Error: $uploadOutput" -ForegroundColor Red
                            }
                        }
                    }
                    else {
                        Write-Warning "Asset file not found: $asset"
                    }
                }
                
                if ($successCount -eq $Assets.Count) {
                    Write-Host "All assets uploaded successfully" -ForegroundColor Green
                    return $true
                }
                else {
                    Write-Host "Some assets failed to upload" -ForegroundColor Yellow
                    return $false
                }
            }
        }
        else {
            Write-Host "No assets to upload" -ForegroundColor Yellow
            return $true
        }
    }
    catch {
        Write-Error "GitHub publish failed: $_"
        return $false
    }
}
