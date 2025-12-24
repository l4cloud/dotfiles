# Minimal Arch Linux Setup with Pipewire

This guide explains how to use the installation scripts on a minimal Arch Linux system with Pipewire audio.

## Prerequisites

The scripts assume:
- Fresh Arch Linux installation
- Network connectivity (for downloading packages)
- Pipewire audio system (already configured as default)
- `sudo` configured for passwordless or password-authenticated use

## Minimum System Requirements

- **RAM**: 4GB minimum (8GB recommended for desktop environment)
- **Storage**: 20GB minimum (30GB+ recommended)
- **CPU**: Any modern processor
- **Network**: Active internet connection

## Installation Steps

### 1. Desktop Environment Setup

Run the desktop environment installation script:

```bash
./os-setup/arch/install_arch_desktop.sh
```

This will:
- Check for Arch Linux system
- Verify internet connectivity
- Install Hyprland desktop environment
- Install pipewire and related audio packages
- Configure NVIDIA drivers (if detected)
- Install essential applications and utilities
- Install Hack Nerd Font
- Set up power profile management

**Duration**: 20-40 minutes depending on system and internet speed

### 2. Development Environment Setup

Run the services/development setup script:

```bash
./os-setup/arch/install_arch_services.sh
```

This will:
- Install development tools
- Install AUR helper (yay) using a dedicated installer script
- Install language version managers (pyenv, nvm)
- Install development utilities (lazygit, yazi, etc.)
- Install opencode and other CLI tools
- Set Zsh as default shell

**Duration**: 15-30 minutes

#### About yay Installation

The setup uses a dedicated yay installer script (`install_yay.sh`) that:
- Checks for required dependencies (git, make, gcc)
- Clones the yay repository cleanly
- Builds and installs yay with clear error messages
- Automatically installs base-devel if needed
- Gracefully continues if yay installation fails

If yay installation fails, you can install it manually:

```bash
./os-setup/arch/install_yay.sh
```

## Pipewire Audio Configuration

The installation scripts automatically:
1. Install pipewire, pipewire-pulse, and pipewire-alsa
2. Install pipewire-jack and wireplumber for advanced routing
3. Enable and start pipewire systemd user service
4. Enable and start wireplumber systemd user service

### Verify Pipewire Installation

```bash
# Check if pipewire is running
systemctl --user status pipewire

# Check audio devices
pactl list short devices

# Test audio with pulsemixer
pulsemixer
```

## Minimal Setup Mode

If you encounter issues on a very minimal system, you can manually install core packages:

```bash
# Install desktop environment
sudo pacman -S hyprland kitty hypridle waybar swww swaync

# Install pipewire
sudo pacman -S pipewire pipewire-pulse pipewire-alsa pipewire-jack wireplumber

# Install development tools
sudo pacman -S git neovim zsh tmux base-devel
```

## Troubleshooting

### Pipewire Not Working

```bash
# Restart pipewire service
systemctl --user restart pipewire wireplumber

# Check logs
journalctl --user -u pipewire -n 20
journalctl --user -u wireplumber -n 20
```

### AUR Helper Installation Failed

The scripts use a dedicated yay installer script that gracefully handles failures. If yay installation fails:

1. The setup continues with pacman packages only
2. You'll see a warning message in the output
3. You can install yay manually anytime with:

```bash
./os-setup/arch/install_yay.sh
```

The standalone installer:
- Automatically installs base-devel if needed
- Provides clear error messages
- Verifies installation success
- Cleans up after itself

If even the standalone installer fails, check:

```bash
# Verify base-devel is installed
pacman -Qs base-devel

# Manually install if needed
sudo pacman -S base-devel

# Check git is available
which git
```

### Internet Connectivity Issues

- The scripts check for internet before starting
- If you lose internet during installation, restart the script
- It will continue from where it left off (most packages)

### Package Manager Locks

If `pacman` is locked:

```bash
# Wait for any background updates to complete
sudo lsof /var/lib/pacman/db.lck

# Or remove the lock file (only if no pacman is running)
sudo rm /var/lib/pacman/db.lck

# Or reboot
sudo reboot
```

## Verification

After installation, verify everything is working:

```bash
# Check desktop environment
hyprctl version

# Check audio
pactl info

# Check development tools
git --version
nvim --version
zsh --version

# Check power profiles
powerprofilesctl list
```

## Post-Installation

### SSH Setup

```bash
# Generate SSH key for GitHub
ssh-keygen -t ed25519 -C "your_email@example.com"

# Add to GitHub: ~/.ssh/id_ed25519.pub
```

### Dotfiles Installation

```bash
# If not already cloned, clone your dotfiles repository
git clone https://github.com/your-username/your-dotfiles.git ~/.dotfiles

# Install with stow
cd ~/.dotfiles
stow .
```

### First Boot Hyprland

After reboot, SDDM display manager will start. Select Hyprland from the session dropdown.

Default keybinds:
- `ALT + T`: Open terminal
- `SUPER + E`: File manager
- `SUPER + M`: Logout menu

## Additional Notes

- The scripts are idempotent - you can run them multiple times safely
- All scripts provide detailed error tracking and reporting
- Internet connection is required for initial setup
- NVIDIA GPU detection is automatic
- Power profile management is configured automatically

## Support

If you encounter issues:
1. Check script output for specific error messages
2. Review the detailed error summary at the end of the script
3. Try manual installation steps from troubleshooting section
4. Check GitHub issues for similar problems
