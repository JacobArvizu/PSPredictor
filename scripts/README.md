# PSPredictor Scripts

This directory contains utility scripts for PSPredictor installation, configuration, and maintenance.

## Installation Scripts

### Install-PSPredictorLocal.ps1

Downloads PSPredictor module package locally for offline installation and distribution.

**Purpose**: Provides a streamlined way to download PSPredictor packages for airgapped environments, offline installation, or internal distribution.

**Features**:
- ✅ Download from PowerShell Gallery or GitHub Releases
- ✅ Support for stable releases, prereleases, and specific versions
- ✅ Automatic version detection (latest/prerelease)
- ✅ Package integrity verification
- ✅ Symbol package download for debugging
- ✅ Comprehensive error handling and user feedback

**Quick Start**:
```powershell
# Download latest stable version
.\Install-PSPredictorLocal.ps1

# Download specific version from GitHub
.\Install-PSPredictorLocal.ps1 -Version "2.0.0" -Source GitHub

# Download prerelease with symbols and verification
.\Install-PSPredictorLocal.ps1 -Version PreRelease -IncludeSymbols -Verify
```

**Parameters**:
- `-Version`: Version to download ('Latest', 'PreRelease', or specific like '2.0.0')
- `-Source`: Download source ('PSGallery' or 'GitHub')
- `-OutputPath`: Directory to save package (default: current directory)
- `-IncludeSymbols`: Download symbols package (.snupkg) for debugging
- `-Force`: Overwrite existing files
- `-Verify`: Verify package integrity after download

**Use Cases**:

1. **Offline Installation**: Download on connected machine, transfer to airgapped environment
   ```powershell
   .\Install-PSPredictorLocal.ps1 -OutputPath "D:\Packages" -Verify
   # Transfer to offline machine and install
   ```

2. **Internal Distribution**: Download once, distribute to team
   ```powershell
   .\Install-PSPredictorLocal.ps1 -Version "2.0.0" -OutputPath "\\FileServer\Packages"
   ```

3. **Development/Testing**: Download prerelease with symbols
   ```powershell
   .\Install-PSPredictorLocal.ps1 -Version PreRelease -IncludeSymbols
   ```

4. **Backup/Archive**: Keep specific versions for rollback
   ```powershell
   .\Install-PSPredictorLocal.ps1 -Version "2.0.0" -OutputPath "C:\Backup\Packages"
   ```

**Complete Documentation**: See [docs/installation.md](../docs/installation.md#offline-installation-airgapped-environments) for detailed offline installation workflow.

**Quick Reference**: For fast commands and common scenarios, see [Offline Installation Quick Reference](../docs/OFFLINE_INSTALLATION_QUICK_REFERENCE.md).

## Legacy Scripts (v1.x)

The `src` directory contains legacy PowerShell-based completions from PSPredictor v1.x. These are maintained for backward compatibility and reference but are being replaced by the C# .NET 9.0 binary module in v2.0.

**Legacy Structure**:
- `src/PSPredictor.psm1` - v1.x main module
- `src/Completions/` - v1.x completion providers
- `src/Public/` - v1.x public functions

**Migration Note**: PSPredictor v2.0 is a complete rewrite in C# with significant performance improvements. Users should migrate to v2.0 for best experience. See [migration guide](../docs/archives/2025-07-30-PROJECT.md) for details.

## Test Scripts

Test scripts are located in the `tests` subdirectory and use Pester testing framework for v1.x validation.

## Contributing

When adding new utility scripts:

1. **Follow PowerShell Best Practices**:
   - Use approved verbs (Get, Set, New, etc.)
   - Include comprehensive comment-based help
   - Implement parameter validation
   - Support `-WhatIf` and `-Confirm` for destructive operations

2. **Documentation**:
   - Update this README with script description
   - Add usage examples
   - Document all parameters
   - Include common use cases

3. **Testing**:
   - Test on Windows PowerShell 5.1 and PowerShell 7+
   - Verify cross-platform compatibility (Windows/Linux/macOS)
   - Test error scenarios and edge cases

4. **Error Handling**:
   - Use `$ErrorActionPreference = 'Stop'` for robust error handling
   - Provide clear, actionable error messages
   - Include recovery suggestions in error output

## Resources

- **Main Documentation**: [../docs/readme.md](../docs/readme.md)
- **Installation Guide**: [../docs/installation.md](../docs/installation.md)
- **Contributing Guide**: [../CONTRIBUTING.md](../CONTRIBUTING.md)
- **GitHub Repository**: https://github.com/wangkanai/PSPredictor

## Support

For issues, questions, or suggestions:
- 🐛 [Report a Bug](https://github.com/wangkanai/PSPredictor/issues/new?template=bug_report.md)
- 💡 [Request a Feature](https://github.com/wangkanai/PSPredictor/issues/new?template=feature_request.md)
- 💬 [Ask a Question](https://github.com/wangkanai/PSPredictor/discussions)
