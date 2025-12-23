# Migration Guide: Ansible to Pure Bash Scripts

This document explains the changes made to the dotfiles installation system and how to migrate from the old Ansible-based setup to the new pure Bash implementation.

## What Changed

### Before (Ansible-based)
```bash
cd ~/.dotfiles/os-setup/arch
ansible-playbook arch_services.yml
ansible-playbook arch_desktop_setup.yml
```

### After (Pure Bash)
```bash
cd ~/.dotfiles/os-setup
./install.sh --desktop
```

## Key Improvements

### 1. **Removed Ansible Dependency**
- **Before**: Required Ansible installation and playbook files
- **After**: Pure Bash scripts - no external dependencies beyond standard Linux tools

**Benefit**: Faster execution, simpler setup, easier to audit and modify

### 2. **Unified Entry Point**
- **Before**: Different setup processes for Arch, Fedora, and Ubuntu
- **After**: Single `install.sh` script with OS auto-detection

**Benefit**: Consistent interface across all distributions

### 3. **Enhanced Config Management with Stow**
- **Before**: Config files in `desktop-setup/` duplicated from actual location
- **After**: Single source of truth in `.config/`, managed by GNU Stow

**Benefit**: No duplication, easier to maintain, true version control

### 4. **Flexible Installation Options**
- **Before**: Run each playbook separately
- **After**: Command-line flags for granular control

**Benefit**: Faster installs for specific needs

```bash
./install.sh                    # Services only
./install.sh --desktop          # Services + Desktop
./install.sh --desktop --nvidia # Services + Desktop + NVIDIA
```

### 5. **NVIDIA Support**
- **Before**: Manual NVIDIA setup required
- **After**: Automatic GPU detection and configuration

**Benefit**: Seamless Wayland/Hyprland experience on NVIDIA systems

## Migration Steps

### Step 1: Update Your Dotfiles Repository
```bash
cd ~/.dotfiles
git pull origin main
```

### Step 2: (Optional) Clean Old Setup Files
The following files are deprecated but still available for reference:
```bash
rm -rf ~/.dotfiles/os-setup/arch/*.yml
rm -rf ~/.dotfiles/os-setup/fedora/*.yml
rm -rf ~/.dotfiles/os-setup/ubuntu/*.yml
rm -rf ~/.dotfiles/.misc/
```

**Note**: These are optional to remove. The new scripts don't use them.

### Step 3: Use New Installation Commands

#### On Arch Linux
```bash
cd ~/.dotfiles/os-setup
./install.sh --desktop --nvidia  # with NVIDIA support
./install.sh --desktop           # without NVIDIA
./install.sh                      # services only
```

#### On Fedora
```bash
cd ~/.dotfiles/os-setup
./install.sh --desktop --nvidia
./install.sh --desktop
./install.sh
```

#### On Ubuntu
```bash
cd ~/.dotfiles/os-setup
./install.sh --desktop --nvidia  # Ubuntu now supports desktop!
./install.sh --desktop
./install.sh
```

### Step 4: Verify Installation

After running the new installer, verify everything works:

```bash
# Check symlinks are in place
ls -l ~/.config/hypr
ls -l ~/.config/waybar

# Verify key tools are installed
hyprctl --version
nvim --version
lazygit --version

# Test Hyprland (if installed desktop)
# Restart your session to use Hyprland
```

## Configuration File Changes

### Old Structure
```
~/.dotfiles/
├── desktop-setup/
│   ├── hypr/
│   ├── waybar/
│   ├── wofi/
│   └── swaync/
└── .config/  (actual configs)
    └── (duplicate configs)
```

**Problem**: Configs existed in two places, causing confusion and sync issues.

### New Structure
```
~/.dotfiles/
├── .config/  (PRIMARY SOURCE - tracked in git)
│   ├── hypr/
│   ├── waybar/
│   ├── wofi/
│   ├── swaync/
│   ├── nvim/
│   └── ... other configs
└── wallpapers/
    └── Wallpapers/
```

**Benefit**: Single source of truth, easier maintenance, true version control.

## How Stow Works Now

During `./install.sh --desktop`:

1. **Stow is installed** if not present
2. **For each config directory** in `~/.dotfiles/.config/`:
   - `stow -R <package>` creates/updates symlinks from `~/.dotfiles/.config/<package>` to `~/.config/<package>/`
3. **Wallpapers** are symlinked to `~/Wallpapers/`

### Example: Hyprland Config
```
~/.dotfiles/.config/hypr/hyprland.conf
        ↓ (stow creates symlink)
~/.config/hypr/hyprland.conf → ../../.dotfiles/.config/hypr/hyprland.conf
```

### Updating Configs
Simply edit files in `~/.config/` - they're actually symlinks to `~/.dotfiles/.config/`, so changes are tracked by git:

```bash
nano ~/.config/hypr/hyprland.conf  # Edit the symlink
cd ~/.dotfiles
git status                         # See the changes
git add .
git commit -m "Update Hyprland config"
```

## Troubleshooting Migration

### Issue: Symlink conflicts
If you see errors about existing files, resolve conflicts:
```bash
cd ~/.dotfiles
stow -R .config  # Replace all conflicting symlinks
```

### Issue: Old Ansible still installed
Remove Ansible if no longer needed:
```bash
# Arch
sudo pacman -R ansible

# Fedora
sudo dnf remove ansible

# Ubuntu
sudo apt remove ansible
```

### Issue: Want to keep Ansible playbooks
The old playbooks are still available in `.misc/` for reference. No action needed.

### Issue: NVIDIA drivers not working
Ensure you:
1. Have an NVIDIA GPU
2. Used the `--nvidia` flag
3. Restarted your system after installation

## Script Structure Changes

### Old Ansible Flow
```
ansible-playbook arch_services.yml
  → installs packages
  → configures services

ansible-playbook arch_desktop_setup.yml
  → installs more packages
  → copies configs (duplicating them)
```

### New Bash Flow
```
./install.sh [--desktop] [--nvidia]
  → detects OS
  → calls os-setup/arch/install_arch_services.sh
  → calls os-setup/arch/install_arch_desktop.sh (if --desktop)
  → calls NVIDIA setup (if --nvidia)
  → runs stow to symlink configs
  → verifies installation
```

## Rollback (If Needed)

To revert to Ansible setup:

```bash
# Uninstall stow-managed configs
cd ~/.dotfiles
stow -D .config
stow -D wallpapers

# Remove symlinks
rm -f ~/.config/* ~/Wallpapers

# Restore from Ansible
cd ~/.dotfiles
ansible-playbook os-setup/arch/arch_services.yml
# ... (run other playbooks as needed)
```

## File Locations Reference

| File | Purpose |
|------|---------|
| `os-setup/install.sh` | Main entry point |
| `os-setup/arch/install_arch_services.sh` | Arch services |
| `os-setup/arch/install_arch_desktop.sh` | Arch desktop |
| `os-setup/fedora/install_fedora_services.sh` | Fedora services |
| `os-setup/fedora/install_fedora_desktop.sh` | Fedora desktop |
| `os-setup/ubuntu/install_ubuntu_services.sh` | Ubuntu services |
| `os-setup/ubuntu/install_ubuntu_desktop.sh` | Ubuntu desktop |
| `.config/` | Configuration files (source of truth) |
| `wallpapers/` | Wallpaper collection |
| `.misc/` | Deprecated (old files for reference) |
| `os-setup/arch/*.yml` | Deprecated (old Ansible playbooks) |

## Next Steps

1. **Backup your current setup**: `git commit -am "Backup before migration"`
2. **Run new installer**: `cd ~/.dotfiles/os-setup && ./install.sh --desktop`
3. **Test everything**: Verify apps, configs, desktop environment
4. **Clean up** (optional): Remove deprecated files
5. **Sync to other machines**: Use git to pull these changes on other systems

## Questions or Issues?

- Check the main [README.md](README.md)
- Review the installer help: `./install.sh --help`
- Examine specific install scripts in `os-setup/`
- Report issues at: https://github.com/l4cloud/dotfiles

## Summary

| Aspect | Ansible | Bash Scripts |
|--------|---------|--------------|
| Entry Point | Multiple playbooks | Single `install.sh` |
| Dependency | Ansible required | None (pure Bash) |
| OS Support | 3 (Arch, Fedora) | 3+ (includes Ubuntu) |
| Desktop | Manual setup | Automated |
| NVIDIA | Manual | Automatic detection |
| Config Mgmt | Files duplicated | Stow symlinks |
| Speed | Slower | Faster |
| Auditability | Ansible syntax | Bash script |

**Migration Time**: Usually 5-15 minutes depending on internet speed and system specs.
