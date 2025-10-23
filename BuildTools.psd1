@{
    # Module manifest for BuildTools
    # Generated on: $(Get-Date -Format "yyyy-MM-dd")
    
    RootModule           = 'BuildTools.psm1'
    ModuleVersion        = '1.0.0'
    GUID                 = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'
    Author               = 'Bluscream'
    CompanyName          = 'BuildTools'
    Copyright            = '(c) 2024 BuildTools. All rights reserved.'
    Description          = 'A comprehensive PowerShell module for build automation, version management, and publishing workflows'
    
    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion    = '5.1'
    
    # Functions to export from this module
    FunctionsToExport    = @(
        # Version Management
        'Set-Version',
        'Bump-Version', 
        'Update-Build',
        
        # Git Operations
        'Git-CreateRepository',
        'Git-CommitRepository',
        'Git-PushRepository',
        
        # .NET Build Functions
        'Dotnet-Build',
        'Dotnet-Publish',
        'Dotnet-Clean',
        
        # Node.js Functions
        'Nodejs-Build',
        'Nodejs-Test',
        'Nodejs-Install',
        
        # Docker Functions
        'Docker-Build',
        'Docker-Publish',
        'Docker-StartIfNeeded',
        
        # GitHub Functions
        'GitHub-CreateRelease',
        'GitHub-Publish',
        
        # Utility Functions
        'Get-Username',
        'Get-FileUnixTimestamp',
        'Clear-BuildArtifacts',
        
        # Template Functions
        'Get-TemplateContent',
        'Get-GitIgnoreTemplate',
        'Get-LicenseTemplate',
        'Get-ReadmeTemplate',
        
        # File Template Functions
        'New-ReadmeFile',
        'New-LicenseFile',
        'New-GitIgnoreFile'
    )
    
    # Cmdlets to export from this module
    CmdletsToExport      = @()
    
    # Variables to export from this module
    VariablesToExport    = @()
    
    # Aliases to export from this module
    AliasesToExport      = @()
    
    # List of all modules packaged with this module
    ModuleList           = @()
    
    # List of all files packaged with this module
    FileList             = @()
    
    # Private data to pass to the module specified in RootModule/ModuleToProcess
    PrivateData          = @{
        PSData = @{
            # Tags applied to this module
            Tags         = @('Build', 'Automation', 'Version', 'Git', 'Docker', 'Nodejs', 'Dotnet', 'GitHub')
            
            # A URL to the license for this module
            LicenseUri   = 'https://github.com/Bluscream/BuildTools/blob/main/LICENSE'
            
            # A URL to the main website for this project
            ProjectUri   = 'https://github.com/Bluscream/BuildTools'
            
            # A URL to an icon representing this module
            IconUri      = ''
            
            # ReleaseNotes of this module
            ReleaseNotes = @'
# BuildTools v1.0.0

## Features
- Version management (Set-Version, Bump-Version, Update-Build)
- Git operations (Create, Commit, Push repositories)
- .NET build automation
- Node.js build and test automation
- Docker build and publish
- GitHub release management
- Comprehensive utility functions

## Installation
```powershell
Install-Module BuildTools -Scope CurrentUser
```

## Usage
```powershell
Import-Module BuildTools
Set-Version -Files @("file1.cs", "file2.js") -Pattern "version.*(\d+\.\d+\.\d+\.\d+)"
Bump-Version -Files @("file1.cs") -Pattern "version.*(\d+\.\d+\.\d+\.\d+)"
```
'@
        }
    }
    
    # HelpInfo URI of this module
    HelpInfoURI          = 'https://github.com/Bluscream/BuildTools/blob/main/README.md'
    
    # Default prefix for commands exported from this module
    DefaultCommandPrefix = ''
}
   