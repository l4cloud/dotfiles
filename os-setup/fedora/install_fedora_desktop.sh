#!/bin/bash

##############################################################################
# Fedora Hyprland Desktop Setup Script
# Sets up Hyprland desktop environment with optional NVIDIA driver support
# Uses stow to manage dotfile configs
##############################################################################

set -u
# Don't use 'set -e' to avoid exiting on command failures - we want to continue and log errors

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

# Track failed package installations and error messages
FAILED_PACKAGES=""
INSTALL_ERRORS=""

# Check if running on Fedora
if [ ! -f /etc/fedora-release ]; then
    log_error "This script requires Fedora Linux"
    exit 1
fi

log_info "================================================================"
log_info "Fedora Hyprland Desktop Setup"
log_info "This script will install Hyprland and all required packages"
log_info "================================================================"
echo ""

# Check for NVIDIA GPU
NVIDIA_DETECTED=0
if command -v lspci >/dev/null 2>&1 && lspci | grep -i nvidia >/dev/null 2>&1; then
    NVIDIA_DETECTED=1
    log_info "NVIDIA GPU detected"
fi

log_info "Starting Fedora Hyprland desktop setup..."

# Install pywal (required for wallpaper color generation)
log_step "Ensuring pywal is installed..."
if ! command -v wal >/dev/null 2>&1; then
    log_info "pywal is not installed. Installing..."
    if ! sudo dnf install -y python3-pywal; then
        log_error "Failed to install pywal"
        FAILED_PACKAGES="$FAILED_PACKAGES pywal"
        PYWAL_ERROR="Unable to install python3-pywal"
        INSTALL_ERRORS="$INSTALL_ERRORS

--- Pywal Installation Errors ---
$PYWAL_ERROR"
    else
        log_info "✓ pywal installed"
    fi
else
    log_info "✓ pywal already installed"
fi

# Update system
log_step "Updating system packages..."
sudo dnf upgrade -y || log_warn "System package update had issues"

# Enable RPMFusion repositories for additional packages
log_step "Enabling RPMFusion repositories..."
if [ ! -f /etc/yum.repos.d/rpmfusion-free.repo ]; then
    sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm || log_warn "RPMFusion free repo installation had issues"
else
    log_info "RPMFusion free repo already enabled"
fi

if [ ! -f /etc/yum.repos.d/rpmfusion-nonfree.repo ]; then
    sudo dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm || log_warn "RPMFusion nonfree repo installation had issues"
else
    log_info "RPMFusion nonfree repo already enabled"
fi

# Install desktop and development packages
log_step "Installing Hyprland and desktop packages..."
log_info "Attempting to install: hyprland kitty hypridle waybar swww swaync and others..."

# List of packages to install
PACKAGES_TO_INSTALL="hyprland kitty hypridle waybar swww swaync pipewire-utils brightnessctl playerctl power-profiles-daemon grim slurp hyprshot hyprlock wlogout thunar wofi flatpak git neovim jq gcc gcc-c++ make patch unzip curl wget zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel openssl-devel tk-devel libffi-devel xz-devel ncurses-devel python3-pip stow yazi p7zip poppler fd-find ripgrep fzf zoxide ImageMagick xclip zsh tmux htop fastfetch blueman golang"

INSTALL_OUTPUT=$(sudo dnf install -y $PACKAGES_TO_INSTALL 2>&1) || DNF_EXIT=$?

# Capture any error messages from dnf
DNF_ERRORS=$(echo "$INSTALL_OUTPUT" | grep -i "error\|failed\|not found\|could not\|unable\|invalid" || true)

# Check each critical package
for pkg in hyprland kitty waybar swww swaync blueman; do
    if rpm -q $pkg >/dev/null 2>&1; then
        log_info "✓ $pkg installed"
    else
        FAILED_PACKAGES="$FAILED_PACKAGES $pkg"
        log_warn "✗ $pkg not found after installation"
    fi
done

log_info "Hyprland and desktop packages installation completed"
if [ -n "$DNF_ERRORS" ]; then
    log_warn "DNF output contained errors - see summary at end of script"
    INSTALL_ERRORS="$INSTALL_ERRORS

--- Main Package Installation Errors ---
$DNF_ERRORS"
fi

# Install and setup SDDM for login manager - best DM for Wayland
log_step "Installing SDDM (display manager for Wayland)..."

if sudo dnf install -y sddm 2>&1 >/dev/null; then
    if rpm -q sddm >/dev/null 2>&1; then
        log_info "✓ SDDM installed successfully"
        
        # Enable SDDM service
        log_step "Enabling SDDM service..."
        if sudo systemctl enable sddm 2>&1 >/dev/null; then
            log_info "✓ SDDM enabled and will start on boot"
        else
            log_warn "Failed to enable SDDM service"
        fi
    else
        FAILED_PACKAGES="$FAILED_PACKAGES sddm"
        log_error "✗ SDDM installation verification failed"
    fi
else
    FAILED_PACKAGES="$FAILED_PACKAGES sddm"
    log_error "✗ SDDM installation failed"
fi

# Install Hack Nerd Font
log_step "Installing Hack Nerd Font..."
if ! command -v fc-list >/dev/null 2>&1 || ! fc-list 2>/dev/null | grep -q "Hack Nerd"; then
    mkdir -p /tmp/font-install
    cd /tmp/font-install
    if wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Hack.zip; then
        sudo unzip -q Hack.zip -d /usr/share/fonts
        if command -v fc-cache >/dev/null 2>&1; then
            sudo fc-cache -fv >/dev/null 2>&1 || true
        fi
        log_info "Hack Nerd Font installed"
    else
        log_warn "Failed to download Hack Nerd Font"
    fi
    cd /
    rm -rf /tmp/font-install
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
if ! systemctl --user enable pipewire pipewire-pulse wireplumber 2>/dev/null; then
    log_warn "Failed to enable Pipewire services"
else
    log_info "Pipewire services enabled"
fi
if ! systemctl --user start pipewire pipewire-pulse wireplumber 2>/dev/null; then
    log_warn "Failed to start Pipewire services"
else
    log_info "Pipewire services started"
fi
log_info "Pipewire configured"

# Setup Bluetooth
log_step "Setting up Bluetooth..."
if ! sudo systemctl enable bluetooth 2>/dev/null; then
    log_warn "Failed to enable Bluetooth service"
else
    log_info "Bluetooth service enabled"
fi
if ! sudo systemctl start bluetooth 2>/dev/null; then
    log_warn "Failed to start Bluetooth service"
else
    log_info "Bluetooth service started"
fi
log_info "Bluetooth configured"

# Setup power-profiles-daemon
log_step "Setting up power profile management..."
if ! sudo systemctl enable power-profiles-daemon 2>/dev/null; then
    log_warn "Failed to enable power-profiles-daemon service"
else
    log_info "power-profiles-daemon service enabled"
fi
if ! sudo systemctl start power-profiles-daemon 2>/dev/null; then
    log_warn "Failed to start power-profiles-daemon service"
else
    log_info "power-profiles-daemon service started"
fi
log_info "Power profile management configured"

# Install pulsemixer for audio control
log_step "Installing pulsemixer..."
pip install --user pulsemixer 2>/dev/null || log_warn "pulsemixer installation skipped"

# Handle NVIDIA configuration if detected
if [ "$NVIDIA_DETECTED" = "1" ]; then
    log_step "Configuring NVIDIA drivers for Hyprland..."
    
    # Detect GPU generation to recommend driver
    if command -v lspci >/dev/null 2>&1 && lspci | grep -i "NVIDIA.*RTX\|GeForce" >/dev/null; then
        GPU_GEN=$(lspci | grep -i nvidia | head -1)
        log_info "Detected GPU: $GPU_GEN"
        
        # Check if RTX 20 series or newer (supports open source drivers)
        if echo "$GPU_GEN" | grep -iE "RTX 20|RTX 30|RTX 40|RTX 50" >/dev/null; then
            log_info "RTX 20+ series detected - using proprietary drivers"
        fi
    fi
    
    # Install NVIDIA drivers and utils
    log_step "Installing NVIDIA driver packages..."
    if ! sudo dnf install -y \
        akmod-nvidia \
        xorg-x11-drv-nvidia \
        xorg-x11-drv-nvidia-cuda \
        xorg-x11-drv-nvidia-libs \
        xorg-x11-drv-nvidia-libs.i686 2>/dev/null; then
        log_warn "NVIDIA drivers installation had issues - you may need to install manually"
    else
        log_info "NVIDIA drivers installed"
    fi
    
    # Configure NVIDIA for Hyprland
    log_step "Configuring NVIDIA for Hyprland..."
    
    # Create/update modprobe config
    sudo tee /etc/modprobe.d/nvidia.conf > /dev/null <<EOF
# Enable NVIDIA DRM kernel mode setting
options nvidia_drm modeset=1
options nvidia_drm fbdev=1
EOF
    
    # Create/update environment variables
    sudo tee /etc/environment.d/90-nvidia.conf > /dev/null <<EOF
# NVIDIA environment variables for Hyprland
LIBVA_DRIVER_NAME=nvidia
XDG_SESSION_TYPE=wayland
GBM_BACKEND=nvidia-drm
__GLX_VENDOR_LIBRARY_NAME=nvidia
WLR_NO_HARDWARE_CURSORS=1
EOF
    
    log_info "NVIDIA configuration complete - reboot required for changes to take effect"
    log_warn "After reboot, wait 5-10 minutes for NVIDIA kernel modules to build (akmod)"
fi

# Install flatpak
log_step "Setting up Flatpak..."
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo 2>/dev/null || true

# Install Obsidian via flatpak
log_step "Installing Obsidian via Flatpak..."
if ! flatpak install -y flathub md.obsidian.Obsidian 2>/dev/null; then
    log_warn "Obsidian installation skipped"
else
    log_info "Obsidian installed"
fi

# Install Zen Browser via flatpak
log_step "Installing Zen Browser via Flatpak..."
if ! flatpak install -y flathub app.zen_browser.zen 2>/dev/null; then
    log_warn "Zen browser installation skipped"
else
    log_info "Zen browser installed"
fi

# Install language version managers
log_step "Installing pyenv..."
if [ ! -d ~/.pyenv ]; then
    if git clone https://github.com/pyenv/pyenv.git ~/.pyenv 2>/dev/null; then
        log_info "pyenv installed"
    else
        log_warn "pyenv installation failed"
    fi
else
    log_info "pyenv already installed"
fi

log_step "Installing nvm..."
if [ ! -d ~/.nvm ]; then
    if curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh 2>/dev/null | bash; then
        log_info "nvm installed"
    else
        log_warn "nvm installation skipped"
    fi
else
    log_info "nvm already installed"
fi

# Install opencode
log_step "Installing opencode..."
if [ ! -f ~/.opencode/bin/opencode ]; then
    if curl -fsSL https://opencode.ai/install 2>/dev/null | bash; then
        log_info "opencode installed"
    else
        log_warn "opencode installation skipped"
    fi
else
    log_info "opencode already installed"
fi

# Install getnf for fonts
log_step "Installing getnf font installer..."
if [ ! -f ~/.local/bin/getnf ]; then
    if curl -fsSL https://raw.githubusercontent.com/MounirErhili/getnf/main/install.sh 2>/dev/null | bash; then
        log_info "getnf installed"
    else
        log_warn "getnf installation skipped"
    fi
else
    log_info "getnf already installed"
fi

# Install lazygit via COPR
log_step "Installing lazygit..."
if ! command -v lazygit &>/dev/null; then
    sudo dnf copr enable -y atim/lazygit 2>/dev/null || true
    if sudo dnf install -y lazygit 2>/dev/null; then
        log_info "lazygit installed"
    else
        log_warn "lazygit installation skipped"
    fi
else
    log_info "lazygit already installed"
fi

# Set Zsh as default shell
log_step "Setting Zsh as default shell..."
sudo usermod -s /bin/zsh $USER || log_warn "Failed to set Zsh as default shell"

# Final verification
log_info "Verifying installation..."
echo ""
command -v hyprctl >/dev/null && log_info "✓ Hyprland installed" || log_error "✗ Hyprland not found"
command -v kitty >/dev/null && log_info "✓ Kitty terminal installed" || log_error "✗ Kitty not found"
command -v waybar >/dev/null && log_info "✓ Waybar installed" || log_error "✗ Waybar not found"
rpm -q sddm >/dev/null 2>&1 && log_info "✓ SDDM display manager installed" || log_error "✗ SDDM not found"
systemctl is-enabled sddm >/dev/null 2>&1 && log_info "✓ SDDM enabled for boot" || log_warn "⚠ SDDM not enabled"
command -v powerprofilesctl >/dev/null && log_info "✓ Power profile management installed" || log_warn "⚠ power-profiles-daemon not found"
command -v zsh >/dev/null && log_info "✓ Zsh installed" || log_error "✗ Zsh not found"
pactl info >/dev/null 2>&1 && log_info "✓ Pipewire working" || log_warn "✗ Pipewire not responding"
command -v lazygit >/dev/null && log_info "✓ lazygit installed" || log_warn "✗ lazygit not installed (non-critical)"
command -v yazi >/dev/null && log_info "✓ yazi installed" || log_warn "✗ yazi not installed (non-critical)"

echo ""
echo "================================================================================"
log_info "Desktop environment setup complete!"
echo "================================================================================"
echo ""

# Show failed packages summary
if [ -n "$FAILED_PACKAGES" ]; then
    echo ""
    log_error "FAILED/MISSING PACKAGES:"
    log_error "The following packages were unable to install:"
    for pkg in $FAILED_PACKAGES; do
        log_error "  • $pkg"
    done
    echo ""
    
    if [ -n "$INSTALL_ERRORS" ]; then
        log_error "DETAILED ERROR MESSAGES:"
        echo "$INSTALL_ERRORS"
        echo ""
    fi
    
    log_warn "To install these packages manually:"
    log_info "  sudo dnf install$FAILED_PACKAGES"
    echo ""
else
    log_info "✓ All packages installed successfully!"
fi

log_info ""
log_info "Next steps:"
log_info ""

if [ "$NVIDIA_DETECTED" = "1" ]; then
    log_info "  1. Restart your system for NVIDIA changes: sudo reboot"
    log_warn "  2. After reboot, wait 5-10 minutes for NVIDIA kernel modules to build"
else
    log_info "  1. Log out and back in to apply group changes (shell)"
    log_info "  2. Restart your system: sudo reboot"
fi

log_info "  3. SDDM will start automatically on boot"
log_info "  4. Select 'Hyprland' from the session dropdown menu"
log_info "  5. Enter your credentials and login"
log_info "  6. Default keybind: ALT + T to open terminal"
log_info "  7. All configs are managed by stow from ~/.dotfiles/"
echo ""
log_info "For more information on Hyprland keybinds:"
log_info "  • Check: ~/.dotfiles/.config/hypr/hyprland.conf"
log_info "  • Or in-session: Super + H (if configured)"
echo ""
echo "================================================================================"
