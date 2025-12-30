#!/bin/bash

##############################################################################
# Arch Linux Hyprland Desktop Setup Script
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

# Check if running on Arch
if [ ! -f /etc/arch-release ]; then
    log_error "This script requires Arch Linux"
    exit 1
fi

log_info "================================================================"
log_info "NOTE: Some packages like hyprland, kitty, waybar may be in the AUR"
log_info "If they don't install, you may need to:"
log_info "  1. Enable multilib repo in /etc/pacman.conf"
log_info "  2. Install from AUR using: yay -S hyprland kitty waybar"
log_info "  3. Or compile from source if needed"
log_info "This script will continue with other packages if these fail."
log_info "================================================================"
echo ""

# Check for NVIDIA GPU
NVIDIA_DETECTED=0
if command -v lspci >/dev/null 2>&1 && lspci | grep -i nvidia >/dev/null 2>&1; then
    NVIDIA_DETECTED=1
    log_info "NVIDIA GPU detected"
fi

log_info "Starting Arch Linux Hyprland desktop setup..."

# Install yay AUR helper using the dedicated script
log_step "Ensuring yay AUR helper is installed..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_YAY_SCRIPT="$SCRIPT_DIR/install_yay.sh"

if [ ! -f "$INSTALL_YAY_SCRIPT" ]; then
    log_error "install_yay.sh not found at $INSTALL_YAY_SCRIPT"
    log_error "Cannot continue without yay installer script"
    exit 1
fi

if ! bash "$INSTALL_YAY_SCRIPT"; then
    log_error "Failed to install yay"
    log_info "You can manually install yay from: https://aur.archlinux.org/yay.git"
    log_info "Or try: git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si"
    exit 1
fi

log_info "yay is ready for AUR package installations"

# Install pywal (required for wallpaper color generation)
log_step "Ensuring pywal is installed..."
if ! command -v wal >/dev/null 2>&1; then
    log_info "pywal is not installed. Installing..."
    if ! sudo pacman -S --noconfirm python-pywal; then
        log_warn "Failed to install pywal from official repos, trying yay..."
        if ! yay -S --noconfirm python-pywal; then
            log_error "Failed to install pywal"
            FAILED_PACKAGES="$FAILED_PACKAGES pywal"
            PYWAL_ERROR="Unable to install python-pywal from official repos or AUR"
            INSTALL_ERRORS="$INSTALL_ERRORS

--- Pywal Installation Errors ---
$PYWAL_ERROR"
        else
            log_info "✓ pywal installed via yay"
        fi
    else
        log_info "✓ pywal installed"
    fi
else
    log_info "✓ pywal already installed"
fi

# Update system
log_step "Updating system packages..."
sudo pacman -Syu --noconfirm || log_warn "System package update had issues"

# Install linux headers (required for DKMS kernel modules)
log_step "Installing Linux headers for kernel module compilation..."
if ! sudo pacman -S --noconfirm linux-headers; then
    log_error "Failed to install linux-headers - required for NVIDIA DKMS modules"
    FAILED_PACKAGES="$FAILED_PACKAGES linux-headers"
else
    log_info "✓ Linux headers installed"
fi

# Install desktop and development packages
log_step "Installing Hyprland and desktop packages..."
log_info "Attempting to install: hyprland kitty hypridle waybar swww swaync and others..."

# List of packages to install (excluding wlogout which is in AUR)
PACKAGES_TO_INSTALL="hyprland kitty hypridle waybar swww swaync pipewire pipewire-pulse pipewire-alsa pipewire-jack wireplumber brightnessctl playerctl power-profiles-daemon grim slurp hyprshot hyprlock thunar wofi flatpak git neovim jq gcc make patch unzip curl wget zlib bzip2 readline sqlite openssl tk libffi xz ncurses python-pip stow docker yazi p7zip poppler fd ripgrep fzf zoxide imagemagick xclip zsh tmux htop fastfetch bluez bluez-utils blueman"

INSTALL_OUTPUT=$(sudo pacman -S --noconfirm $PACKAGES_TO_INSTALL 2>&1) || PACMAN_EXIT=$?

# Capture any error messages from pacman
PACMAN_ERRORS=$(echo "$INSTALL_OUTPUT" | grep -i "error\|failed\|not found\|could not\|unable\|invalid" || true)

# Check each critical package
for pkg in hyprland kitty waybar swww swaync blueman power-profiles-daemon; do
    if pacman -Q $pkg >/dev/null 2>&1; then
        log_info "✓ $pkg installed"
    else
        FAILED_PACKAGES="$FAILED_PACKAGES $pkg"
        log_warn "✗ $pkg not found after installation"
    fi
done

log_info "Hyprland and desktop packages installation completed"
if [ -n "$PACMAN_ERRORS" ]; then
    log_warn "Pacman output contained errors - see summary at end of script"
    INSTALL_ERRORS="$INSTALL_ERRORS

--- Main Package Installation Errors ---
$PACMAN_ERRORS"
fi

# Install wlogout from AUR (not in official repos)
log_step "Installing wlogout from AUR..."
if yay -S --noconfirm wlogout 2>&1 >/dev/null; then
    log_info "✓ wlogout installed via yay"
else
    log_warn "✗ wlogout installation failed"
    FAILED_PACKAGES="$FAILED_PACKAGES wlogout"
    WLOGOUT_ERROR=$(yay -S --noconfirm wlogout 2>&1 | grep -i "error\|failed\|not found\|could not\|unable\|invalid" || true)
    if [ -n "$WLOGOUT_ERROR" ]; then
        INSTALL_ERRORS="$INSTALL_ERRORS

--- wlogout (AUR) Installation Errors ---
$WLOGOUT_ERROR"
    fi
fi

# Install and setup greeter (SDDM) for login manager - best DM for Wayland
log_step "Installing SDDM (display manager for Wayland)..."

if sudo pacman -S --noconfirm sddm sddm-kcm 2>&1 >/dev/null; then
    if pacman -Q sddm >/dev/null 2>&1; then
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
# Note: This will be managed by stow, don't create it if it exists in dotfiles
if [ ! -d "$HOME/.dotfiles/.config/xdg-desktop-portal" ]; then
    mkdir -p "$HOME/.config/xdg-desktop-portal"
    if [ ! -f "$HOME/.config/xdg-desktop-portal/hyprland-portals.conf" ]; then
        tee "$HOME/.config/xdg-desktop-portal/hyprland-portals.conf" > /dev/null <<EOF
[General]
backends=hyprland;gtk
EOF
        log_info "XDG desktop portal configured"
    fi
else
    log_info "XDG desktop portal will be managed by stow"
fi

# Ensure XDG Session Type environment variable is set for Hyprland
# Only add to bashrc, let stow manage .zshrc
if ! grep -q "XDG_SESSION_TYPE=wayland" ~/.bashrc 2>/dev/null; then
    echo "export XDG_SESSION_TYPE=wayland" >> ~/.bashrc
fi
# Check if zshrc is managed by stow before modifying
if [ ! -L "$HOME/.zshrc" ]; then
    if ! grep -q "XDG_SESSION_TYPE=wayland" ~/.zshrc 2>/dev/null; then
        echo "export XDG_SESSION_TYPE=wayland" >> ~/.zshrc
    fi
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

# Setup Bluetooth (BlueZ)
log_step "Setting up Bluetooth (BlueZ)..."
if ! systemctl enable bluetooth 2>/dev/null; then
    log_warn "Failed to enable Bluetooth service"
else
    log_info "Bluetooth service enabled"
fi
if ! systemctl start bluetooth 2>/dev/null; then
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
            log_info "RTX 20+ series detected - open source drivers recommended"
        fi
    fi
    
    # Install NVIDIA drivers and utils with all kernel modules
    log_step "Installing NVIDIA driver packages with kernel modules..."
    if ! sudo pacman -S --noconfirm \
        nvidia \
        nvidia-utils \
        nvidia-settings \
        nvidia-dkms \
        opencl-nvidia \
        cuda \
        libvdpau \
        libva-nvidia-driver 2>/dev/null; then
        log_warn "NVIDIA drivers installation had issues - you may need to install manually"
    else
        log_info "NVIDIA drivers with kernel modules installed"
    fi
    
    # Configure NVIDIA for Hyprland
    log_step "Configuring NVIDIA for Hyprland..."
    
    # Create/update modprobe config
    sudo tee /etc/modprobe.d/nvidia.conf > /dev/null <<EOF
# Enable NVIDIA DRM kernel mode setting
options nvidia_drm modeset=1
options nvidia_drm fbdev=1
EOF
    
    # Update mkinitcpio with complete NVIDIA kernel modules
    if ! grep -q "nvidia nvidia_modeset nvidia_uvm nvidia_drm" /etc/mkinitcpio.conf; then
        sudo sed -i 's/^MODULES=.*/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
        log_info "Added NVIDIA modules to mkinitcpio.conf"
    else
        log_info "NVIDIA modules already in mkinitcpio.conf"
    fi
    
    # Create/update environment variables
    sudo tee /etc/environment.d/90-nvidia.conf > /dev/null <<EOF
# NVIDIA environment variables for Hyprland - Performance & Compatibility
LIBVA_DRIVER_NAME=nvidia
XDG_SESSION_TYPE=wayland
GBM_BACKEND=nvidia-drm
__GLX_VENDOR_LIBRARY_NAME=nvidia
WLR_NO_HARDWARE_CURSORS=1

# Performance optimization variables
__NV_PRIME_RENDER_OFFLOAD=1
__VK_LAYER_NV_optimus=NVIDIA_only
__GL_VRR_ALLOWED=1
PROTON_ENABLE_NVAPI=1
PROTON_ENABLE_NGX_UPSCALING=1

# Video acceleration and codec support
VDPAU_DRIVER=nvidia
NVHPC_ENABLE CUDA=1

# OpenGL and Vulkan optimizations
__GL_THREADED_OPTIMIZATIONS=1
__GL_SHADER_DISK_CACHE=1
__GL_SHADER_DISK_CACHE_PATH=/tmp
__GL_IGNORE_MIPMAP_LEVEL=1

# Frame pacing and sync
__GL_SYNC_TO_VBLANK=0
CLGL_SHARE_GL_RESOURCES=1

# Memory management
__GL_MAX_TEXTURE_UNITS=32
__GL_HEAP_MEMORY_LIMIT_KB=1048576

# Wayland specific optimizations
WLR_DRM_NO_ATOMIC=1
WLR_RENDERER=vulkan

# Power management and thermal
__NV_REGISTERS=0

# Development and debugging (set to 0 for production)
__GL_DEBUG=0
__GL_LOG_MIN_SEVERITY=0

# Legacy compatibility
__GL_FORCE_STANDARD_GAMMA_CORRECTIONS=1
__GL_X_SWAP_SUPPORTED=1
EOF
    
    # Regenerate initramfs
    log_step "Regenerating initramfs with NVIDIA modules..."
    if ! sudo mkinitcpio -P 2>/dev/null; then
        log_warn "mkinitcpio regeneration had issues - you may need to run: sudo mkinitcpio -P"
    else
        log_info "Initramfs regenerated successfully"
    fi
    
    # Verify environment variables are set
    log_step "Verifying NVIDIA environment variables..."
    if [ -f /etc/environment.d/90-nvidia.conf ]; then
        log_info "NVIDIA environment variables configured in /etc/environment.d/90-nvidia.conf"
        log_info "These will be loaded automatically on next boot/login"
    else
        log_warn "NVIDIA environment variables file not found"
    fi
    
    log_info "NVIDIA configuration complete - reboot required for changes to take effect"
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

# Fix waybar power-profile.sh symlink
log_step "Setting up waybar scripts..."
if [ -f "$HOME/.dotfiles/.config/waybar/scripts/power-profile.sh" ]; then
    mkdir -p "$HOME/.config/waybar/scripts"
    ln -sf "$HOME/.dotfiles/.config/waybar/scripts/power-profile.sh" "$HOME/.config/waybar/scripts/power-profile.sh"
    log_info "Waybar power profile script linked"
else
    log_warn "Power profile script not found in dotfiles"
fi

# Final verification
log_info "Verifying installation..."
echo ""
command -v hyprctl >/dev/null && log_info "✓ Hyprland installed" || log_error "✗ Hyprland not found"
command -v kitty >/dev/null && log_info "✓ Kitty terminal installed" || log_error "✗ Kitty not found"
command -v waybar >/dev/null && log_info "✓ Waybar installed" || log_error "✗ Waybar not found"
pacman -Q sddm >/dev/null 2>&1 && log_info "✓ SDDM display manager installed" || log_error "✗ SDDM not found"
systemctl is-enabled sddm >/dev/null 2>&1 && log_info "✓ SDDM enabled for boot" || log_warn "⚠ SDDM not enabled"
command -v powerprofilesctl >/dev/null && log_info "✓ Power profile management installed" || log_warn "⚠ power-profiles-daemon not found"

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
    
    log_warn "To install these packages manually, you have several options:"
    log_info ""
    log_info "Option 1 - If you have yay installed (AUR helper):"
    log_info "  yay -S$FAILED_PACKAGES"
    log_info ""
    log_info "Option 2 - If you have paru installed (AUR helper):"
    log_info "  paru -S$FAILED_PACKAGES"
    log_info ""
    log_info "Option 3 - Manual AUR installation:"
    log_info "  Visit: https://aur.archlinux.org/packages"
    log_info "  Search for each package and follow the AUR installation guide"
    log_info ""
    log_info "Option 4 - Check if they're in a different repo:"
    log_info "  pacman -Ss <package_name>"
    echo ""
else
    log_info "✓ All packages installed successfully!"
fi

log_info ""
log_info "Next steps:"
log_info ""

if [ "$NVIDIA_DETECTED" = "1" ]; then
    log_info "  1. Restart your system for NVIDIA changes: sudo reboot"
else
    log_info "  1. Restart your system: sudo reboot"
fi

log_info "  2. SDDM will start automatically on boot"
log_info "  3. Select 'Hyprland' from the session dropdown menu"
log_info "  4. Enter your credentials and login"
log_info "  5. Default keybind: ALT + T to open terminal"
log_info "  6. All configs are managed by stow from ~/.dotfiles/"
echo ""

# Setup dotfile symlinks with stow
log_step "Setting up dotfile symlinks with stow..."
if cd "$HOME/.dotfiles" 2>/dev/null; then
    if stow -v . 2>/dev/null; then
        log_info "✓ Dotfile symlinks created successfully"
    else
        log_warn "⚠ Stow had some conflicts, but main configs should be working"
        log_info "  You may need to run: cd ~/.dotfiles && stow -v ."
    fi
    cd - >/dev/null
else
    log_error "✗ Could not access ~/.dotfiles directory"
fi

echo ""
log_info "For more information on Hyprland keybinds:"
log_info "  • Check: ~/.dotfiles/.config/hypr/hyprland.conf"
log_info "  • Or in-session: Super + H (if configured)"
echo ""
echo "================================================================================"
