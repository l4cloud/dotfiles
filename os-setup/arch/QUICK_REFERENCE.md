# Arch Linux Installation - Quick Reference

## Quick Start

```bash
cd ~/.dotfiles/os-setup/arch

# Full installation (everything)
./install.sh

# Desktop only (no optional tools)
./install.sh --desktop

# Minimal (no desktop environment)
./install.sh --minimal

# Force NVIDIA installation
./install.sh --desktop --nvidia
```

## What Gets Installed

### Minimal Mode
- System updates
- Core packages (git, neovim, zsh, docker, etc.)
- AUR helper (yay)

### Desktop Mode
Minimal + 
- Hyprland desktop environment
- Kitty terminal, Waybar, etc.
- Pipewire audio
- Bluetooth
- Display manager (SDDM)
- System services
- Fonts (Hack Nerd Font)
- Dev tools (pyenv, nvm, opencode)
- AUR packages (lazygit)
- Flatpak apps (Obsidian, Zen Browser)
- Dotfiles via Stow
- NVIDIA drivers (auto-detected, or use --nvidia to force)

### Full Mode
Same as Desktop mode (Desktop now includes everything)

## NVIDIA Support

NVIDIA drivers are automatically detected and installed in desktop/full modes.

To force NVIDIA installation (even if not detected):
```bash
./install.sh --desktop --nvidia
```

Note: --nvidia flag requires --desktop or --full mode.

## Module Structure

```
modules/
├── common.sh              # Shared utilities
├── 01-system-update.sh    # System update
├── 02-core-packages.sh    # Development tools
├── 03-desktop-packages.sh # Hyprland + desktop
├── 04-yay.sh              # AUR helper
├── 05-aur-packages.sh     # AUR packages
├── 06-services.sh         # System services
├── 07-fonts.sh            # Font installation
├── 08-devtools.sh         # pyenv, nvm, etc.
├── 09-nvidia.sh           # NVIDIA configuration
├── 11-flatpak.sh          # Flatpak apps
└── 12-dotfiles.sh         # Dotfiles (stow)
```

## Running Individual Modules

```bash
cd modules/

# Run specific module
./06-services.sh

# Configure NVIDIA
./09-nvidia.sh

# Install dotfiles only
./12-dotfiles.sh
```

## Error Handling

The installation continues even if optional modules fail. You'll get a summary:

```
[SUCCESS] Successfully Completed (10):
  ✓ System Update
  ✓ Core Development Packages
  ...

[WARN] Failed Modules (1):
  ✗ NVIDIA Configuration
  
[ERROR] Detailed Errors:
  09-nvidia.sh: No NVIDIA GPU detected
```

## Retry Failed Modules

```bash
cd modules/
./failed-module-name.sh
```

## Benefits

- **Modular**: Each script does one job
- **Independent**: Run modules individually
- **Error Isolation**: Failures don't break everything
- **Comprehensive Logging**: Know exactly what failed and why
- **Flexible**: Choose what to install

## Migration Note

Old scripts are preserved but deprecated:
- `install_arch_desktop.sh` → Use `./install.sh --desktop`
- `install_arch_services.sh` → Use `./install.sh --minimal`
- `setup.sh` → Now redirects to new system

## Documentation

- `MODULES.md` - Complete module documentation
- `README.md` - Original documentation
- `QUICK_START.md` - Quick start guide
