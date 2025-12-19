# PSPredictor Installation Guide

## 📦 Installation

### Prerequisites

**PowerShell Requirements:**
- **Windows**: PowerShell 5.1+ or PowerShell Core 7.0+
- **Linux/macOS**: PowerShell Core 7.0+
- **Recommended**: PowerShell 7.4+ for optimal performance

**.NET Requirements:**
- **.NET Runtime**: .NET 9.0+ (automatically installed with PowerShell 7.4+)
- **Platform Support**: x64 and ARM64 architectures fully supported
- **Dependencies**: No additional dependencies required (self-contained)

**Operating System Compatibility:**
- ✅ **Windows**: 10/11, Server 2019/2022
- ✅ **Linux**: Ubuntu 20.04+, RHEL 8+, Debian 11+, Arch Linux
- ✅ **macOS**: 11.0+ (Big Sur), including Apple Silicon (M1/M2/M3)

**Terminal Compatibility:**
- ✅ **Windows**: Windows Terminal, PowerShell ISE, ConEmu, cmder
- ✅ **Linux**: GNOME Terminal, Konsole, xterm, tmux/screen
- ✅ **macOS**: Terminal.app, iTerm2, Hyper

### Production Installation

**Option 1: PowerShell Gallery (Recommended)**
```powershell
# Install for current user (no admin required)
Install-Module PSPredictor -Scope CurrentUser

# Install system-wide (requires admin/sudo)
Install-Module PSPredictor -Scope AllUsers

# Install specific version
Install-Module PSPredictor -RequiredVersion 2.0.0

# Update to latest version
Update-Module PSPredictor
```

**Option 2: NuGet Package**
```powershell
# Using PackageManagement
Find-Package PSPredictor -Source "https://www.nuget.org/api/v2"
Install-Package PSPredictor

# Using .NET CLI
dotnet add package PSPredictor
```

**Option 3: Local Download (Offline/Airgapped Environments)**
```powershell
# Download using the local installer script
# This downloads the package for offline installation

# Download latest stable version from PowerShell Gallery
.\scripts\Install-PSPredictorLocal.ps1

# Download specific version from GitHub Releases
.\scripts\Install-PSPredictorLocal.ps1 -Version "2.0.0" -Source GitHub -OutputPath "C:\Packages"

# Download latest prerelease with symbols
.\scripts\Install-PSPredictorLocal.ps1 -Version PreRelease -IncludeSymbols -Verify

# After download, install from saved module
Install-Module PSPredictor -Repository PSGallery -RequiredVersion 2.0.0
```

**Option 4: Manual GitHub Releases Download**
```powershell
# Download latest release manually
$url = "https://github.com/wangkanai/PSPredictor/releases/latest/download/PSPredictor.2.0.0.nupkg"
Invoke-WebRequest $url -OutFile "PSPredictor.nupkg"

# Install from local package
Install-Package -Source "./PSPredictor.nupkg" -Scope CurrentUser
```

### Development Installation

**Prerequisites for Development:**
- **.NET SDK 9.0+**: Required for building from source
- **Git**: For cloning the repository
- **Visual Studio Code** or **Visual Studio 2022**: Recommended IDEs

**Clone and Build:**
```bash
# Clone repository
git clone https://github.com/wangkanai/PSPredictor.git
cd PSPredictor

# Restore dependencies
dotnet restore

# Build the module
dotnet build --configuration Release

# Run tests
dotnet test

# Create package
dotnet pack --configuration Release
```

**Install Development Build:**
```powershell
# Build and install locally
$ModulePath = Join-Path -Path (Get-Location) -ChildPath "src/PSPredictor/bin/Release/net9.0/PSPredictor.dll"
Import-Module $ModulePath -Force

# Verify development installation
Get-PSPredictorStatus
```

**Development Workflow:**
```bash
# Watch mode for continuous development
dotnet watch build --project src/PSPredictor/PSPredictor.csproj

# Run specific tests
dotnet test tests/PSPredictor.Tests/ --filter "Category=Core"

# Performance testing
dotnet run --project tests/PSPredictor.Performance.Tests/
```

### Verification

**Basic Verification:**
```powershell
# Check module installation
Get-Module PSPredictor -ListAvailable

# Verify module loads correctly
Import-Module PSPredictor
Get-PSPredictorStatus

# Test basic functionality
Enable-PSPredictor
git <TAB>  # Should show Git completions
```

**Advanced Verification:**
```powershell
# Test AI prediction engine
Test-PSPredictorAI -Verbose

# Verify completion providers
Get-PSPredictorProviders | Format-Table

# Test syntax highlighting
Test-PSPredictorSyntaxHighlighting -Command "Get-Process | Where-Object"

# Check performance metrics
Measure-PSPredictorPerformance -Iterations 100
```

**Troubleshooting Installation:**
```powershell
# Reset configuration
Reset-PSPredictorConfig

# Reinstall with verbose logging
Install-Module PSPredictor -Force -Verbose

# Check for conflicts
Get-Module *Predictor* -ListAvailable

# Validate dependencies
Test-PSPredictorDependencies
```

## Offline Installation (Airgapped Environments)

PSPredictor can be installed in environments without internet access using the local package download workflow.

### Step 1: Download Package (On Connected Machine)

Use the provided download script to obtain the PSPredictor package:

```powershell
# Navigate to PSPredictor repository
cd PSPredictor

# Download latest stable version from PowerShell Gallery
.\scripts\Install-PSPredictorLocal.ps1 -OutputPath "C:\Packages"

# Or download specific version from GitHub
.\scripts\Install-PSPredictorLocal.ps1 -Version "2.0.0" -Source GitHub -OutputPath "C:\Packages"

# Download with symbols for debugging
.\scripts\Install-PSPredictorLocal.ps1 -IncludeSymbols -Verify -OutputPath "C:\Packages"
```

### Step 2: Transfer Package

Transfer the downloaded package to your offline environment:

**For PowerShell Gallery downloads** (using Save-Module):
- Copy the entire `PSPredictor` folder from the output path
- Example: `C:\Packages\PSPredictor\2.0.0\`

**For GitHub downloads** (.nupkg file):
- Copy the `.nupkg` file(s) from the output path
- Example: `C:\Packages\PSPredictor.2.0.0.nupkg`

### Step 3: Install on Offline Machine

**Method 1: From Saved Module Directory**
```powershell
# Import from the downloaded module folder
$ModulePath = "C:\Packages\PSPredictor\2.0.0"
Import-Module $ModulePath -Force

# Or copy to PowerShell module directory
$PSModulePath = "$env:USERPROFILE\Documents\PowerShell\Modules"
Copy-Item -Path "C:\Packages\PSPredictor" -Destination $PSModulePath -Recurse -Force
Import-Module PSPredictor
```

**Method 2: From .nupkg Package**
```powershell
# Extract the .nupkg (it's a ZIP file)
$PackagePath = "C:\Packages\PSPredictor.2.0.0.nupkg"
$ExtractPath = "C:\Temp\PSPredictor"

# Extract using PowerShell
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory($PackagePath, $ExtractPath)

# Find and import the module
$DllPath = Get-ChildItem -Path $ExtractPath -Filter "PSPredictor.dll" -Recurse | Select-Object -First 1
Import-Module $DllPath.FullName -Force
```

**Method 3: Install from Local Repository**
```powershell
# Create a local repository
$LocalRepo = "C:\LocalPSRepo"
New-Item -ItemType Directory -Path $LocalRepo -Force

# Register the local repository
Register-PSRepository -Name "LocalRepo" -SourceLocation $LocalRepo -InstallationPolicy Trusted

# Copy the .nupkg to the local repository
Copy-Item "C:\Packages\PSPredictor.2.0.0.nupkg" -Destination $LocalRepo

# Install from local repository
Install-Module PSPredictor -Repository LocalRepo -Scope CurrentUser
```

### Verification in Offline Environment

```powershell
# Verify module installation
Get-Module PSPredictor -ListAvailable

# Test module functionality
Import-Module PSPredictor
Get-PSPredictorStatus

# Verify offline mode
Enable-PSPredictor
git <TAB>  # Should show completions even without internet
```

### Script Parameters Reference

The `Install-PSPredictorLocal.ps1` script supports the following parameters:

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-Version` | String | 'Latest' | Version to download: 'Latest', 'PreRelease', or specific version |
| `-Source` | String | 'PSGallery' | Download source: 'PSGallery' or 'GitHub' |
| `-OutputPath` | String | Current Dir | Directory to save downloaded package |
| `-IncludeSymbols` | Switch | False | Download symbols package (.snupkg) for debugging |
| `-Force` | Switch | False | Overwrite existing files |
| `-Verify` | Switch | False | Verify package integrity after download |

### Offline Installation Examples

```powershell
# Example 1: Download and prepare for offline installation
.\scripts\Install-PSPredictorLocal.ps1 -Version "2.0.0" -OutputPath "D:\Transfer" -Verify

# Example 2: Download prerelease with symbols for development
.\scripts\Install-PSPredictorLocal.ps1 -Version PreRelease -IncludeSymbols -OutputPath "D:\Dev"

# Example 3: Get latest and verify
.\scripts\Install-PSPredictorLocal.ps1 -Source PSGallery -Verify -Force

# Example 4: Download from GitHub (useful if PSGallery is blocked)
.\scripts\Install-PSPredictorLocal.ps1 -Version "2.0.0-alpha.1" -Source GitHub -OutputPath "C:\Packages"
```

### Troubleshooting Offline Installation

**Issue: Module not found after installation**
```powershell
# Check PowerShell module paths
$env:PSModulePath -split ';'

# Manually add module path if needed
$env:PSModulePath += ";C:\CustomModules"
```

**Issue: Cannot load module DLL**
```powershell
# Ensure .NET 9.0 runtime is installed
dotnet --list-runtimes

# Check if module DLL is blocked
$DllPath = "C:\Packages\PSPredictor\PSPredictor.dll"
Unblock-File -Path $DllPath
Get-ChildItem -Path "C:\Packages\PSPredictor" -Recurse | Unblock-File
```

**Issue: Package integrity verification failed**
```powershell
# Re-download with verification
.\scripts\Install-PSPredictorLocal.ps1 -Version "2.0.0" -Force -Verify

# Check file hash manually
Get-FileHash "C:\Packages\PSPredictor.2.0.0.nupkg" -Algorithm SHA256
```

## Next Steps

After successful installation, see the [User Guide](readme.md#-user-guide) for detailed usage instructions and configuration options.

## Getting Help

If you encounter installation issues:

1. Check the [Troubleshooting Guide](readme.md#troubleshooting) for common solutions
2. Review the [FAQ](readme.md#-references) for frequently asked questions
3. [Open an issue](https://github.com/wangkanai/PSPredictor/issues) on GitHub for additional support

---

**[← Back to Main README](readme.md)**