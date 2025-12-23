#!/bin/bash

##############################################################################
# Fedora Complete Setup Script
# Sets up Hyprland desktop + development environment + pipewire audio
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

# Verify running on Fedora
if [ ! -f /etc/fedora-release ]; then
    log_error "This script requires Fedora Linux"
    exit 1
fi

log_info "Starting Fedora setup..."

# Update system
log_step "Updating system packages..."
sudo dnf upgrade -y

# Install all required packages in one go
log_step "Installing all packages..."
sudo dnf install -y \
    git curl wget \
    neovim zsh tmux htop fastfetch \
    jq gcc gcc-c++ make patch unzip \
    zlib-devel bzip2-devel readline-devel sqlite-devel openssl-devel \
    tk-devel libffi-devel xz-devel ncurses-devel \
    python3-pip stow docker \
    hyprland kitty hypridle waybar swww swaync \
    pipewire pipewire-pulse pipewire-alsa pipewire-jack wireplumber \
    brightnessctl playerctl grim slurp hyprshot hyprlock wlogout \
    thunar wofi flatpak \
    yazi p7zip poppler fd-find ripgrep fzf zoxide ImageMagick xclip \
    base-devel

# Enable RPMFusion repositories for additional packages
log_step "Enabling RPMFusion repositories..."
sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm 2>/dev/null || log_warn "RPMFusion free repo already enabled"
sudo dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm 2>/dev/null || log_warn "RPMFusion nonfree repo already enabled"

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

# Setup pipewire
log_step "Setting up Pipewire audio..."
systemctl --user enable pipewire pipewire-pulse wireplumber 2>/dev/null || true
systemctl --user start pipewire pipewire-pulse wireplumber 2>/dev/null || true
log_info "Pipewire configured"

# Enable and start Docker
log_step "Setting up Docker..."
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER
log_info "Docker configured (you may need to log out and back in)"

# Install lazygit via COPR
log_step "Installing lazygit..."
if ! command -v lazygit &>/dev/null; then
    sudo dnf copr enable -y atim/lazygit 2>/dev/null || true
    sudo dnf install -y lazygit 2>/dev/null || log_warn "lazygit installation skipped"
else
    log_info "lazygit already installed"
fi

# Install Obsidian via flatpak
log_step "Installing Obsidian via Flatpak..."
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo 2>/dev/null || true
flatpak install -y flathub md.obsidian.Obsidian 2>/dev/null || log_warn "Obsidian installation skipped"

# Install Zen browser via flatpak
log_step "Installing Zen Browser via Flatpak..."
flatpak install -y flathub app.zen_browser.zen 2>/dev/null || log_warn "Zen browser installation skipped"

# Install pulsemixer for audio control
log_step "Installing pulsemixer..."
pip install --user pulsemixer 2>/dev/null || log_warn "pulsemixer installation skipped"

# Install language version managers
log_step "Installing pyenv..."
if [ ! -d ~/.pyenv ]; then
    git clone https://github.com/pyenv/pyenv.git ~/.pyenv 2>/dev/null || true
    log_info "pyenv installed"
else
    log_info "pyenv already installed"
fi

log_step "Installing nvm..."
if [ ! -d ~/.nvm ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh 2>/dev/null | bash || log_warn "nvm installation skipped"
    log_info "nvm installed"
else
    log_info "nvm already installed"
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

# Set Zsh as default shell
log_step "Setting Zsh as default shell..."
sudo usermod -s /bin/zsh $USER

# Final verification
log_info "Verifying installation..."
echo ""
command -v hyprctl >/dev/null && log_info "✓ Hyprland installed" || log_error "✗ Hyprland not found"
command -v zsh >/dev/null && log_info "✓ Zsh installed" || log_error "✗ Zsh not found"
pactl info >/dev/null 2>&1 && log_info "✓ Pipewire working" || log_warn "✗ Pipewire not responding"
command -v docker >/dev/null && log_info "✓ Docker installed" || log_error "✗ Docker not found"
command -v lazygit >/dev/null && log_info "✓ lazygit installed" || log_warn "✗ lazygit not installed (non-critical)"
command -v yazi >/dev/null && log_info "✓ yazi installed" || log_warn "✗ yazi not installed (non-critical)"

echo ""
log_info "Setup complete!"
log_info "Next steps:"
log_info "  1. Log out and back in to apply group changes (docker, shell)"
log_info "  2. Restart your system: sudo reboot"
log_info "  3. Hyprland will start automatically"
log_info "  4. Default keybind: SUPER + Q to open terminal"
echo ""
