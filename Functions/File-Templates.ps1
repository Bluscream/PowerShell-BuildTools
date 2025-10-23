# File Template Functions
# New-ReadmeFile, New-LicenseFile, New-GitIgnoreFile

function New-ReadmeFile {
    <#
    .SYNOPSIS
    Creates a README file using templates.
    
    .DESCRIPTION
    Creates a README.md file using predefined templates with variable substitution.
    
    .PARAMETER Path
    Path where to create the README file.
    
    .PARAMETER Type
    Type of README template (Default, PowerShell, Nodejs).
    
    .PARAMETER ProjectName
    Name of the project.
    
    .PARAMETER ProjectDescription
    Description of the project.
    
    .PARAMETER License
    License type.
    
    .PARAMETER RepoUrl
    Repository URL.
    
    .PARAMETER Force
    Overwrite existing file.
    
    .EXAMPLE
    New-ReadmeFile -Path "C:\MyProject" -Type "PowerShell" -ProjectName "MyModule" -ProjectDescription "A PowerShell module"
    
    .EXAMPLE
    New-ReadmeFile -Path "C:\MyProject" -Type "Nodejs" -ProjectName "my-package" -License "MIT" -RepoUrl "https://github.com/user/repo"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        
        [ValidateSet("Default", "PowerShell", "Nodejs")]
        [string]$Type = "Default",
        
        [string]$ProjectName,
        
        [string]$ProjectDescription,
        
        [string]$License,
        
        [string]$RepoUrl,
        
        [switch]$Force
    )
    
    $readmePath = Join-Path $Path "README.md"
    
    if ((Test-Path $readmePath) -and -not $Force) {
        Write-Warning "README.md already exists at $readmePath. Use -Force to overwrite."
        return $false
    }
    
    try {
        $content = Get-ReadmeTemplate -Type $Type -ProjectName $ProjectName -ProjectDescription $ProjectDescription -License $License -RepoUrl $RepoUrl
        
        if ($content) {
            Set-Content -Path $readmePath -Value $content -Encoding UTF8
            Write-Host "Created README.md at $readmePath" -ForegroundColor Green
            return $true
        }
        else {
            Write-Error "Failed to get README template"
            return $false
        }
    }
    catch {
        Write-Error "Failed to create README file: $_"
        return $false
    }
}

function New-LicenseFile {
    <#
    .SYNOPSIS
    Creates a LICENSE file using templates.
    
    .DESCRIPTION
    Creates a LICENSE file using predefined templates with variable substitution.
    
    .PARAMETER Path
    Path where to create the LICENSE file.
    
    .PARAMETER Type
    Type of license template (MIT, GPL, Apache, BSD, Unlicense).
    
    .PARAMETER Author
    Author name for the license.
    
    .PARAMETER Year
    Year for the license.
    
    .PARAMETER Force
    Overwrite existing file.
    
    .EXAMPLE
    New-LicenseFile -Path "C:\MyProject" -Type "MIT" -Author "John Doe" -Year "2024"
    
    .EXAMPLE
    New-LicenseFile -Path "C:\MyProject" -Type "GPL" -Force
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        
        [ValidateSet("MIT", "GPL", "Apache", "BSD", "Unlicense")]
        [string]$Type = "MIT",
        
        [string]$Author,
        
        [string]$Year,
        
        [switch]$Force
    )
    
    $licensePath = Join-Path $Path "LICENSE"
    
    if ((Test-Path $licensePath) -and -not $Force) {
        Write-Warning "LICENSE already exists at $licensePath. Use -Force to overwrite."
        return $false
    }
    
    try {
        $content = Get-LicenseTemplate -Type $Type -Author $Author -Year $Year
        
        if ($content) {
            Set-Content -Path $licensePath -Value $content -Encoding UTF8
            Write-Host "Created LICENSE at $licensePath" -ForegroundColor Green
            return $true
        }
        else {
            Write-Error "Failed to get license template"
            return $false
        }
    }
    catch {
        Write-Error "Failed to create LICENSE file: $_"
        return $false
    }
}

function New-GitIgnoreFile {
    <#
    .SYNOPSIS
    Creates a .gitignore file using templates.
    
    .DESCRIPTION
    Creates a .gitignore file using predefined templates.
    
    .PARAMETER Path
    Path where to create the .gitignore file.
    
    .PARAMETER Type
    Type of .gitignore template (CSharp, Node, Python, Java, Go, Rust).
    
    .PARAMETER Force
    Overwrite existing file.
    
    .EXAMPLE
    New-GitIgnoreFile -Path "C:\MyProject" -Type "CSharp"
    
    .EXAMPLE
    New-GitIgnoreFile -Path "C:\MyProject" -Type "Node" -Force
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        
        [ValidateSet("CSharp", "Node", "Python", "Java", "Go", "Rust")]
        [string]$Type = "CSharp",
        
        [switch]$Force
    )
    
    $gitignorePath = Join-Path $Path ".gitignore"
    
    if ((Test-Path $gitignorePath) -and -not $Force) {
        Write-Warning ".gitignore already exists at $gitignorePath. Use -Force to overwrite."
        return $false
    }
    
    try {
        $content = Get-GitIgnoreTemplate -Type $Type
        
        if ($content) {
            Set-Content -Path $gitignorePath -Value $content -Encoding UTF8
            Write-Host "Created .gitignore at $gitignorePath" -ForegroundColor Green
            return $true
        }
        else {
            Write-Error "Failed to get .gitignore template"
            return $false
        }
    }
    catch {
        Write-Error "Failed to create .gitignore file: $_"
        return $false
    }
}
