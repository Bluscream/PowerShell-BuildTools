# BuildTools PowerShell Module

A comprehensive PowerShell module for build automation, version management, and publishing workflows. This module combines the best features from multiple build scripts into a unified, reusable toolkit.

## Features

- **Version Management**: Set, bump, and update version numbers in files
- **Git Operations**: Create repositories, commit changes, and push to remotes
- **Build Automation**: .NET, Node.js, and Docker build support
- **Publishing**: GitHub releases, Docker Hub, and container registries
- **Utility Functions**: File operations, process management, and more

## Installation

### From PowerShell Gallery (Recommended)

```powershell
Install-Module BuildTools -Scope CurrentUser
```

### From GitHub

```powershell
# Using the install script
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Bluscream/PowerShell-BuildTools/main/Install-BuildTools.ps1" -OutFile "Install-BuildTools.ps1"
.\Install-BuildTools.ps1 -Source GitHub
```

### Manual Installation

1. Download the module files from [GitHub](https://github.com/Bluscream/PowerShell-BuildTools)
2. Place them in your PowerShell modules directory
3. Import the module: `Import-Module BuildTools`

## Quick Start

```powershell
# Import the module
Import-Module BuildTools

# Set version numbers in files
Set-Version -Files @("AssemblyInfo.cs", "package.json") -Pattern "version.*(\d+\.\d+\.\d+\.\d+)" -NewVersion "1.2.3.4"

# Bump version numbers
Bump-Version -Files @("AssemblyInfo.cs") -Pattern "version.*(\d+\.\d+\.\d+\.\d+)"

# Update build timestamps
Update-Build -Files @("index.ts") -Pattern "build:\s*(\d+)"

# Create a Git repository
Git-CreateRepository -Path "C:\MyProject" -GitIgnore "CSharp" -License "MIT" -InitialCommit

# Build a .NET project
Dotnet-Build -ProjectPath "MyProject.csproj" -Configuration "Release" -Architecture "win-x64"

# Build a Node.js project
Nodejs-Build -ProjectPath "C:\MyProject" -PackageManager "npm" -Script "build"

# Create a GitHub release
GitHub-CreateRelease -Repository "myuser/myapp" -Tag "v1.0.0" -Title "Release v1.0.0" -Assets @("app.exe", "app.dll")
```

## Function Reference

### Version Management

#### Set-Version

Sets version numbers in files using regex patterns.

```powershell
Set-Version -Files @("file1.cs", "file2.js") -Pattern "version.*(\d+\.\d+\.\d+\.\d+)" -NewVersion "1.2.3.4"
```

#### Bump-Version

Bumps version numbers by incrementing the build number.

```powershell
Bump-Version -Files @("AssemblyInfo.cs") -Pattern 'AssemblyVersion\("([^"]+)"\)' -Backup
```

#### Update-Build

Updates build timestamps using Unix timestamps.

```powershell
Update-Build -Files @("index.ts") -Pattern "build:\s*(\d+)" -UseCurrentTime
```

### Git Operations

#### Git-CreateRepository

Creates a new Git repository with optional .gitignore and license.

```powershell
Git-CreateRepository -Path "C:\MyProject" -GitIgnore "CSharp" -License "MIT" -InitialCommit
```

#### Git-CommitRepository

Commits changes to a Git repository.

```powershell
Git-CommitRepository -Path "C:\MyProject" -Message "Update build files" -AutoMessage
```

#### Git-PushRepository

Pushes changes to a remote Git repository.

```powershell
Git-PushRepository -Path "C:\MyProject" -Force -SetUpstream
```

### .NET Build Functions

#### Dotnet-Build

Builds a .NET project with specified configuration and architecture.

```powershell
Dotnet-Build -ProjectPath "MyProject.csproj" -Configuration "Release" -Architecture "win-x64" -Clean
```

#### Dotnet-Publish

Publishes a .NET project with various deployment options.

```powershell
Dotnet-Publish -ProjectPath "MyProject.csproj" -Configuration "Release" -SelfContained -SingleFile -Trimmed
```

#### Dotnet-Clean

Cleans .NET project build artifacts.

```powershell
Dotnet-Clean -ProjectPath "MyProject.csproj" -Configuration "Release" -Verbose
```

### Node.js Functions

#### Nodejs-Build

Builds a Node.js project using npm, yarn, pnpm, or bun.

```powershell
Nodejs-Build -ProjectPath "C:\MyProject" -PackageManager "npm" -Script "build" -Production
```

#### Nodejs-Test

Runs tests for a Node.js project.

```powershell
Nodejs-Test -ProjectPath "C:\MyProject" -PackageManager "npm" -Script "test" -Coverage
```

#### Nodejs-Install

Installs dependencies for a Node.js project.

```powershell
Nodejs-Install -ProjectPath "C:\MyProject" -PackageManager "yarn" -Frozen -Verbose
```

### Docker Functions

#### Docker-Build

Builds Docker images with specified configurations.

```powershell
Docker-Build -ProjectPath "C:\MyProject" -Tag "myapp:latest" -NoCache -Verbose
```

#### Docker-Publish

Publishes Docker images to registries.

```powershell
Docker-Publish -ImageName "myapp" -Registry "dockerhub" -Username "myuser" -Tags @("1.0", "latest")
```

#### Docker-StartIfNeeded

Ensures Docker is running and starts it if needed.

```powershell
Docker-StartIfNeeded
```

### GitHub Functions

#### GitHub-CreateRelease

Creates a GitHub release with assets.

```powershell
GitHub-CreateRelease -Repository "myuser/myapp" -Tag "v1.0.0" -Title "Release v1.0.0" -Assets @("app.exe", "app.dll")
```

#### GitHub-Publish

Publishes a GitHub release with assets in parallel.

```powershell
GitHub-Publish -Repository "myapp" -Tag "v1.0.0" -Title "Release v1.0.0" -Assets @("app.exe", "app.dll") -Parallel
```

### Utility Functions

#### Get-Username

Gets username for various services.

```powershell
$githubUser = Get-Username -Service "github"
$dockerUser = Get-Username -Service "docker"
```

#### Clear-BuildArtifacts

Clears build artifacts and temporary files.

```powershell
Clear-BuildArtifacts -ProjectPath "C:\MyProject" -OutputPath "C:\MyProject\bin" -KillProcesses
```

#### Get-FileUnixTimestamp

Gets the Unix timestamp of a file's last write time.

```powershell
$timestamp = Get-FileUnixTimestamp -FilePath "C:\MyFile.txt"
```

### Template Functions

#### New-ReadmeFile

Creates README files using templates.

```powershell
New-ReadmeFile -Path "C:\MyProject" -Type "PowerShell" -ProjectName "MyModule" -ProjectDescription "A PowerShell module"
```

#### New-LicenseFile

Creates LICENSE files using templates.

```powershell
New-LicenseFile -Path "C:\MyProject" -Type "MIT" -Author "John Doe" -Year "2024"
```

#### New-GitIgnoreFile

Creates .gitignore files using templates.

```powershell
New-GitIgnoreFile -Path "C:\MyProject" -Type "CSharp"
```

#### Get-TemplateContent

Gets template content with variable substitution.

```powershell
$content = Get-TemplateContent -TemplateType "License" -TemplateName "MIT" -Variables @{YEAR="2024"; AUTHOR="John Doe"}
```

## Examples

### Complete Build Workflow

```powershell
# Import module
Import-Module BuildTools

# Set version
Set-Version -Files @("AssemblyInfo.cs") -Pattern 'AssemblyVersion\("([^"]+)"\)' -NewVersion "1.2.3.4"

# Build .NET project
Dotnet-Build -ProjectPath "MyProject.csproj" -Configuration "Release" -Architecture "win-x64" -Clean

# Publish .NET project
Dotnet-Publish -ProjectPath "MyProject.csproj" -Configuration "Release" -SelfContained -SingleFile

# Commit changes
Git-CommitRepository -Path "." -Message "Release v1.2.3.4" -AutoMessage

# Push changes
Git-PushRepository -Path "." -Force

# Create GitHub release
GitHub-CreateRelease -Repository "myuser/myapp" -Tag "v1.2.3.4" -Title "Release v1.2.3.4" -Assets @("MyProject.exe")
```

### Node.js Build Workflow

```powershell
# Import module
Import-Module BuildTools

# Install dependencies
Nodejs-Install -ProjectPath "C:\MyProject" -PackageManager "npm"

# Run tests
Nodejs-Test -ProjectPath "C:\MyProject" -PackageManager "npm" -Coverage

# Build project
Nodejs-Build -ProjectPath "C:\MyProject" -PackageManager "npm" -Script "build" -Production

# Update build timestamp
Update-Build -Files @("dist\index.js") -Pattern "build:\s*(\d+)"

# Commit and push
Git-CommitRepository -Path "." -Message "Build $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -AutoMessage
Git-PushRepository -Path "."
```

### Docker Workflow

```powershell
# Import module
Import-Module BuildTools

# Ensure Docker is running
Docker-StartIfNeeded

# Build Docker image
Docker-Build -ProjectPath "C:\MyProject" -Tag "myapp:latest" -NoCache

# Publish to Docker Hub
Docker-Publish -ImageName "myapp" -Registry "dockerhub" -Username "myuser" -Tags @("latest", "1.0")

# Publish to GitHub Container Registry
Docker-Publish -ImageName "myapp" -Registry "ghcr" -Username "myuser" -Tags @("latest", "1.0")
```

### Template Usage Workflow

```powershell
# Import module
Import-Module BuildTools

# Create project files using templates
New-ReadmeFile -Path "C:\MyProject" -Type "PowerShell" -ProjectName "MyModule" -ProjectDescription "A PowerShell module"
New-LicenseFile -Path "C:\MyProject" -Type "MIT" -Author "John Doe"
New-GitIgnoreFile -Path "C:\MyProject" -Type "CSharp"

# Create Git repository with templates
Git-CreateRepository -Path "C:\MyProject" -GitIgnore "CSharp" -License "MIT" -InitialCommit
```

## Configuration

### Environment Variables

- `GITHUB_USERNAME`: GitHub username for releases
- `DOCKER_USERNAME`: Docker username for publishing
- `NUGET_API_KEY`: NuGet API key for publishing packages

### Git Configuration

The module will automatically detect GitHub usernames from git remotes if available.

## Requirements

- PowerShell 5.1 or later
- Git (for Git operations)
- GitHub CLI (for GitHub operations)
- Docker (for Docker operations)
- .NET SDK (for .NET operations)
- Node.js (for Node.js operations)

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues and questions:

1. Check the [Issues](https://github.com/Bluscream/BuildTools/issues) page
2. Create a new issue if your problem isn't already reported
3. Provide detailed information about your environment and the issue

## Changelog

### v1.0.0

- Initial release
- Version management functions
- Git operations
- .NET build support
- Node.js build support
- Docker operations
- GitHub release management
- Utility functions
