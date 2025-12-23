# Arch Linux Complete Setup Guide

## One-Command Setup

```bash
cd ~/.dotfiles
./os-setup/arch/setup.sh
```

That's it. Everything else happens automatically.

---

## What This Script Does

The `setup.sh` script is a single, straightforward bash script that:

1. **Verifies** you're running Arch Linux
2. **Updates** all system packages
3. **Installs** all required packages in one go (~150 packages)
4. **Configures** Pipewire audio system
5. **Builds** yay from source (AUR helper)
6. **Installs** optional extras (lazygit, Obsidian, fonts)
7. **Sets up** language managers (pyenv, nvm)
8. **Installs** CLI tools (opencode, pulsemixer, getnf)
9. **Sets** Zsh as default shell
10. **Verifies** everything works

**Total time: 30-45 minutes**

---

## Complete Package List

### Core Desktop (25 packages)
- hyprland, kitty, hypridle, waybar, swww, swaync
- brightnessctl, playerctl, grim, slurp, hyprshot
- hyprlock, wlogout, thunar, wofi, flatpak

### Audio (5 packages)
- pipewire, pipewire-pulse, pipewire-alsa, pipewire-jack, wireplumber

### Development (15+ packages)
- base-devel, git, gcc, make, patch, unzip
- neovim, zsh, tmux, curl, wget
- jq, go, docker, stow, python-pip

### Build Dependencies (10+ packages)
- zlib, bzip2, readline, sqlite, openssl, tk, libffi, xz, ncurses

### Utilities (10+ packages)
- yazi, p7zip, poppler, fd, ripgrep, fzf, zoxide
- imagemagick, xclip, htop, fastfetch

### Optional (installed if available)
- lazygit (AUR) - Git TUI
- Obsidian (Flatpak) - Note taking
- pulsemixer - Audio control CLI
- opencode - Development CLI tool
- getnf - Font installer

---

## Requirements

- **OS**: Arch Linux (checked by script)
- **Disk**: 20GB+ free space
- **RAM**: 4GB minimum (8GB recommended)
- **Internet**: Required (checked by script)
- **Sudo**: Must have sudo access
- **Time**: 30-45 minutes

---

## Quick Reference

### If You Need to Install Just Core Packages
The script will install these first, so even if optional parts fail, you'll have a working system.

### If Internet Fails Mid-Way
Run the script again. It's mostly idempotent:
- Already installed packages are skipped
- Failed packages will retry
- You can run it multiple times safely

### If You Want Only the Desktop (No Dev Tools)
Modify the script to remove the dev language sections.

---

## What You Get After Setup

### Immediately After Running Script
```
✓ Hyprland installed and ready
✓ Zsh installed (new default shell)
✓ Pipewire audio configured
✓ yay installed (can use AUR)
✓ Development tools ready
✓ All utilities installed
```

### After First Reboot
- Hyprland boots automatically
- Pipewire audio is active
- All packages are available
- Ready to use the system

### After Deploying Dotfiles
```bash
cd ~/.dotfiles
stow -v -t ~ .config
```
- Terminal configured (kitty)
- Keybinds in place
- Theme/colors applied
- All tools configured

---

## Step-by-Step Walkthrough

### Before You Start
```bash
# Make sure you have internet
ping 8.8.8.8

# Navigate to dotfiles
cd ~/.dotfiles

# Verify script exists
ls -l os-setup/arch/setup.sh
```

### During Installation
The script shows progress with colored output:
- `[STEP]` - Major steps (blue)
- `[INFO]` - Additional info (green)
- `[WARN]` - Non-critical warnings (yellow)
- `[ERROR]` - Actual errors (red)

**Do NOT interrupt the script.** If it stops, just run it again.

### Verification Phase
At the end, you'll see something like:
```
[INFO] Verifying installation...
[INFO] ✓ Hyprland installed
[INFO] ✓ Zsh installed
[INFO] ✓ Pipewire working
[INFO] ✓ yay installed
[INFO] ✓ lazygit installed
[INFO] Setup complete!
```

---

## Troubleshooting

### Script Won't Run
```bash
# Make sure it's executable
chmod +x os-setup/arch/setup.sh

# Run with bash explicitly
bash os-setup/arch/setup.sh
```

### Pacman Errors
```bash
# Update mirrors
sudo pacman -Syy

# If locked, wait or reboot
sudo lsof /var/lib/pacman/db.lck
```

### Packages Fail to Install
```bash
# Check your internet
ping 8.8.8.8

# Try the problematic package manually
sudo pacman -S <package-name>

# Continue script afterwards
bash os-setup/arch/setup.sh
```

### yay Installation Fails
- Script will continue with just pacman
- You can install yay manually later with:
  ```bash
  git clone https://aur.archlinux.org/yay.git
  cd yay
  makepkg -si --noconfirm
  ```

### Hyprland Won't Start After Reboot
```bash
# Check if it's installed
hyprctl version

# Start manually
Hyprland

# Check logs
journalctl -xe | grep hyprland
```

### Pipewire Not Working
```bash
# Restart service
systemctl --user restart pipewire wireplumber

# Check status
systemctl --user status pipewire

# List devices
pactl list short devices

# Test with pulsemixer
pulsemixer
```

### Zsh Not Set as Default
```bash
# Verify which shell
echo $SHELL

# Change if needed
chsh -s /bin/zsh
```

---

## What Happens Next

### First Boot
1. System reboots
2. Hyprland starts
3. You see the desktop
4. Terminal is SUPER + Q

### Setup Your Dotfiles
```bash
cd ~/.dotfiles
stow -v -t ~ .config
```

### Configure Git
```bash
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
```

### Generate SSH Key
```bash
ssh-keygen -t ed25519 -C "your@email.com"
cat ~/.ssh/id_ed25519.pub  # Add to GitHub
```

### Install Additional Languages
```bash
# Python versions
pyenv install 3.12
pyenv global 3.12

# Node versions
nvm install 20
nvm use 20
```

---

## Advanced: Customizing the Script

If you need different packages, edit `setup.sh`:

```bash
# Find this section:
sudo pacman -S --noconfirm \
    base-devel git curl wget \
    # ... add or remove packages here

# Then run:
bash setup.sh
```

Common additions:
- `postgresql` - Database
- `redis` - Cache
- `nginx` - Web server
- `nodejs` - If not using nvm
- `rust` - Rust programming language

---

## File Reference

In `os-setup/arch/`:
- `setup.sh` - Main installation script (use this)
- `README.md` - Full documentation
- `QUICK_START.md` - Quick overview
- `NVIDIA_README.md` - NVIDIA GPU setup
- `install_yay.sh` - Standalone yay installer (optional)

---

## Got Issues?

1. **Read the troubleshooting section above**
2. **Check if packages are installed**: `pacman -Q <package>`
3. **Try manual installation**: `sudo pacman -S <package>`
4. **Check internet**: `ping 8.8.8.8`
5. **Rerun the script**: Most issues resolve on second run

---

## Summary

This is a **single script setup**. No Ansible, no playbooks, no complex logic.

Just run it once:
```bash
./os-setup/arch/setup.sh
```

Everything installs. If something fails, run it again. That's the whole design.

Simple. Reliable. Done.
