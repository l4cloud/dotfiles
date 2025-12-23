# Arch Linux Setup

Complete setup script for Arch Linux with Hyprland, Pipewire, and development tools.

## Quick Start

```bash
cd ~/.dotfiles
./os-setup/arch/setup.sh
```

The script will:
1. Update all system packages
2. Install desktop environment (Hyprland with all components)
3. Configure Pipewire audio
4. Install development tools and languages
5. Install optional tools (AUR packages, Obsidian, fonts, etc.)
6. Set Zsh as default shell

## What Gets Installed

### Desktop Environment
- **Hyprland** - Modern tiling Wayland compositor
- **Kitty** - GPU-based terminal
- **Waybar** - Status bar
- **Swaync** - Notification daemon
- **Wofi** - Application launcher
- **Thunar** - File manager
- **Hypridle** - Idle daemon for lock/suspend

### Audio
- **Pipewire** - Modern audio system
- **Wireplumber** - Session/policy manager
- **pulsemixer** - Audio control CLI

### Development Tools
- **Git, curl, wget** - Version control and downloading
- **Neovim** - Text editor
- **Zsh, Tmux** - Shell and terminal multiplexer
- **GCC, Make, Patch** - Build tools
- **Go, Python, Node** - Language support via pyenv/nvm
- **Docker** - Containerization
- **Yazi** - File browser
- **lazygit** - Git TUI (via AUR if available)

### Utilities
- **htop, fastfetch** - System monitoring
- **fzf, ripgrep, fd** - Search and find utilities
- **Obsidian** - Note taking (Flatpak)
- **opencode** - CLI development tool
- **Hack Nerd Font** - Terminal font

## Requirements

- Fresh Arch Linux installation
- Internet connection
- `sudo` access
- 20GB+ disk space

## Troubleshooting

### Script fails to start
```bash
# Make sure you're in the dotfiles directory
cd ~/.dotfiles

# Make script executable
chmod +x os-setup/arch/setup.sh

# Run with bash explicitly
bash os-setup/arch/setup.sh
```

### Packages fail to install
- Check your pacman mirrors: `sudo pacman -Syy`
- Ensure internet connection: `ping 8.8.8.8`
- Try updating first: `sudo pacman -Syu --noconfirm`

### Hyprland not starting
- After reboot, try starting manually: `Hyprland`
- Check for display server issues: `echo $WAYLAND_DISPLAY`

### Pipewire audio not working
```bash
# Restart pipewire
systemctl --user restart pipewire wireplumber

# Check status
systemctl --user status pipewire

# Check devices
pactl list short devices
```

### yay not installing
The main packages will still install. You can manually install yay later:
```bash
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
```

## Manual Installation

If the script has issues, you can install packages manually:

```bash
# System update
sudo pacman -Syu --noconfirm

# Desktop environment
sudo pacman -S --noconfirm hyprland kitty waybar swaync

# Audio
sudo pacman -S --noconfirm pipewire pipewire-pulse pipewire-alsa wireplumber

# Development
sudo pacman -S --noconfirm git neovim zsh tmux base-devel

# Languages (via version managers)
git clone https://github.com/pyenv/pyenv.git ~/.pyenv
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# Set Zsh
sudo usermod -s /bin/zsh $USER
```

## Post-Setup

1. **Reboot** to start Hyprland: `sudo reboot`
2. **Configure dotfiles** with stow: `cd ~/.dotfiles && stow -v -t ~ .config`
3. **Set up SSH** for GitHub: `ssh-keygen -t ed25519`
4. **Install additional languages**: Use pyenv/nvm as needed

## Default Keybinds

Once Hyprland starts:
- `SUPER + Q` - Open terminal
- `SUPER + E` - File manager
- `SUPER + D` - Application launcher
- `SUPER + M` - Logout menu

See your `.config/hypr/hyprland.conf` for full keybind list.

## Support

Check the main dotfiles README for general setup issues.
