# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- GitHub Actions CI/CD workflows
- Automated publishing to PowerShell Gallery
- Comprehensive installation scripts
- Template system with external files
- Enhanced documentation

### Changed

- Refactored templates to use external files instead of hardcoded strings
- Improved error handling and validation
- Enhanced module manifest with proper metadata

## [1.0.0] - 2024-12-19

### Added

- Initial release of BuildTools PowerShell module
- Version management functions (Set-Version, Bump-Version, Update-Build)
- Git operations (Git-CreateRepository, Git-CommitRepository, Git-PushRepository)
- .NET build functions (Dotnet-Build, Dotnet-Publish, Dotnet-Clean)
- Node.js functions (Nodejs-Build, Nodejs-Test, Nodejs-Install)
- Docker operations (Docker-Build, Docker-Publish, Docker-StartIfNeeded)
- GitHub release management (GitHub-CreateRelease, GitHub-Publish)
- Template system with .gitignore, license, and README templates
- Comprehensive utility functions
- File template functions (New-ReadmeFile, New-LicenseFile, New-GitIgnoreFile)
- Template helper functions with variable substitution
- Complete documentation and examples
- Support for multiple package managers (npm, yarn, pnpm, bun)
- Support for multiple registries (Docker Hub, GHCR, NuGet)
- Parallel asset uploads for GitHub releases
- Automatic username detection for various services
- Build artifact cleanup and process management
- Unix timestamp utilities
- Comprehensive error handling and logging

### Features

- **Version Management**: Set, bump, and update version numbers in files using regex patterns
- **Git Operations**: Create repositories with templates, commit changes, and push to remotes
- **Build Automation**: Support for .NET, Node.js, and Docker builds with various configurations
- **Publishing**: GitHub releases, Docker Hub, GHCR, and NuGet publishing
- **Templates**: External template system for .gitignore, licenses, and README files
- **Utilities**: File operations, process management, and comprehensive helper functions

### Templates

- **GitIgnore**: CSharp, Node, Python, Java, Go, Rust
- **License**: MIT, GPL, Apache, BSD, Unlicense
- **README**: Default, PowerShell, Nodejs

### Requirements

- PowerShell 5.1 or later
- Git (for Git operations)
- GitHub CLI (for GitHub operations)
- Docker (for Docker operations)
- .NET SDK (for .NET operations)
- Node.js (for Node.js operations)
