# BuildTools Setup Guide

This guide will help you set up the BuildTools PowerShell module for publishing to GitHub and the PowerShell Gallery.

## Prerequisites

- PowerShell 5.1 or later
- Git
- GitHub account
- PowerShell Gallery account (for publishing)

## Step 1: GitHub Repository Setup

### 1.1 Create GitHub Repository

1. Go to [GitHub](https://github.com) and create a new repository
2. Name it `PowerShell-BuildTools` (or your preferred name)
3. Make it public
4. Don't initialize with README (we already have one)

### 1.2 Push Your Code

```powershell
# Initialize git repository
git init
git add .
git commit -m "Initial commit: BuildTools PowerShell module"

# Add remote origin (replace with your GitHub URL)
git remote add origin https://github.com/Bluscream/PowerShell-BuildTools.git

# Push to GitHub
git branch -M main
git push -u origin main
```

### 1.3 Set Up GitHub Secrets

1. Go to your repository on GitHub: https://github.com/Bluscream/PowerShell-BuildTools
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Add the following secrets:
   - `POWERSHELLGALLERY_API_KEY`: Your PowerShell Gallery API key

## Step 2: PowerShell Gallery Setup

### 2.1 Get PowerShell Gallery API Key

1. Go to [PowerShell Gallery](https://www.powershellgallery.com)
2. Sign in with your Microsoft account
3. Go to **Account Settings** → **API Keys**
4. Create a new API key
5. Copy the API key (you'll need it for GitHub secrets)

### 2.2 Test Local Publishing

```powershell
# Test publishing locally (replace with your API key)
.\Publish-Module.ps1 -NuGetApiKey "YOUR_API_KEY" -WhatIf

# If test passes, publish for real
.\Publish-Module.ps1 -NuGetApiKey "YOUR_API_KEY"
```

## Step 3: Automated Publishing

### 3.1 Create Release

To trigger automated publishing:

1. Create a new release on GitHub:

   - Go to **Releases** → **Create a new release**
   - Tag version: `v1.0.0`
   - Release title: `BuildTools v1.0.0`
   - Description: `Initial release of BuildTools PowerShell module`

2. The GitHub Action will automatically:
   - Validate the module
   - Publish to PowerShell Gallery
   - Create a release

### 3.2 Manual Publishing

You can also publish manually:

```powershell
# Using the publish script
.\Publish-Module.ps1 -NuGetApiKey "YOUR_API_KEY"

# Or using Publish-Module directly
Publish-Module -Path . -NuGetApiKey "YOUR_API_KEY" -Repository PSGallery
```

## Step 4: Installation Methods

### 4.1 From PowerShell Gallery (Recommended)

```powershell
# Install for current user
Install-Module BuildTools -Scope CurrentUser

# Install for all users (requires admin)
Install-Module BuildTools -Scope AllUsers
```

### 4.2 From GitHub

```powershell
# Using the install script
.\Install-BuildTools.ps1 -Source GitHub

# Or manually
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Bluscream/BuildTools/main/Install-BuildTools.ps1" -OutFile "Install-BuildTools.ps1"
.\Install-BuildTools.ps1 -Source GitHub
```

### 4.3 From Local Source

```powershell
# Copy module to PowerShell modules directory
$modulePath = "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\BuildTools"
Copy-Item -Path . -Destination $modulePath -Recurse -Force
```

## Step 5: Verification

### 5.1 Test Installation

```powershell
# Import module
Import-Module BuildTools

# Check available functions
Get-Command -Module BuildTools

# Test basic functionality
Get-UnixTimestamp
Get-GitIgnoreTemplate -Type "CSharp"
```

### 5.2 Run Examples

```powershell
# Run the template usage example
.\Examples\Template-Usage-Example.ps1

# Run the complete build workflow example
.\Examples\Complete-Build-Workflow.ps1
```

## Step 6: Maintenance

### 6.1 Updating Version

1. Update version in `BuildTools.psd1`:

   ```powershell
   # Update ModuleVersion
   $manifest = Import-PowerShellDataFile -Path "BuildTools.psd1"
   $manifest.ModuleVersion = "1.0.1"
   ```

2. Update `CHANGELOG.md` with new changes

3. Commit and push changes:

   ```powershell
   git add .
   git commit -m "Update to version 1.0.1"
   git push
   ```

4. Create new release with tag `v1.0.1` at https://github.com/Bluscream/PowerShell-BuildTools/releases

### 6.2 Adding New Templates

1. Add template files to `Templates/` directory
2. Update template helper functions if needed
3. Test with `Get-TemplateContent` function
4. Update documentation

### 6.3 Adding New Functions

1. Create new function file in `Functions/` directory
2. Add function to `BuildTools.psd1` in `FunctionsToExport`
3. Update `README.md` with function documentation
4. Add examples to `Examples/` directory

## Troubleshooting

### Common Issues

1. **Module not found after installation**

   - Check PowerShell module path: `$env:PSModulePath`
   - Ensure module is in correct location
   - Restart PowerShell session

2. **Publishing fails**

   - Verify API key is correct
   - Check module version is unique
   - Ensure all required files are present

3. **GitHub Actions fail**

   - Check secrets are set correctly
   - Verify workflow files are in `.github/workflows/`
   - Check repository permissions

4. **Template functions not working**
   - Ensure `Templates/` directory exists
   - Check template files have correct extensions
   - Verify template content is valid

### Getting Help

- Check the [Issues](https://github.com/Bluscream/PowerShell-BuildTools/issues) page
- Create a new issue with detailed information
- Include PowerShell version and error messages

## Next Steps

After successful setup:

1. **Test the module** with your own projects
2. **Share with others** by providing installation instructions
3. **Contribute** by submitting pull requests
4. **Report issues** to help improve the module

## Resources

- [PowerShell Gallery](https://www.powershellgallery.com/)
- [PowerShell Module Manifest](https://docs.microsoft.com/en-us/powershell/developer/module/how-to-write-a-powershell-module-manifest)
- [GitHub Actions](https://docs.github.com/en/actions)
- [PowerShell Gallery Publishing](https://docs.microsoft.com/en-us/powershell/scripting/gallery/publishing/publishing-a-package)
