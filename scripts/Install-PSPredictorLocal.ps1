<#
.SYNOPSIS
    Downloads PSPredictor module package locally for offline installation.

.DESCRIPTION
    This script downloads the PSPredictor PowerShell module package from either
    PowerShell Gallery or GitHub Releases and saves it locally for offline installation.
    Useful for airgapped environments or when you need to distribute the module internally.

.PARAMETER Version
    The version of PSPredictor to download. If not specified, downloads the latest stable version.
    Use 'Latest' for the latest release, 'PreRelease' for latest prerelease, or specify exact version like '2.0.0'.

.PARAMETER Source
    Source to download from. Options are 'PSGallery' or 'GitHub'. Default is 'PSGallery'.

.PARAMETER OutputPath
    Directory where the package will be saved. Defaults to current directory.

.PARAMETER IncludeSymbols
    If specified, also downloads the symbols package (.snupkg) for debugging purposes.

.PARAMETER Force
    Overwrites existing package files if they already exist.

.PARAMETER Verify
    Verifies the downloaded package integrity after download.

.EXAMPLE
    .\Install-PSPredictorLocal.ps1
    Downloads the latest stable version from PowerShell Gallery to current directory.

.EXAMPLE
    .\Install-PSPredictorLocal.ps1 -Version "2.0.0" -Source GitHub -OutputPath "C:\Packages"
    Downloads version 2.0.0 from GitHub Releases to C:\Packages.

.EXAMPLE
    .\Install-PSPredictorLocal.ps1 -Version PreRelease -IncludeSymbols -Verify
    Downloads the latest prerelease with symbols and verifies integrity.

.EXAMPLE
    .\Install-PSPredictorLocal.ps1 -Version "2.0.0-alpha.1" -Force
    Downloads specific prerelease version, overwriting if exists.

.NOTES
    Author: PSPredictor Team
    Version: 2.0.0
    Requires: PowerShell 5.1+
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Position = 0)]
    [ValidateNotNullOrEmpty()]
    [string]$Version = 'Latest',
    
    [Parameter()]
    [ValidateSet('PSGallery', 'GitHub')]
    [string]$Source = 'PSGallery',
    
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$OutputPath = $PWD,
    
    [Parameter()]
    [switch]$IncludeSymbols,
    
    [Parameter()]
    [switch]$Force,
    
    [Parameter()]
    [switch]$Verify
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

#region Helper Functions

function Write-ColorOutput {
    param(
        [Parameter(Mandatory)]
        [string]$Message,
        
        [Parameter()]
        [ValidateSet('Info', 'Success', 'Warning', 'Error')]
        [string]$Type = 'Info'
    )
    
    $colors = @{
        'Info'    = 'Cyan'
        'Success' = 'Green'
        'Warning' = 'Yellow'
        'Error'   = 'Red'
    }
    
    $icons = @{
        'Info'    = '📦'
        'Success' = '✅'
        'Warning' = '⚠️'
        'Error'   = '❌'
    }
    
    Write-Host "$($icons[$Type]) " -ForegroundColor $colors[$Type] -NoNewline
    Write-Host $Message -ForegroundColor $colors[$Type]
}

function Get-LatestVersionFromPSGallery {
    param(
        [bool]$IncludePrerelease = $false
    )
    
    try {
        Write-Verbose "Querying PowerShell Gallery for latest version..."
        
        $findParams = @{
            Name             = 'PSPredictor'
            Repository       = 'PSGallery'
            ErrorAction      = 'Stop'
            AllowPrerelease  = $IncludePrerelease
        }
        
        $module = Find-Module @findParams | Select-Object -First 1
        
        if ($null -eq $module) {
            throw "PSPredictor module not found in PowerShell Gallery"
        }
        
        return $module.Version
    }
    catch {
        Write-ColorOutput "Failed to query PowerShell Gallery: $($_.Exception.Message)" -Type Error
        throw
    }
}

function Get-LatestVersionFromGitHub {
    param(
        [bool]$IncludePrerelease = $false
    )
    
    try {
        Write-Verbose "Querying GitHub API for latest release..."
        
        $apiUrl = if ($IncludePrerelease) {
            'https://api.github.com/repos/wangkanai/PSPredictor/releases'
        }
        else {
            'https://api.github.com/repos/wangkanai/PSPredictor/releases/latest'
        }
        
        $headers = @{
            'Accept'               = 'application/vnd.github.v3+json'
            'User-Agent'           = 'PSPredictor-Installer/2.0'
        }
        
        $response = Invoke-RestMethod -Uri $apiUrl -Headers $headers -ErrorAction Stop
        
        if ($IncludePrerelease) {
            $release = $response | Select-Object -First 1
        }
        else {
            $release = $response
        }
        
        if ($null -eq $release) {
            throw "No releases found in GitHub repository"
        }
        
        # Extract version from tag (remove 'v' prefix if present)
        $versionString = $release.tag_name -replace '^v', ''
        
        return $versionString
    }
    catch {
        Write-ColorOutput "Failed to query GitHub API: $($_.Exception.Message)" -Type Error
        throw
    }
}

function Download-FromPSGallery {
    param(
        [Parameter(Mandatory)]
        [string]$ModuleVersion,
        
        [Parameter(Mandatory)]
        [string]$DestinationPath,
        
        [bool]$IncludeSymbolsPackage = $false
    )
    
    try {
        Write-ColorOutput "Downloading PSPredictor v$ModuleVersion from PowerShell Gallery..." -Type Info
        
        # Ensure destination directory exists
        if (-not (Test-Path $DestinationPath)) {
            New-Item -ItemType Directory -Path $DestinationPath -Force | Out-Null
        }
        
        # Use Save-Module to download the package
        $saveParams = @{
            Name             = 'PSPredictor'
            RequiredVersion  = $ModuleVersion
            Path             = $DestinationPath
            Repository       = 'PSGallery'
            Force            = $Force
            ErrorAction      = 'Stop'
        }
        
        Save-Module @saveParams
        
        Write-ColorOutput "Successfully downloaded PSPredictor v$ModuleVersion" -Type Success
        
        # Find the downloaded module directory
        $modulePath = Join-Path $DestinationPath "PSPredictor\$ModuleVersion"
        
        if (Test-Path $modulePath) {
            Write-ColorOutput "Module saved to: $modulePath" -Type Info
            return $modulePath
        }
        else {
            throw "Module directory not found at expected path: $modulePath"
        }
    }
    catch {
        Write-ColorOutput "Failed to download from PowerShell Gallery: $($_.Exception.Message)" -Type Error
        throw
    }
}

function Download-FromGitHub {
    param(
        [Parameter(Mandatory)]
        [string]$ModuleVersion,
        
        [Parameter(Mandatory)]
        [string]$DestinationPath,
        
        [bool]$IncludeSymbolsPackage = $false
    )
    
    try {
        Write-ColorOutput "Downloading PSPredictor v$ModuleVersion from GitHub Releases..." -Type Info
        
        # Ensure destination directory exists
        if (-not (Test-Path $DestinationPath)) {
            New-Item -ItemType Directory -Path $DestinationPath -Force | Out-Null
        }
        
        # Add 'v' prefix for tag if not present
        $tagName = if ($ModuleVersion -match '^v') { $ModuleVersion } else { "v$ModuleVersion" }
        
        # GitHub releases URL pattern
        $packageFileName = "PSPredictor.$ModuleVersion.nupkg"
        $symbolsFileName = "PSPredictor.$ModuleVersion.snupkg"
        $baseUrl = "https://github.com/wangkanai/PSPredictor/releases/download/$tagName"
        
        # Download main package
        $packageUrl = "$baseUrl/$packageFileName"
        $packagePath = Join-Path $DestinationPath $packageFileName
        
        Write-Verbose "Downloading from: $packageUrl"
        Write-Verbose "Saving to: $packagePath"
        
        if ((Test-Path $packagePath) -and -not $Force) {
            Write-ColorOutput "Package already exists at: $packagePath (use -Force to overwrite)" -Type Warning
            return $packagePath
        }
        
        try {
            $webClient = New-Object System.Net.WebClient
            $webClient.Headers.Add('User-Agent', 'PSPredictor-Installer/2.0')
            $webClient.DownloadFile($packageUrl, $packagePath)
            $webClient.Dispose()
            
            Write-ColorOutput "Successfully downloaded: $packageFileName" -Type Success
        }
        catch {
            Write-ColorOutput "Failed to download package: $($_.Exception.Message)" -Type Error
            Write-ColorOutput "URL attempted: $packageUrl" -Type Warning
            throw
        }
        
        # Download symbols package if requested
        if ($IncludeSymbolsPackage) {
            $symbolsUrl = "$baseUrl/$symbolsFileName"
            $symbolsPath = Join-Path $DestinationPath $symbolsFileName
            
            Write-ColorOutput "Downloading symbols package..." -Type Info
            
            try {
                $webClient = New-Object System.Net.WebClient
                $webClient.Headers.Add('User-Agent', 'PSPredictor-Installer/2.0')
                $webClient.DownloadFile($symbolsUrl, $symbolsPath)
                $webClient.Dispose()
                
                Write-ColorOutput "Successfully downloaded: $symbolsFileName" -Type Success
            }
            catch {
                Write-ColorOutput "Symbols package not available or download failed" -Type Warning
            }
        }
        
        return $packagePath
    }
    catch {
        Write-ColorOutput "Failed to download from GitHub: $($_.Exception.Message)" -Type Error
        throw
    }
}

function Test-PackageIntegrity {
    param(
        [Parameter(Mandatory)]
        [string]$PackagePath
    )
    
    try {
        Write-ColorOutput "Verifying package integrity..." -Type Info
        
        if (-not (Test-Path $PackagePath)) {
            throw "Package file not found: $PackagePath"
        }
        
        # Check if file is a valid ZIP archive (NuGet packages are ZIP files)
        try {
            Add-Type -AssemblyName System.IO.Compression.FileSystem
            $archive = [System.IO.Compression.ZipFile]::OpenRead($PackagePath)
            
            # Check for required files in the package
            $requiredFiles = @('PSPredictor.psd1', 'PSPredictor.dll')
            $foundFiles = @()
            
            foreach ($entry in $archive.Entries) {
                foreach ($required in $requiredFiles) {
                    if ($entry.FullName -like "*$required") {
                        $foundFiles += $required
                    }
                }
            }
            
            $archive.Dispose()
            
            if ($foundFiles.Count -eq $requiredFiles.Count) {
                Write-ColorOutput "Package integrity verified successfully" -Type Success
                return $true
            }
            else {
                $missing = $requiredFiles | Where-Object { $_ -notin $foundFiles }
                Write-ColorOutput "Package integrity check failed - missing files: $($missing -join ', ')" -Type Error
                return $false
            }
        }
        catch {
            Write-ColorOutput "Failed to read package as ZIP archive: $($_.Exception.Message)" -Type Error
            return $false
        }
    }
    catch {
        Write-ColorOutput "Package integrity verification failed: $($_.Exception.Message)" -Type Error
        return $false
    }
}

function Show-InstallationInstructions {
    param(
        [Parameter(Mandatory)]
        [string]$PackagePath
    )
    
    Write-Host ""
    Write-ColorOutput "Installation Instructions:" -Type Info
    Write-Host ""
    Write-Host "To install the downloaded package locally, use one of these methods:" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Method 1: Direct Installation (Recommended)" -ForegroundColor Yellow
    Write-Host "  Install-Module PSPredictor -Scope CurrentUser -Repository PSGallery -RequiredVersion <version>" -ForegroundColor White
    Write-Host ""
    Write-Host "Method 2: Manual Installation from Package" -ForegroundColor Yellow
    Write-Host "  # For .nupkg file:" -ForegroundColor Gray
    Write-Host "  `$PackagePath = '$PackagePath'" -ForegroundColor White
    Write-Host "  Install-Package -Source `$PackagePath -Scope CurrentUser" -ForegroundColor White
    Write-Host ""
    Write-Host "Method 3: Extract and Import from Saved Module" -ForegroundColor Yellow
    Write-Host "  # If downloaded via Save-Module:" -ForegroundColor Gray
    Write-Host "  Import-Module '$PackagePath' -Force" -ForegroundColor White
    Write-Host ""
    Write-Host "For more information, visit: https://github.com/wangkanai/PSPredictor" -ForegroundColor Cyan
    Write-Host ""
}

#endregion

#region Main Script

try {
    Write-Host ""
    Write-ColorOutput "PSPredictor Local Package Downloader v2.0" -Type Info
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host ""
    
    # Normalize output path
    $OutputPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputPath)
    
    # Determine version to download
    $moduleVersion = $Version
    
    if ($Version -eq 'Latest') {
        Write-ColorOutput "Determining latest stable version..." -Type Info
        $moduleVersion = if ($Source -eq 'PSGallery') {
            Get-LatestVersionFromPSGallery -IncludePrerelease $false
        }
        else {
            Get-LatestVersionFromGitHub -IncludePrerelease $false
        }
        Write-ColorOutput "Latest stable version: $moduleVersion" -Type Success
    }
    elseif ($Version -eq 'PreRelease') {
        Write-ColorOutput "Determining latest prerelease version..." -Type Info
        $moduleVersion = if ($Source -eq 'PSGallery') {
            Get-LatestVersionFromPSGallery -IncludePrerelease $true
        }
        else {
            Get-LatestVersionFromGitHub -IncludePrerelease $true
        }
        Write-ColorOutput "Latest prerelease version: $moduleVersion" -Type Success
    }
    
    Write-Host ""
    Write-ColorOutput "Download Configuration:" -Type Info
    Write-Host "  Version:        $moduleVersion" -ForegroundColor Gray
    Write-Host "  Source:         $Source" -ForegroundColor Gray
    Write-Host "  Output Path:    $OutputPath" -ForegroundColor Gray
    Write-Host "  Include Symbols: $IncludeSymbols" -ForegroundColor Gray
    Write-Host ""
    
    # Download based on source
    if ($PSCmdlet.ShouldProcess("PSPredictor v$moduleVersion", "Download from $Source")) {
        $downloadedPath = if ($Source -eq 'PSGallery') {
            Download-FromPSGallery -ModuleVersion $moduleVersion -DestinationPath $OutputPath -IncludeSymbolsPackage $IncludeSymbols
        }
        else {
            Download-FromGitHub -ModuleVersion $moduleVersion -DestinationPath $OutputPath -IncludeSymbolsPackage $IncludeSymbols
        }
        
        # Verify package if requested
        if ($Verify) {
            Write-Host ""
            if ($Source -eq 'GitHub') {
                $packageFile = Join-Path $OutputPath "PSPredictor.$moduleVersion.nupkg"
                if (Test-Path $packageFile) {
                    $isValid = Test-PackageIntegrity -PackagePath $packageFile
                    if (-not $isValid) {
                        Write-ColorOutput "Package verification failed!" -Type Error
                        exit 1
                    }
                }
            }
            else {
                Write-ColorOutput "Skipping verification for Save-Module downloads (verified by PowerShell)" -Type Info
            }
        }
        
        # Show installation instructions
        Write-Host ""
        Show-InstallationInstructions -PackagePath $downloadedPath
        
        Write-Host ""
        Write-ColorOutput "Download completed successfully!" -Type Success
    }
}
catch {
    Write-Host ""
    Write-ColorOutput "Download failed: $($_.Exception.Message)" -Type Error
    Write-Host ""
    Write-Host "Stack Trace:" -ForegroundColor Gray
    Write-Host $_.ScriptStackTrace -ForegroundColor DarkGray
    exit 1
}

#endregion
