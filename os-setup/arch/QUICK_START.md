# Complete Arch Setup - Simplified

## Overview

The setup is now **much simpler** - just one script:

```bash
./os-setup/arch/setup.sh
```

This single script installs everything:
- ✓ Desktop environment (Hyprland + all components)
- ✓ Pipewire audio
- ✓ Development tools
- ✓ Language managers (pyenv, nvm)
- ✓ Optional tools (lazygit, Obsidian, fonts)
- ✓ Sets Zsh as default shell

## What Changed

### Old Approach (Complex)
- Multiple shell scripts calling Ansible playbooks
- Complicated conditional logic
- Hard to debug when things fail
- Many interdependent tasks

### New Approach (Simple)
- Single `setup.sh` script
- Direct shell commands
- Clear error messages
- Graceful handling of optional components
- Takes ~30-45 minutes total

## What Gets Installed

| Category | Packages |
|----------|----------|
| **Desktop** | hyprland, kitty, waybar, swaync, wofi, thunar, wlogout |
| **Audio** | pipewire, pipewire-pulse, pipewire-alsa, pipewire-jack, wireplumber |
| **Tools** | git, neovim, zsh, tmux, curl, wget, jq, htop, fastfetch |
| **Build** | base-devel, gcc, make, patch, unzip |
| **Languages** | go, python, node (via pyenv/nvm) |
| **Utilities** | yazi, fd, ripgrep, fzf, zoxide, imagemagick, xclip, docker |
| **Optional** | lazygit (AUR), Obsidian (Flatpak), pulsemixer, opencode, getnf |

## Usage

### Quick Install
```bash
cd ~/.dotfiles
./os-setup/arch/setup.sh
```

### If Script Fails
The script gracefully handles failures. Optional components (AUR, Flatpak) will skip if they fail, but the core system will still install.

### Manual Install (if needed)
See README.md for manual package installation commands.

## Verification

After setup completes, you'll see a summary like:
```
✓ Hyprland installed
✓ Zsh installed  
✓ Pipewire working
✓ yay installed (optional)
✓ lazygit installed (optional)
```

## Next Steps

1. Reboot: `sudo reboot`
2. Hyprland will start automatically
3. Deploy dotfiles: `cd ~/.dotfiles && stow -v -t ~ .config`
4. Set up SSH for GitHub

## Additional Scripts

The following scripts are also available for more granular control:
- `install_arch_desktop.sh` - Desktop environment only (with advanced NVIDIA detection)
- `install_arch_services.sh` - Development tools only (CLI without desktop)
- `install_yay.sh` - Standalone yay installer

All scripts are pure shell scripts with no external dependencies.

## Troubleshooting

See README.md for common issues and solutions.
