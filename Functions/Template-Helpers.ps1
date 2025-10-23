# Template Helper Functions
# Get-TemplateContent, Get-GitIgnoreTemplate, Get-LicenseTemplate, Get-ReadmeTemplate

function Get-TemplateContent {
    <#
    .SYNOPSIS
    Gets template content from external files with variable substitution.
    
    .DESCRIPTION
    Reads template files from the Templates directory and performs variable substitution.
    
    .PARAMETER TemplateType
    Type of template (GitIgnore, License, README).
    
    .PARAMETER TemplateName
    Name of the template file (without extension).
    
    .PARAMETER Variables
    Hashtable of variables to substitute in the template.
    
    .EXAMPLE
    Get-TemplateContent -TemplateType "GitIgnore" -TemplateName "CSharp"
    
    .EXAMPLE
    Get-TemplateContent -TemplateType "License" -TemplateName "MIT" -Variables @{YEAR="2024"; AUTHOR="John Doe"}
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet("GitIgnore", "License", "README")]
        [string]$TemplateType,
        
        [Parameter(Mandatory = $true)]
        [string]$TemplateName,
        
        [hashtable]$Variables = @{}
    )
    
    $moduleRoot = $PSScriptRoot
    $templatePath = Join-Path $moduleRoot "..\Templates\$TemplateType\$TemplateName"
    
    # Determine file extension based on template type
    $extension = switch ($TemplateType) {
        "GitIgnore" { ".txt" }
        "License" { ".txt" }
        "README" { ".md" }
    }
    
    $templateFile = "$templatePath$extension"
    
    if (-not (Test-Path $templateFile)) {
        Write-Warning "Template file not found: $templateFile"
        return $null
    }
    
    try {
        $content = Get-Content $templateFile -Raw
        
        # Add default variables if not provided
        if (-not $Variables.ContainsKey("YEAR")) {
            $Variables["YEAR"] = (Get-Date).Year
        }
        if (-not $Variables.ContainsKey("AUTHOR")) {
            $Variables["AUTHOR"] = $env:USERNAME
        }
        if (-not $Variables.ContainsKey("PROJECT_NAME")) {
            $Variables["PROJECT_NAME"] = "MyProject"
        }
        if (-not $Variables.ContainsKey("PROJECT_DESCRIPTION")) {
            $Variables["PROJECT_DESCRIPTION"] = "A project description"
        }
        if (-not $Variables.ContainsKey("LICENSE")) {
            $Variables["LICENSE"] = "MIT"
        }
        if (-not $Variables.ContainsKey("REPO_URL")) {
            $Variables["REPO_URL"] = "https://github.com/user/repo"
        }
        
        # Perform variable substitution
        foreach ($key in $Variables.Keys) {
            $content = $content -replace "{{$key}}", $Variables[$key]
        }
        
        return $content
    }
    catch {
        Write-Error "Failed to read template file: $_"
        return $null
    }
}

function Get-GitIgnoreTemplate {
    <#
    .SYNOPSIS
    Gets .gitignore template content.
    
    .DESCRIPTION
    Gets .gitignore template content from external files.
    
    .PARAMETER Type
    Type of .gitignore template.
    
    .EXAMPLE
    Get-GitIgnoreTemplate -Type "CSharp"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Type
    )
    
    return Get-TemplateContent -TemplateType "GitIgnore" -TemplateName $Type
}

function Get-LicenseTemplate {
    <#
    .SYNOPSIS
    Gets license template content.
    
    .DESCRIPTION
    Gets license template content from external files with variable substitution.
    
    .PARAMETER Type
    Type of license template.
    
    .PARAMETER Author
    Author name for the license.
    
    .PARAMETER Year
    Year for the license.
    
    .EXAMPLE
    Get-LicenseTemplate -Type "MIT" -Author "John Doe" -Year "2024"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Type,
        
        [string]$Author,
        
        [string]$Year
    )
    
    $variables = @{}
    if ($Author) { $variables["AUTHOR"] = $Author }
    if ($Year) { $variables["YEAR"] = $Year }
    
    return Get-TemplateContent -TemplateType "License" -TemplateName $Type -Variables $variables
}

function Get-ReadmeTemplate {
    <#
    .SYNOPSIS
    Gets README template content.
    
    .DESCRIPTION
    Gets README template content from external files with variable substitution.
    
    .PARAMETER Type
    Type of README template.
    
    .PARAMETER ProjectName
    Name of the project.
    
    .PARAMETER ProjectDescription
    Description of the project.
    
    .PARAMETER License
    License type.
    
    .PARAMETER RepoUrl
    Repository URL.
    
    .EXAMPLE
    Get-ReadmeTemplate -Type "PowerShell" -ProjectName "MyModule" -ProjectDescription "A PowerShell module"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Type,
        
        [string]$ProjectName,
        
        [string]$ProjectDescription,
        
        [string]$License,
        
        [string]$RepoUrl
    )
    
    $variables = @{}
    if ($ProjectName) { $variables["PROJECT_NAME"] = $ProjectName }
    if ($ProjectDescription) { $variables["PROJECT_DESCRIPTION"] = $ProjectDescription }
    if ($License) { $variables["LICENSE"] = $License }
    if ($RepoUrl) { $variables["REPO_URL"] = $RepoUrl }
    
    return Get-TemplateContent -TemplateType "README" -TemplateName $Type -Variables $variables
}
