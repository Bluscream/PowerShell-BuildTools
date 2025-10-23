# BuildTools PowerShell Module
# A comprehensive module for build automation, version management, and publishing workflows

# Import all function files
$ModuleRoot = $PSScriptRoot
$FunctionFiles = Get-ChildItem -Path $ModuleRoot -Filter "*.ps1" -Recurse | Where-Object { $_.Name -ne "BuildTools.psm1" }

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
