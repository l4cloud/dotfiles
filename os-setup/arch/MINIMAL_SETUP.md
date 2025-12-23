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
- Install Ansible
- Install Hyprland desktop environment
- Install pipewire and related audio packages
- Configure NVIDIA drivers (if detected)
- Install essential applications and utilities
- Install Hack Nerd Font

**Duration**: 20-40 minutes depending on system and internet speed

### 2. Development Environment Setup

Run the services/development setup script:

```bash
./os-setup/arch/install_arch_services.sh
```

This will:
- Install development tools
- Install AUR helper (yay) with graceful fallback
- Install language version managers (pyenv, nvm)
- Install development utilities (lazygit, yazi, etc.)
- Install opencode and other CLI tools
- Set Zsh as default shell

**Duration**: 15-30 minutes

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

If you encounter issues on a very minimal system:

### Option 1: Skip Optional Components

Run playbooks with specific tags to skip non-essential packages:

```bash
# Desktop setup without flatpak/obsidian
ansible-playbook os-setup/arch/arch_desktop_setup.yml --skip-tags flatpak

# Services setup without AUR packages
ansible-playbook os-setup/arch/arch_services.yml --skip-tags aur,fonts
```

### Option 2: Manual Package Installation

If automation fails, install packages manually:

```bash
# Install desktop environment
sudo pacman -S hyprland kitty hypridle waybar swww swaync

# Install pipewire
sudo pacman -S pipewire pipewire-pulse pipewire-alsa pipewire-jack wireplumber

# Install development tools
sudo pacman -S git neovim zsh tmux base-devel
```

## Troubleshooting

### Ansible Not Installing

```bash
# Manually install Ansible
sudo pacman -Sy
sudo pacman -S ansible
```

### Pipewire Not Working

```bash
# Restart pipewire service
systemctl --user restart pipewire wireplumber

# Check logs
journalctl --user -u pipewire -n 20
journalctl --user -u wireplumber -n 20
```

### AUR Helper Installation Failed

The scripts gracefully handle AUR helper failures. If yay installation fails:
1. The setup continues with pacman packages only (no AUR packages)
2. You'll see a WARNING message in the output
3. You can install yay manually later if needed

To install yay manually:

```bash
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
```

Common yay installation issues:
- **gcc/make not installed**: Run `sudo pacman -S base-devel` first
- **No internet**: Ensure network connectivity
- **Permission denied**: Check sudo configuration
- **Existing build directory**: The script cleans this automatically

### Internet Connectivity Issues

- The scripts check for internet before starting
- If you lose internet during installation, restart the script
- It will continue from where it left off

### Package Manager Locks

If `pacman` is locked:

```bash
# Wait for any background updates to complete
sudo lsof /var/lib/pacman/db.lck

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
# Clone your dotfiles repository
git clone https://github.com/your-username/your-dotfiles.git ~/.dotfiles

# Install with stow
cd ~/.dotfiles
stow -v -t ~ .config
```

### First Boot Hyprland

After reboot, Hyprland will start. Default keybinds:
- `SUPER + Q`: Open terminal
- `SUPER + E`: File manager
- `SUPER + ALT + Q`: Quit Hyprland
- `SUPER + M`: Logout

## Additional Notes

- The scripts are idempotent - you can run them multiple times safely
- Use tags to customize installation: `ansible-playbook ... --tags=zsh`
- Check logs for detailed error messages if something fails
- Internet connection is required for initial setup
- System will ask for password during installation (Ansible become)

## Support

If you encounter issues:
1. Check script output for specific error messages
2. Review Ansible logs
3. Try manual installation steps from troubleshooting section
4. Check GitHub issues for similar problems
