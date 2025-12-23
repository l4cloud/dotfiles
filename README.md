# Dotfiles Installation System

A comprehensive dotfiles management system for Arch Linux, Fedora, and Ubuntu with support for development tools and the Hyprland desktop environment.

## Quick Start

```bash
# Clone the repository
git clone https://github.com/l4cloud/dotfiles.git ~/.dotfiles

# Install development tools only
cd ~/.dotfiles/os-setup && ./install.sh

# Install with desktop environment (Hyprland, Waybar, etc.)
./install.sh --desktop

# Install with desktop + NVIDIA GPU support
./install.sh --desktop --nvidia
```

## What Gets Installed

### Services (Always)
- **Development**: Git, Neovim, Zsh, Tmux, Docker
- **CLI Tools**: Lazygit, Yazi, Htop, Fastfetch
- **Version Managers**: Pyenv (Python), NVM (Node.js), Rust (Ubuntu only)
- **Utilities**: Opencode, Getnf, Pulsemixer

### Desktop Environment (with `--desktop`)
- **Window Manager**: Hyprland (Wayland compositor)
- **Display Manager**: SDDM (greeter with login screen)
- **Status Bar**: Waybar with multiple themes
- **Launcher**: Wofi
- **Notifications**: Swaync
- **Terminal**: Kitty
- **Utilities**: Brightctl, Playerctl, Grim/Slurp, Swww
- **Audio**: Pipewire + Wireplumber
- **Fonts**: Hack Nerd Font
- **Apps**: Flatpak, Obsidian, Zen Browser

### NVIDIA Support (with `--nvidia`)
- NVIDIA graphics drivers
- Kernel modules with DRM mode setting
- Wayland environment variables
- Regenerated initramfs

## Directory Structure

```
~/.dotfiles/
├── os-setup/                          # Installation scripts
│   ├── install.sh                     # Main entry point
│   ├── arch/install_arch_*.sh        # Arch-specific scripts
│   ├── fedora/install_fedora_*.sh    # Fedora-specific scripts
│   └── ubuntu/install_ubuntu_*.sh    # Ubuntu-specific scripts
│
├── .config/                           # Configuration files (tracked in git)
│   ├── hypr/                          Hyprland configs
│   ├── waybar/                        Waybar configs
│   ├── wofi/                          Wofi launcher
│   ├── swaync/                        Notification daemon
│   ├── kitty/                         Kitty terminal
│   ├── nvim/                          Neovim config
│   ├── lazygit/                       Lazygit config
│   └── ...other configs
│
├── wallpapers/                        # Wallpaper collection
│   └── Wallpapers/
│
└── ... other dotfiles
```

## Hyprland Window Manager

Hyprland is a modern Wayland compositor with a focus on performance and aesthetics. This installation includes:

### Features Configured
- **SDDM Display Manager**: Login screen with Hyprland session selection
- **Wayland Session**: Full Wayland environment for better security and performance
- **XDG Desktop Portal**: Integration with GTK and system dialogs
- **Pipewire Audio**: High-quality audio with full feature support
- **NVIDIA Support**: Automatic configuration for NVIDIA GPUs (with `--nvidia` flag)

### Key Configuration Files
- **Main Config**: `~/.config/hypr/hyprland.conf` - Window manager settings, keybinds, workspaces
- **Idle Config**: `~/.config/hypr/hypridle.conf` - Screen lock and idle behavior
- **Lock Screen**: `~/.config/hypr/hyprlock.conf` - Login lock screen appearance
- **Exit Menu**: Uses `wlogout` for power options

### Essential Keybinds
```
SUPER + Q           Open terminal (Kitty)
SUPER + C           Close window
SUPER + Space       Toggle floating
SUPER + 1-10        Switch workspaces
SUPER + Shift + 1-10 Move to workspace
SUPER + Right/Left  Move window focus
```

See `~/.config/hypr/hyprland.conf` for the complete keybind list and customization options.

### Post-Installation Steps
1. **Restart your system** to apply all changes
2. **Login with SDDM** - Select "Hyprland" from session menu
3. **Configure your keyboard layout** if needed - Edit `hyprland.conf`
4. **Customize colors** - Edit `hyprland.conf` and Waybar theme files
5. **Set wallpaper** - Use `swww` or edit the startup commands in `hyprland.conf`

### Troubleshooting Hyprland

**"Hyprland not starting"**
- Verify installation: `command -v hyprctl`
- Check SDDM is available: `command -v sddm`
- Ensure Wayland support on your GPU (most Intel/AMD support, NVIDIA needs drivers)

**"Keyboard not responding"**
- Edit `~/.config/hypr/hyprland.conf` and check:
  ```
  input {
      kb_layout = us  # Change to your layout
      kb_variant =
  }
  ```

**"Screen goes black / tearing**
- Disable vsync: Edit `hyprland.conf` and add `vsync = false` in decoration section
- For NVIDIA: Ensure `--nvidia` flag was used during installation

**"Audio not working"**
- Verify Pipewire: `systemctl --user status pipewire`
- Check ALSA devices: `pactl list devices short`
- Use pulsemixer to adjust levels: `pulsemixer`

**"Mouse lag or cursor invisible"**
- This is often NVIDIA-related, ensure `--nvidia` was used
- Or set in `hyprland.conf`: `cursor { hide_on_key_press = false }`

### Performance Tips
- Use `wl-mirrors` for better screen mirroring
- Enable adaptive sync in `hyprland.conf`: `monitor=,preferred,auto,auto,1`
- Disable animations if needed: `animations { enabled = false }`
- Monitor GPU usage: `nvidia-smi` or `radeontop` (AMD)

### Further Reading
- Hyprland Official Docs: https://hyprland.org
- Hyprland GitHub: https://github.com/hyprwm/Hyprland
- Waybar Themes: Included in `~/.config/waybar/themes/`

Configuration files are managed using **GNU Stow**. During desktop installation:

1. Stow symlinks `.config/` directories to `~/.config/`
2. Symlinks wallpapers to `~/Wallpapers/`
3. Creates symlinks for Neovim, starship, and other tools

This approach allows:
- Single source of truth in the dotfiles repo
- Easy version control and sync across machines
- Safe config management with stow's revert capabilities

## Supported Systems

| OS | Services | Desktop | NVIDIA |
|---|----------|---------|--------|
| Arch Linux | ✓ | ✓ | ✓ |
| Fedora | ✓ | ✓ | ✓ |
| Ubuntu 22.04+ | ✓ | ✓ | ✓ |

## Configuration Details

### NVIM
Based on Kickstart.nvim with custom plugins (Copilot, Neogen, etc.)

### Neofetch/Fastfetch
System information display utility configured with custom formatting

### Zsh
Custom aliases and shell configuration (see `.config/zshrc` if present)

### Waybar Themes
Multiple themes available: default, experimental, line, zen
- Switch themes via configuration symlinks
- Includes custom scripts for volume, brightness, etc.

## Troubleshooting

### Stow conflicts
If you see symlink conflicts during installation:
```bash
cd ~/.dotfiles && stow -R .config   # Re-stow with replacement
```

### NVIDIA drivers not detected
Ensure you have an NVIDIA GPU and use the `--nvidia` flag:
```bash
./install.sh --desktop --nvidia
```

### Missing symlinks
Verify symlinks are in place:
```bash
ls -l ~/.config/hypr  # Should show symlinked files
```

### SDDM (greeter) not starting
If the login screen doesn't appear:
```bash
# Check if SDDM is installed
command -v sddm

# Check SDDM is enabled
sudo systemctl status sddm

# Enable if not running
sudo systemctl enable sddm
sudo systemctl start sddm
```

### Display manager conflicts
If you have multiple display managers, set SDDM as default:
```bash
# Arch
sudo systemctl enable sddm
sudo systemctl disable gdm lightdm     # disable others

# Fedora/Ubuntu
sudo systemctl set-default graphical.target
sudo systemctl enable sddm
```

### Hyprland not available
Hyprland requires Wayland support. If not available:
- **Arch/Fedora**: Usually available in repos
- **Ubuntu**: May require external PPA or manual compilation
- Consider using Arch or Fedora for best Hyprland experience

## Development

To add new configuration files:
1. Place config in `~/.dotfiles/.config/<app>/`
2. Commit to git
3. On next install, stow will symlink it to `~/.config/<app>/`

To remove a package:
```bash
cd ~/.dotfiles && stow -D <package-name>
```

## Feedback

Report issues or suggestions at https://github.com/l4cloud/dotfiles
