# Arch Linux Modular Installation System

This directory contains a modular installation system for Arch Linux with Hyprland desktop environment.

## Overview

The installation system is split into independent, reusable modules that can be run individually or orchestrated together. Each module handles a specific aspect of the system setup.

## Directory Structure

```
os-setup/arch/
├── install.sh              # Master orchestration script
├── setup.sh                # Compatibility wrapper (redirects to install.sh)
├── modules/                # Individual installation modules
│   ├── common.sh           # Shared functions and utilities
│   ├── 01-system-update.sh
│   ├── 02-core-packages.sh
│   ├── 03-desktop-packages.sh
│   ├── 04-yay.sh
│   ├── 05-aur-packages.sh
│   ├── 06-services.sh
│   ├── 07-fonts.sh
│   ├── 08-devtools.sh
│   ├── 09-nvidia.sh
│   ├── 11-flatpak.sh
│   └── 12-dotfiles.sh
└── (legacy scripts...)
```

## Installation Modes

### Full Installation (Default)
Installs everything including desktop environment, development tools, and optional features.
```bash
./install.sh
# or
./install.sh --full
```

### Desktop Installation
Installs desktop environment and essential services, skips optional tools.
```bash
./install.sh --desktop
```

### Minimal Installation
Installs only core packages and development tools (no desktop environment).
```bash
./install.sh --minimal
```

## Modules

Each module is a self-contained script that can be run independently:

| Module | Description | Required | Desktop | Full |
|--------|-------------|----------|---------|------|
| 01-system-update | Updates system packages | ✓ | ✓ | ✓ |
| 02-core-packages | Core development tools | ✓ | ✓ | ✓ |
| 03-desktop-packages | Hyprland and desktop packages | ✗ | ✓ | ✓ |
| 04-yay | AUR helper installation | ✓ | ✓ | ✓ |
| 05-aur-packages | AUR packages (lazygit, etc.) | ✗ | ✓ | ✓ |
| 06-services | System services configuration | ✗ | ✓ | ✓ |
| 07-fonts | Nerd Fonts installation | ✗ | ✓ | ✓ |
| 08-devtools | Dev tools (pyenv, nvm, etc.) | ✗ | ✓ | ✓ |
| 09-nvidia | NVIDIA driver configuration | ✗ | ⚡ | ⚡ |
| 11-flatpak | Flatpak applications | ✗ | ✓ | ✓ |
| 12-dotfiles | Dotfiles installation (stow) | ✗ | ✓ | ✓ |

Legend:
- ✓ = Always installed
- ✗ = Not installed in this mode
- ⚡ = Auto-detected (or force with --nvidia flag)

## Running Individual Modules

Each module can be executed independently:

```bash
cd modules/

# Update system
./01-system-update.sh

# Install core packages only
./02-core-packages.sh

# Configure NVIDIA (if GPU detected)
./09-nvidia.sh

# Install dotfiles
./12-dotfiles.sh
```

## Error Handling

The master script (`install.sh`) provides comprehensive error handling:

1. **Module Failures**: Each module reports success/failure
2. **Required vs Optional**: Required modules stop installation if they fail
3. **Detailed Summary**: Shows which modules succeeded, failed, or were skipped
4. **Error Messages**: Captures and displays specific error information
5. **Continue on Optional Failure**: Optional modules don't stop installation

### Example Output

```
================================================================================
[====] Installation Summary
================================================================================

Installation Mode: full

[SUCCESS] Successfully Completed (10):
  ✓ System Update
  ✓ Core Development Packages
  ✓ AUR Helper (yay)
  ✓ Desktop Environment Packages
  ✓ System Services
  ...

[WARN] Failed Modules (1):
  ✗ NVIDIA Configuration

[ERROR] Detailed Errors:
  09-nvidia.sh: Exit code: 1 (No NVIDIA GPU detected)

================================================================================
```

## Common Functions (common.sh)

The `common.sh` library provides shared utilities:

- **Logging**: `log_error`, `log_info`, `log_warn`, `log_step`, `log_success`
- **System Checks**: `check_arch`, `check_internet`, `check_sudo`
- **Verification**: `verify_package`, `verify_command`
- **Package Management**: `install_packages`
- **Service Management**: `enable_service`

## Adding New Modules

To add a new module:

1. Create a new script in `modules/` (e.g., `13-mymodule.sh`)
2. Use this template:

```bash
#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

main() {
    log_section "My Module Name"
    
    # Your installation logic here
    
    if [ success ]; then
        log_success "Module completed"
        return 0
    else
        log_error "Module failed"
        return 1
    fi
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    check_arch || exit 1
    check_sudo || exit 1
    main
    exit $?
fi
```

3. Add to `MODULES` array in `install.sh`:
```bash
"130:13-mymodule.sh:My Module Description:false"
```

4. Make it executable:
```bash
chmod +x modules/13-mymodule.sh
```

## Migration from Old Scripts

The old monolithic scripts are preserved for reference:
- `install_arch_desktop.sh` - Old desktop installer
- `install_arch_services.sh` - Old services installer
- `install_yay.sh` - Standalone yay installer

The `setup.sh` script acts as a compatibility wrapper and redirects to the new system.

## Troubleshooting

### Module Failed

If a module fails, you can:

1. Check the error message in the summary
2. Run the module individually with verbose output:
   ```bash
   cd modules/
   ./XX-modulename.sh
   ```
3. Fix the issue and re-run just that module

### Continue After Failure

The installation continues after optional module failures. Only required modules will stop the installation.

### Retry Failed Modules

After installation, you can retry specific failed modules:
```bash
cd /path/to/.dotfiles/os-setup/arch/modules
./failed-module.sh
```

## Benefits of Modular System

1. **Maintainability**: Easy to update individual components
2. **Testability**: Each module can be tested independently
3. **Flexibility**: Run only what you need
4. **Debuggability**: Failures are isolated and easier to fix
5. **Reusability**: Modules can be used in different contexts
6. **Error Handling**: Comprehensive error reporting at each step

## Future Enhancements

Potential improvements:
- Interactive mode with module selection
- Configuration file for customizing module options
- Progress indicators for long-running operations
- Dry-run mode to preview changes
- Logging to file for debugging
- Module dependencies and ordering validation
