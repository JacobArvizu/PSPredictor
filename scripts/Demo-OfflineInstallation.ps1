<#
.SYNOPSIS
    Demonstration of PSPredictor offline installation workflow.

.DESCRIPTION
    This script demonstrates the complete workflow for downloading and installing
    PSPredictor in offline/airgapped environments. It's provided as an example
    and reference for users who need to implement offline installation.

.NOTES
    This is a demonstration script. Modify paths and parameters according to
    your environment's requirements.
#>

[CmdletBinding()]
param()

Write-Host @"

╔══════════════════════════════════════════════════════════════════════════╗
║                                                                          ║
║     PSPredictor Offline Installation Workflow Demonstration             ║
║     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━     ║
║                                                                          ║
║     This demonstrates the complete workflow for offline installation    ║
║                                                                          ║
╚══════════════════════════════════════════════════════════════════════════╝

"@ -ForegroundColor Cyan

Write-Host "`n━━━ STEP 1: Download Package (Connected Machine) ━━━`n" -ForegroundColor Yellow

Write-Host "Example commands for downloading PSPredictor package:`n" -ForegroundColor Gray

Write-Host "# Download latest stable version from PowerShell Gallery" -ForegroundColor White
Write-Host ".\scripts\Install-PSPredictorLocal.ps1 -OutputPath 'C:\Packages'" -ForegroundColor Green
Write-Host ""

Write-Host "# Download specific version from GitHub Releases" -ForegroundColor White
Write-Host ".\scripts\Install-PSPredictorLocal.ps1 -Version '2.0.0' -Source GitHub -OutputPath 'C:\Packages'" -ForegroundColor Green
Write-Host ""

Write-Host "# Download latest prerelease with symbols and verification" -ForegroundColor White
Write-Host ".\scripts\Install-PSPredictorLocal.ps1 -Version PreRelease -IncludeSymbols -Verify -OutputPath 'C:\Packages'" -ForegroundColor Green
Write-Host ""

Write-Host "`n━━━ STEP 2: Transfer Package to Offline Environment ━━━`n" -ForegroundColor Yellow

Write-Host "Transfer methods:" -ForegroundColor Gray
Write-Host "  • USB drive" -ForegroundColor White
Write-Host "  • Internal file share" -ForegroundColor White
Write-Host "  • Removable media" -ForegroundColor White
Write-Host "  • Physical media (CD/DVD)" -ForegroundColor White
Write-Host ""

Write-Host "Files to transfer:" -ForegroundColor Gray
Write-Host "  • PSPredictor folder (if using Save-Module)" -ForegroundColor White
Write-Host "  • PSPredictor.X.X.X.nupkg (if using GitHub download)" -ForegroundColor White
Write-Host "  • PSPredictor.X.X.X.snupkg (if symbols included)" -ForegroundColor White
Write-Host ""

Write-Host "`n━━━ STEP 3: Install on Offline Machine ━━━`n" -ForegroundColor Yellow

Write-Host "Method 1: Import from saved module directory" -ForegroundColor Gray
Write-Host @"
`$ModulePath = "C:\Packages\PSPredictor\2.0.0"
Import-Module `$ModulePath -Force

# Or copy to PowerShell module directory
`$PSModulePath = "`$env:USERPROFILE\Documents\PowerShell\Modules"
Copy-Item -Path "C:\Packages\PSPredictor" -Destination `$PSModulePath -Recurse -Force
Import-Module PSPredictor
"@ -ForegroundColor Green
Write-Host ""

Write-Host "Method 2: Extract and install from .nupkg" -ForegroundColor Gray
Write-Host @"
# Extract the .nupkg (it's a ZIP file)
`$PackagePath = "C:\Packages\PSPredictor.2.0.0.nupkg"
`$ExtractPath = "C:\Temp\PSPredictor"

Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory(`$PackagePath, `$ExtractPath)

# Find and import the module DLL
`$DllPath = Get-ChildItem -Path `$ExtractPath -Filter "PSPredictor.dll" -Recurse | Select-Object -First 1
Import-Module `$DllPath.FullName -Force
"@ -ForegroundColor Green
Write-Host ""

Write-Host "Method 3: Use local PowerShell repository" -ForegroundColor Gray
Write-Host @"
# Create and register local repository
`$LocalRepo = "C:\LocalPSRepo"
New-Item -ItemType Directory -Path `$LocalRepo -Force
Register-PSRepository -Name "LocalRepo" -SourceLocation `$LocalRepo -InstallationPolicy Trusted

# Copy package and install
Copy-Item "C:\Packages\PSPredictor.2.0.0.nupkg" -Destination `$LocalRepo
Install-Module PSPredictor -Repository LocalRepo -Scope CurrentUser
"@ -ForegroundColor Green
Write-Host ""

Write-Host "`n━━━ STEP 4: Verify Installation ━━━`n" -ForegroundColor Yellow

Write-Host "Verification commands:" -ForegroundColor Gray
Write-Host @"
# Check module is available
Get-Module PSPredictor -ListAvailable

# Import and test
Import-Module PSPredictor
Get-PSPredictorStatus

# Verify functionality
Enable-PSPredictor
git <TAB>  # Should show completions even offline
"@ -ForegroundColor Green
Write-Host ""

Write-Host "`n━━━ STEP 5: Troubleshooting (If Needed) ━━━`n" -ForegroundColor Yellow

Write-Host "Common issues and solutions:" -ForegroundColor Gray
Write-Host ""

Write-Host "Issue: Cannot find module" -ForegroundColor White
Write-Host @"
# Check module paths
`$env:PSModulePath -split ';'

# Add custom path if needed
`$env:PSModulePath += ";C:\CustomModules"
"@ -ForegroundColor Green
Write-Host ""

Write-Host "Issue: DLL blocked by Windows" -ForegroundColor White
Write-Host @"
# Unblock all module files
`$ModulePath = "C:\Packages\PSPredictor"
Get-ChildItem -Path `$ModulePath -Recurse | Unblock-File
"@ -ForegroundColor Green
Write-Host ""

Write-Host "Issue: .NET runtime missing" -ForegroundColor White
Write-Host @"
# Check .NET runtime version
dotnet --list-runtimes

# PSPredictor requires .NET 9.0 runtime
# Download from: https://dotnet.microsoft.com/download/dotnet/9.0
"@ -ForegroundColor Green
Write-Host ""

Write-Host @"

╔══════════════════════════════════════════════════════════════════════════╗
║                                                                          ║
║     📚 For detailed documentation, see:                                  ║
║     docs/installation.md#offline-installation-airgapped-environments     ║
║                                                                          ║
║     🔗 GitHub: https://github.com/wangkanai/PSPredictor                  ║
║                                                                          ║
╚══════════════════════════════════════════════════════════════════════════╝

"@ -ForegroundColor Cyan

Write-Host "Press any key to continue..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
