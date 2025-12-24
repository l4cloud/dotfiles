#!/bin/bash

##############################################################################
# Ubuntu Hyprland Desktop Setup Script
# Sets up Hyprland desktop environment and related tools
# Uses stow to manage dotfile configs
##############################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging functions
log_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_step() { echo -e "${BLUE}[STEP]${NC} $1"; }

# Verify running on Ubuntu
if [ ! -f /etc/os-release ]; then
    log_error "Cannot determine OS"
    exit 1
fi

. /etc/os-release
if [ "$ID" != "ubuntu" ]; then
    log_error "This script requires Ubuntu"
    exit 1
fi

# Warn about non-22.04 versions but allow them
if [ "$VERSION_ID" != "22.04" ]; then
    log_warn "This script is optimized for Ubuntu 22.04"
    log_warn "Detected: $PRETTY_NAME"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Exiting..."
        exit 0
    fi
fi

log_info "Starting Ubuntu Hyprland desktop setup..."
log_info "Detected: $PRETTY_NAME"

# Check for internet connectivity
if ! ping -c 1 8.8.8.8 &> /dev/null; then
    log_warn "No internet connectivity detected. Some features may fail."
    log_warn "Please ensure you have internet access before continuing."
fi

# Update system
log_step "Updating system packages..."
sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y

# Install Hyprland and desktop packages
log_step "Installing Hyprland desktop environment..."
sudo apt install -y \
    hyprland kitty hypridle waybar swww swaync \
    pipewire pipewire-pulse pipewire-alsa pipewire-jack wireplumber \
    brightnessctl playerctl grim slurp hyprshot hyprlock wlogout \
    thunar wofi flatpak blueman \
    git curl wget \
    neovim zsh tmux htop fastfetch \
    jq gcc g++ make patch unzip \
    zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev libssl-dev \
    libffi-dev liblzma-dev python3-dev python3-pip \
    stow ffmpeg p7zip-full poppler-utils fd-find ripgrep fzf zoxide imagemagick xclip \
    build-essential 2>/dev/null || log_warn "Some Hyprland packages may not be available in this Ubuntu version"

# Install and setup greeter (SDDM) for login manager
log_step "Installing SDDM (greeter) for display manager..."
sudo apt install -y sddm sddm-kcm 2>/dev/null || log_warn "SDDM may not be available in this Ubuntu version"

# Enable SDDM login manager
log_step "Configuring SDDM as display manager..."
sudo systemctl set-default graphical.target 2>/dev/null || true
if command -v sddm >/dev/null; then
    sudo systemctl enable sddm
    log_info "SDDM display manager enabled"
else
    log_warn "SDDM not available - using default display manager"
fi

# Install Hack Nerd Font
log_step "Installing Hack Nerd Font..."
if ! fc-list | grep -q "Hack Nerd"; then
    mkdir -p /tmp/font-install
    cd /tmp/font-install
    wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Hack.zip
    sudo unzip -q Hack.zip -d /usr/share/fonts
    sudo fc-cache -fv
    cd /
    rm -rf /tmp/font-install
    log_info "Hack Nerd Font installed"
else
    log_info "Hack Nerd Font already installed"
fi

# Setup Hyprland improvements
log_step "Configuring Hyprland optimizations..."

# Create/ensure XDG desktop portal config for Hyprland
mkdir -p "$HOME/.config/xdg-desktop-portal"
if [ ! -f "$HOME/.config/xdg-desktop-portal/hyprland-portals.conf" ]; then
    tee "$HOME/.config/xdg-desktop-portal/hyprland-portals.conf" > /dev/null <<EOF
[General]
backends=hyprland;gtk
EOF
    log_info "XDG desktop portal configured"
fi

# Ensure XDG Session Type environment variable is set for Hyprland
if ! grep -q "XDG_SESSION_TYPE=wayland" ~/.bashrc 2>/dev/null; then
    echo "export XDG_SESSION_TYPE=wayland" >> ~/.bashrc
fi
if ! grep -q "XDG_SESSION_TYPE=wayland" ~/.zshrc 2>/dev/null; then
    echo "export XDG_SESSION_TYPE=wayland" >> ~/.zshrc
fi

log_info "Hyprland environment variables configured"

# Setup pipewire
log_step "Setting up Pipewire audio..."
systemctl --user enable pipewire pipewire-pulse wireplumber 2>/dev/null || true
systemctl --user start pipewire pipewire-pulse wireplumber 2>/dev/null || true
log_info "Pipewire configured"

# Install pulsemixer for audio control
log_step "Installing pulsemixer..."
pip install --user pulsemixer 2>/dev/null || log_warn "pulsemixer installation skipped"

# Install flatpak apps
log_step "Setting up Flatpak applications..."
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo 2>/dev/null || true

log_step "Installing Obsidian via Flatpak..."
flatpak install -y flathub md.obsidian.Obsidian 2>/dev/null || log_warn "Obsidian installation skipped"

log_step "Installing Zen Browser via Flatpak..."
flatpak install -y flathub app.zen_browser.zen 2>/dev/null || log_warn "Zen browser installation skipped"

# Use stow to install dotfiles (configs)
log_step "Installing dotfile configs using stow..."
DOTFILES_DIR="$HOME/.dotfiles"

if [ ! -d "$DOTFILES_DIR" ]; then
    log_error "Dotfiles directory not found at $DOTFILES_DIR"
    exit 1
fi

# Change to dotfiles directory and run stow
cd "$DOTFILES_DIR"

# Stow configuration directories (.config, wallpapers, etc.)
# Remove any existing symlinks first to avoid conflicts
log_info "Installing dotfile configs (.config, wallpapers, etc.)..."
for package in .config wallpapers nvim starship.toml; do
    if [ -e "$package" ]; then
        stow -R "$package" 2>/dev/null || log_warn "stow $package had minor issues (this is often OK)"
    fi
done

cd - > /dev/null

# Final verification
log_info "Verifying installation..."
echo ""
command -v hyprctl >/dev/null && log_info "✓ Hyprland installed" || log_warn "✗ Hyprland may not be available on this Ubuntu version"
command -v kitty >/dev/null && log_info "✓ Kitty terminal installed" || log_warn "✗ Kitty not found"
command -v waybar >/dev/null && log_info "✓ Waybar installed" || log_warn "✗ Waybar not found"
command -v sddm >/dev/null && log_info "✓ SDDM (greeter) installed" || log_warn "✗ SDDM may not be available on this Ubuntu version"
pactl info >/dev/null 2>&1 && log_info "✓ Pipewire working" || log_warn "✗ Pipewire not responding"
fc-list | grep -q "Hack Nerd" && log_info "✓ Hack Nerd Font installed" || log_warn "✗ Hack Nerd Font not found"
[ -L "$HOME/.config/hypr" ] && log_info "✓ Hyprland configs linked via stow" || log_warn "✗ Hyprland configs not linked"
[ -f "$HOME/.config/xdg-desktop-portal/hyprland-portals.conf" ] && log_info "✓ XDG desktop portal configured" || log_warn "✗ XDG portal not configured"
command -v flatpak >/dev/null && log_info "✓ Flatpak installed" || log_warn "✗ Flatpak not found"

echo ""
log_info "Desktop environment setup complete!"
log_info "Next steps:"
log_info "  1. Restart your system: sudo reboot"
log_info "  2. SDDM will start automatically on login (if available)"
log_info "  3. Select Hyprland from the session menu (if available)"
log_info "  4. Default keybind: SUPER + Q to open terminal"
log_info "  5. All configs are managed by stow from ~/.dotfiles/"
echo ""
log_info "For more information on Hyprland keybinds:"
log_info "  • Check: ~/.dotfiles/.config/hypr/hyprland.conf"
log_info "  • Or in-session: Super + H (if configured)"
echo ""
log_warn "NOTE: Hyprland and SDDM may have limited availability on Ubuntu."
log_warn "If they're not available, consider using a Wayland-focused distro like Fedora or Arch."
echo ""
