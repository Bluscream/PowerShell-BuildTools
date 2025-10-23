# BuildTools PowerShell Module
# A comprehensive module for build automation, version management, and publishing workflows

# Import all function files from Functions directory only
$ModuleRoot = $PSScriptRoot
$FunctionFiles = Get-ChildItem -Path "$ModuleRoot\Functions" -Filter "*.ps1" -ErrorAction SilentlyContinue

foreach ($File in $FunctionFiles) {
    try {
        . $File.FullName
        Write-Verbose "Imported functions from $($File.Name)"
    }
    catch {
        Write-Warning "Failed to import functions from $($File.Name): $_"
    }
}

# Export all functions
Export-ModuleMember -Function *