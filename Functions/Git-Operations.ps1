# Git Operations Functions
# Git-CreateRepository, Git-CommitRepository, Git-PushRepository

function Git-CreateRepository {
    <#
    .SYNOPSIS
    Creates a new Git repository with optional .gitignore and license.
    
    .DESCRIPTION
    Initializes a new Git repository, sets up .gitignore file, and optionally creates a license file.
    
    .PARAMETER Path
    Path where to create the repository.
    
    .PARAMETER Force
    Force re-creation if repository already exists.
    
    .PARAMETER GitIgnore
    Type of .gitignore to create (ActionScript, CSharp, Node, etc.).
    
    .PARAMETER License
    Type of license to create (MIT, GPL, Apache, etc.).
    
    .PARAMETER InitialCommit
    Create initial commit with all files.
    
    .EXAMPLE
    Git-CreateRepository -Path "C:\MyProject" -GitIgnore "CSharp" -License "MIT"
    
    .EXAMPLE
    Git-CreateRepository -Path "C:\MyProject" -Force -GitIgnore "Node" -License "GPL" -InitialCommit
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        
        [switch]$Force,
        
        [ValidateSet("ActionScript", "CSharp", "Node", "Python", "Java", "Go", "Rust", "CPlusPlus", "VisualStudio", "IntelliJ", "Eclipse", "NetBeans", "Xcode", "Vim", "Emacs", "SublimeText", "Atom", "VSCode", "JetBrains", "Maven", "Gradle", "SBT", "Leiningen", "Composer", "NPM", "Yarn", "Bower", "NuGet", "CocoaPods", "Carthage", "SwiftPM", "Cargo", "Pip", "Conda", "Poetry", "Pipenv", "NPM", "Yarn", "Bun", "Deno", "Bazel", "Buck", "Pants", "Please", "Waf", "CMake", "Make", "Ninja", "Ant", "Maven", "Gradle", "SBT", "Leiningen", "Composer", "NPM", "Yarn", "Bower", "NuGet", "CocoaPods", "Carthage", "SwiftPM", "Cargo", "Pip", "Conda", "Poetry", "Pipenv", "NPM", "Yarn", "Bun", "Deno", "Bazel", "Buck", "Pants", "Please", "Waf", "CMake", "Make", "Ninja", "Ant")]
        [string]$GitIgnore,
        
        [ValidateSet("MIT", "GPL", "Apache", "BSD", "LGPL", "AGPL", "Mozilla", "ISC", "Unlicense", "CC0", "CC-BY", "CC-BY-SA", "CC-BY-NC", "CC-BY-NC-SA", "CC-BY-NC-ND", "CC-BY-ND", "CC-BY-SA", "CC-BY-NC", "CC-BY-NC-SA", "CC-BY-NC-ND", "CC-BY-ND")]
        [string]$License,
        
        [switch]$InitialCommit
    )
    
    $originalLocation = Get-Location
    
    try {
        Set-Location $Path
        
        # Check if repository already exists
        if (Test-Path ".git") {
            if ($Force) {
                Write-Host "Removing existing repository..." -ForegroundColor Yellow
                Remove-Item -Path ".git" -Recurse -Force
            }
            else {
                Write-Warning "Repository already exists. Use -Force to recreate."
                return $false
            }
        }
        
        # Initialize repository
        Write-Host "Initializing Git repository..." -ForegroundColor Green
        git init
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to initialize Git repository"
        }
        
        # Set default branch to main
        git branch -M main
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Failed to set default branch to main"
        }
        
        # Create .gitignore if specified
        if ($GitIgnore) {
            Write-Host "Creating .gitignore for $GitIgnore..." -ForegroundColor Green
            $gitignoreSuccess = New-GitIgnoreFile -Path $Path -Type $GitIgnore -Force
            if ($gitignoreSuccess) {
                Write-Host "Created .gitignore file" -ForegroundColor Green
            }
        }
        
        # Create license if specified
        if ($License) {
            Write-Host "Creating $License license..." -ForegroundColor Green
            $licenseSuccess = New-LicenseFile -Path $Path -Type $License -Force
            if ($licenseSuccess) {
                Write-Host "Created LICENSE file" -ForegroundColor Green
            }
        }
        
        # Create initial commit if requested
        if ($InitialCommit) {
            Write-Host "Creating initial commit..." -ForegroundColor Green
            git add .
            git commit -m "Initial commit"
            if ($LASTEXITCODE -eq 0) {
                Write-Host "Initial commit created" -ForegroundColor Green
            }
            else {
                Write-Warning "Failed to create initial commit"
            }
        }
        
        Write-Host "Repository created successfully!" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Error "Failed to create repository: $_"
        return $false
    }
    finally {
        Set-Location $originalLocation
    }
}

function Git-CommitRepository {
    <#
    .SYNOPSIS
    Commits changes to a Git repository.
    
    .DESCRIPTION
    Stages all changes and commits them with a specified message. Handles stashing if needed.
    
    .PARAMETER Path
    Path to the Git repository.
    
    .PARAMETER Message
    Commit message.
    
    .PARAMETER Stash
    Stash changes before committing.
    
    .PARAMETER AutoMessage
    Generate automatic commit message with timestamp.
    
    .EXAMPLE
    Git-CommitRepository -Path "C:\MyProject" -Message "Update build files"
    
    .EXAMPLE
    Git-CommitRepository -Path "C:\MyProject" -AutoMessage -Stash
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        
        [string]$Message,
        
        [switch]$Stash,
        
        [switch]$AutoMessage
    )
    
    $originalLocation = Get-Location
    
    try {
        Set-Location $Path
        
        # Verify git repo
        if (-not (Test-Path ".git")) {
            Write-Warning "Not a git repository: $Path"
            return $false
        }
        
        # Stash changes if requested
        if ($Stash) {
            Write-Host "Stashing changes..." -ForegroundColor Yellow
            git stash
            if ($LASTEXITCODE -ne 0) {
                Write-Warning "Failed to stash changes"
            }
        }
        
        # Check for changes
        $status = git status --porcelain
        if ([string]::IsNullOrWhiteSpace($status)) {
            Write-Host "No changes to commit" -ForegroundColor Yellow
            return $true
        }
        
        # Stage all changes
        Write-Host "Staging changes..." -ForegroundColor Green
        git add .
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to stage changes"
        }
        
        # Generate commit message if needed
        if ($AutoMessage -and -not $Message) {
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            $Message = "Build at $timestamp"
        }
        
        if (-not $Message) {
            $Message = "Update files"
        }
        
        # Commit changes
        Write-Host "Committing changes..." -ForegroundColor Green
        git commit -m $Message
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to commit changes"
        }
        
        Write-Host "Changes committed successfully" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Error "Failed to commit repository: $_"
        return $false
    }
    finally {
        Set-Location $originalLocation
    }
}

function Git-PushRepository {
    <#
    .SYNOPSIS
    Pushes changes to a remote Git repository.
    
    .DESCRIPTION
    Pushes changes to the remote repository. Handles upstream setup and force push if needed.
    
    .PARAMETER Path
    Path to the Git repository.
    
    .PARAMETER Remote
    Remote name (default: origin).
    
    .PARAMETER Branch
    Branch name (default: current branch).
    
    .PARAMETER Force
    Force push changes.
    
    .PARAMETER SetUpstream
    Set upstream branch.
    
    .EXAMPLE
    Git-PushRepository -Path "C:\MyProject"
    
    .EXAMPLE
    Git-PushRepository -Path "C:\MyProject" -Force -SetUpstream
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        
        [string]$Remote = "origin",
        
        [string]$Branch,
        
        [switch]$Force,
        
        [switch]$SetUpstream
    )
    
    $originalLocation = Get-Location
    
    try {
        Set-Location $Path
        
        # Verify git repo
        if (-not (Test-Path ".git")) {
            Write-Warning "Not a git repository: $Path"
            return $false
        }
        
        # Get current branch if not specified
        if (-not $Branch) {
            $Branch = git rev-parse --abbrev-ref HEAD
            if ($LASTEXITCODE -ne 0) {
                throw "Failed to get current branch"
            }
        }
        
        # Pull and rebase remote changes before pushing
        Write-Host "Syncing with remote..." -ForegroundColor Yellow
        git pull --rebase $Remote $Branch
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Failed to sync with remote, trying to push anyway..."
        }
        
        # Push changes
        Write-Host "Pushing changes to $Remote/$Branch..." -ForegroundColor Green
        
        if ($SetUpstream) {
            git push --set-upstream $Remote $Branch
        }
        elseif ($Force) {
            git push --force $Remote $Branch
        }
        else {
            git push $Remote $Branch
        }
        
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to push changes"
        }
        
        Write-Host "Changes pushed successfully" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Error "Failed to push repository: $_"
        return $false
    }
    finally {
        Set-Location $originalLocation
    }
}

# Helper function to get .gitignore templates (now uses external files)
function Get-GitIgnoreTemplate {
    param([string]$Type)
    
    return Get-TemplateContent -TemplateType "GitIgnore" -TemplateName $Type
}

# Helper function to get license templates (now uses external files)
function Get-LicenseTemplate {
    param([string]$Type)
    
    return Get-TemplateContent -TemplateType "License" -TemplateName $Type
}
