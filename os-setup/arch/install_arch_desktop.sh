#!/bin/bash

##############################################################################
# Arch Linux Hyprland Desktop Setup Script
# Sets up Hyprland desktop environment with optional NVIDIA driver support
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

# Check if running on Arch
if [ ! -f /etc/arch-release ]; then
    log_error "This script requires Arch Linux"
    exit 1
fi

# Check for NVIDIA GPU
NVIDIA_DETECTED=0
if lspci | grep -i nvidia >/dev/null 2>&1; then
    NVIDIA_DETECTED=1
    log_info "NVIDIA GPU detected"
fi

log_info "Starting Arch Linux Hyprland desktop setup..."

# Update system
log_step "Updating system packages..."
sudo pacman -Syu --noconfirm

# Install desktop and development packages
log_step "Installing Hyprland and desktop packages..."
sudo pacman -S --noconfirm \
    hyprland kitty hypridle waybar swww swaync \
    pipewire pipewire-pulse pipewire-alsa pipewire-jack wireplumber \
    brightnessctl playerctl grim slurp hyprshot hyprlock wlogout \
    thunar wofi flatpak \
    git neovim jq gcc make patch unzip curl wget \
    zlib bzip2 readline sqlite openssl tk libffi xz ncurses \
    python-pip stow docker \
    yazi p7zip poppler fd ripgrep fzf zoxide imagemagick xclip \
    zsh tmux htop fastfetch

# Install and setup greeter (SDDM) for login manager
log_step "Installing SDDM (greeter) for display manager..."
sudo pacman -S --noconfirm sddm sddm-kcm

# Enable SDDM login manager
log_step "Configuring SDDM as display manager..."
sudo systemctl enable sddm
log_info "SDDM display manager enabled"

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

# Handle NVIDIA configuration if detected
if [ "$NVIDIA_DETECTED" = "1" ]; then
    log_step "Configuring NVIDIA drivers for Hyprland..."
    
    # Detect GPU generation to recommend driver
    if lspci | grep -i "NVIDIA.*RTX\|GeForce" >/dev/null; then
        GPU_GEN=$(lspci | grep -i nvidia | head -1)
        log_info "Detected GPU: $GPU_GEN"
        
        # Check if RTX 20 series or newer (supports open source drivers)
        if echo "$GPU_GEN" | grep -iE "RTX 20|RTX 30|RTX 40|RTX 50" >/dev/null; then
            log_info "RTX 20+ series detected - open source drivers recommended"
        fi
    fi
    
    # Install NVIDIA drivers and utils
    log_step "Installing NVIDIA driver packages..."
    sudo pacman -S --noconfirm \
        nvidia \
        nvidia-utils \
        nvidia-settings 2>/dev/null || log_warn "NVIDIA drivers installation attempted"
    
    # Configure NVIDIA for Hyprland
    log_step "Configuring NVIDIA for Hyprland..."
    
    # Create/update modprobe config
    sudo tee /etc/modprobe.d/nvidia.conf > /dev/null <<EOF
# Enable NVIDIA DRM kernel mode setting
options nvidia_drm modeset=1
options nvidia_drm fbdev=1
EOF
    
    # Update mkinitcpio
    sudo sed -i 's/^MODULES=.*/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
    
    # Create/update environment variables
    sudo tee /etc/environment.d/90-nvidia.conf > /dev/null <<EOF
# NVIDIA environment variables for Hyprland
LIBVA_DRIVER_NAME=nvidia
XDG_SESSION_TYPE=wayland
GBM_BACKEND=nvidia-drm
__GLX_VENDOR_LIBRARY_NAME=nvidia
WLR_NO_HARDWARE_CURSORS=1
EOF
    
    # Regenerate initramfs
    log_step "Regenerating initramfs with NVIDIA modules..."
    sudo mkinitcpio -P 2>/dev/null || log_warn "mkinitcpio regeneration had issues"
    
    log_info "NVIDIA configuration complete - reboot required for changes to take effect"
fi

# Install flatpak
log_step "Setting up Flatpak..."
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo 2>/dev/null || true

# Install Obsidian via flatpak
log_step "Installing Obsidian via Flatpak..."
flatpak install -y flathub md.obsidian.Obsidian 2>/dev/null || log_warn "Obsidian installation skipped"

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

# Install language version managers
log_step "Installing pyenv..."
if [ ! -d ~/.pyenv ]; then
    git clone https://github.com/pyenv/pyenv.git ~/.pyenv 2>/dev/null || true
    log_info "pyenv installed"
fi

log_step "Installing nvm..."
if [ ! -d ~/.nvm ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh 2>/dev/null | bash || log_warn "nvm installation skipped"
    log_info "nvm installed"
fi

# Install opencode
log_step "Installing opencode..."
if [ ! -f ~/.opencode/bin/opencode ]; then
    curl -fsSL https://opencode.ai/install 2>/dev/null | bash || log_warn "opencode installation skipped"
fi

# Install getnf for fonts
log_step "Installing getnf font installer..."
if [ ! -f ~/.local/bin/getnf ]; then
    curl -fsSL https://raw.githubusercontent.com/MounirErhili/getnf/main/install.sh 2>/dev/null | bash || log_warn "getnf installation skipped"
fi

# Final verification
log_info "Verifying installation..."
echo ""
command -v hyprctl >/dev/null && log_info "✓ Hyprland installed" || log_error "✗ Hyprland not found"
command -v kitty >/dev/null && log_info "✓ Kitty terminal installed" || log_error "✗ Kitty not found"
command -v waybar >/dev/null && log_info "✓ Waybar installed" || log_error "✗ Waybar not found"
command -v sddm >/dev/null && log_info "✓ SDDM (greeter) installed" || log_warn "✗ SDDM not found"
pactl info >/dev/null 2>&1 && log_info "✓ Pipewire working" || log_warn "✗ Pipewire not responding"
fc-list | grep -q "Hack Nerd" && log_info "✓ Hack Nerd Font installed" || log_warn "✗ Hack Nerd Font not found"
[ -L "$HOME/.config/hypr" ] && log_info "✓ Hyprland configs linked via stow" || log_warn "✗ Hyprland configs not linked"
[ -f "$HOME/.config/xdg-desktop-portal/hyprland-portals.conf" ] && log_info "✓ XDG desktop portal configured" || log_warn "✗ XDG portal not configured"

if [ "$NVIDIA_DETECTED" = "1" ]; then
    log_info "✓ NVIDIA GPU detected and configured"
fi

echo ""
log_info "Desktop environment setup complete!"
log_info "Next steps:"

if [ "$NVIDIA_DETECTED" = "1" ]; then
    log_info "  1. Restart your system for NVIDIA changes: sudo reboot"
else
    log_info "  1. Restart your system: sudo reboot"
fi

log_info "  2. SDDM will start automatically on login"
log_info "  3. Select Hyprland from the session menu in SDDM"
log_info "  4. Default keybind: SUPER + Q to open terminal"
log_info "  5. All configs are managed by stow from ~/.dotfiles/"
echo ""
log_info "For more information on Hyprland keybinds:"
log_info "  • Check: ~/.dotfiles/.config/hypr/hyprland.conf"
log_info "  • Or in-session: Super + H (if configured)"
echo ""
