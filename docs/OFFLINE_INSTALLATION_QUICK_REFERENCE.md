# PSPredictor Offline Installation Quick Reference

Quick reference guide for downloading and installing PSPredictor in offline/airgapped environments.

## Quick Commands

### Download Package (Connected Machine)

```powershell
# Latest stable from PowerShell Gallery
.\scripts\Install-PSPredictorLocal.ps1 -OutputPath "C:\Packages"

# Specific version from GitHub
.\scripts\Install-PSPredictorLocal.ps1 -Version "2.0.0" -Source GitHub -OutputPath "C:\Packages"

# Latest prerelease with symbols
.\scripts\Install-PSPredictorLocal.ps1 -Version PreRelease -IncludeSymbols -Verify
```

### Install on Offline Machine

```powershell
# Method 1: Import from saved module
Import-Module "C:\Packages\PSPredictor\2.0.0" -Force

# Method 2: Copy to module directory
Copy-Item "C:\Packages\PSPredictor" -Destination "$env:USERPROFILE\Documents\PowerShell\Modules" -Recurse -Force
Import-Module PSPredictor

# Method 3: Local repository
Register-PSRepository -Name "LocalRepo" -SourceLocation "C:\LocalPSRepo" -InstallationPolicy Trusted
Copy-Item "C:\Packages\PSPredictor.2.0.0.nupkg" -Destination "C:\LocalPSRepo"
Install-Module PSPredictor -Repository LocalRepo -Scope CurrentUser
```

## Common Scenarios

### Scenario 1: Corporate Airgapped Network

**Connected Machine**:
```powershell
# Download to network share
.\scripts\Install-PSPredictorLocal.ps1 -Version "2.0.0" -OutputPath "\\FileServer\Software\PSPredictor" -Verify
```

**Offline Machines** (via GPO or login script):
```powershell
$NetworkPath = "\\FileServer\Software\PSPredictor\PSPredictor\2.0.0"
$LocalPath = "$env:USERPROFILE\Documents\PowerShell\Modules\PSPredictor"
Copy-Item $NetworkPath -Destination $LocalPath -Recurse -Force
Import-Module PSPredictor
```

### Scenario 2: USB Transfer

**Step 1 - Download**:
```powershell
.\scripts\Install-PSPredictorLocal.ps1 -Version "2.0.0" -OutputPath "E:\PSPredictor" -IncludeSymbols -Verify
```

**Step 2 - Transfer USB to offline machine**

**Step 3 - Install**:
```powershell
Import-Module "E:\PSPredictor\PSPredictor\2.0.0" -Force
```

### Scenario 3: Development Environment

**Download with debugging support**:
```powershell
.\scripts\Install-PSPredictorLocal.ps1 -Version PreRelease -IncludeSymbols -OutputPath "C:\Dev\Packages"
```

**Extract and inspect**:
```powershell
$PackagePath = "C:\Dev\Packages\PSPredictor.2.0.0-alpha.1.nupkg"
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory($PackagePath, "C:\Dev\PSPredictor")
```

## Script Parameters

| Parameter | Values | Description |
|-----------|--------|-------------|
| `-Version` | 'Latest', 'PreRelease', '2.0.0' | Version to download |
| `-Source` | 'PSGallery', 'GitHub' | Download source |
| `-OutputPath` | Directory path | Save location |
| `-IncludeSymbols` | Switch | Download .snupkg |
| `-Force` | Switch | Overwrite files |
| `-Verify` | Switch | Check integrity |

## Verification

```powershell
# Check installation
Get-Module PSPredictor -ListAvailable

# Test functionality
Import-Module PSPredictor
Get-PSPredictorStatus
Enable-PSPredictor

# Verify completions work offline
git <TAB>
docker <TAB>
```

## Troubleshooting

### Module not found
```powershell
# Check paths
$env:PSModulePath -split ';'

# Add custom path
$env:PSModulePath += ";C:\CustomModules"
```

### DLL blocked
```powershell
# Unblock all files
Get-ChildItem "C:\Packages\PSPredictor" -Recurse | Unblock-File
```

### .NET runtime missing
```powershell
# Check version
dotnet --list-runtimes

# Required: .NET 9.0+
# Download: https://dotnet.microsoft.com/download/dotnet/9.0
```

### Package corrupt
```powershell
# Re-download with verification
.\scripts\Install-PSPredictorLocal.ps1 -Version "2.0.0" -Force -Verify

# Check hash
Get-FileHash "C:\Packages\PSPredictor.2.0.0.nupkg" -Algorithm SHA256
```

## Files Transferred

### PowerShell Gallery (Save-Module)
- `PSPredictor/` directory
  - `PSPredictor/2.0.0/` version directory
    - `PSPredictor.psd1` - Module manifest
    - `PSPredictor.dll` - Binary module
    - Dependencies and resources

### GitHub Releases (.nupkg)
- `PSPredictor.2.0.0.nupkg` - Main package
- `PSPredictor.2.0.0.snupkg` - Symbols (optional)

## Prerequisites

### Connected Machine
- PowerShell 5.1+ or PowerShell 7+
- Internet access to PowerShell Gallery or GitHub
- Disk space for package (~20-50 MB)

### Offline Machine
- PowerShell 5.1+ (Windows) or PowerShell 7+ (Linux/macOS)
- .NET 9.0 runtime
- ~50 MB disk space for module installation

## Support

- **Full Documentation**: [docs/installation.md](installation.md)
- **Demo Script**: Run `.\scripts\Demo-OfflineInstallation.ps1`
- **GitHub Issues**: https://github.com/wangkanai/PSPredictor/issues
- **Discussions**: https://github.com/wangkanai/PSPredictor/discussions

---

**Last Updated**: 2025-12-19  
**PSPredictor Version**: 2.0.0+
