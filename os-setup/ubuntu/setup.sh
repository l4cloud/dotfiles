#!/bin/bash

##############################################################################
# Ubuntu Complete Setup Script
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

log_info "Starting Ubuntu setup..."
log_info "Detected: $PRETTY_NAME"

# Update system
log_step "Updating system packages..."
sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y

# Install base development packages
log_step "Installing base development packages..."
sudo apt install -y \
    git curl wget \
    neovim zsh tmux htop fastfetch \
    jq gcc g++ make patch unzip \
    zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev libssl-dev \
    libffi-dev liblzma-dev python3-dev python3-pip \
    stow docker.io \
    ffmpeg p7zip-full poppler-utils fd-find ripgrep fzf zoxide imagemagick xclip \
    build-essential apt-transport-https ca-certificates gnupg lsb-release

# Configure Docker
log_step "Setting up Docker..."
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER
log_info "Docker configured (you may need to log out and back in)"

# Install Yazi from GitHub releases
log_step "Installing Yazi..."
if ! command -v yazi &>/dev/null; then
    YAZI_VERSION=$(curl -s "https://api.github.com/repos/sxyazi/yazi/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
    if [ -n "$YAZI_VERSION" ]; then
        log_info "Downloading Yazi v${YAZI_VERSION}..."
        curl -L "https://github.com/sxyazi/yazi/releases/download/v${YAZI_VERSION}/yazi-x86_64-unknown-linux-gnu.zip" -o /tmp/yazi.zip
        unzip -q /tmp/yazi.zip -d /tmp/yazi
        mkdir -p "$HOME/.local/bin"
        cp /tmp/yazi/yazi-x86_64-unknown-linux-gnu/yazi "$HOME/.local/bin/yazi"
        cp /tmp/yazi/yazi-x86_64-unknown-linux-gnu/ya "$HOME/.local/bin/ya"
        chmod +x "$HOME/.local/bin/yazi" "$HOME/.local/bin/ya"
        rm -rf /tmp/yazi.zip /tmp/yazi
        log_info "Yazi installed successfully"
    else
        log_warn "Could not determine Yazi version"
    fi
else
    log_info "Yazi already installed"
fi

# Install Hyprland (from ubuntu repos or build)
log_step "Installing Hyprland..."
sudo apt install -y hyprland kitty hypridle waybar swww swaync \
    pipewire pipewire-pulse pipewire-alsa pipewire-jack wireplumber \
    brightnessctl playerctl grim slurp hyprshot hyprlock wlogout \
    thunar wofi flatpak 2>/dev/null || log_warn "Some Hyprland packages may not be available in this Ubuntu version"

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

# Install lazygit from GitHub releases
log_step "Installing lazygit..."
if ! command -v lazygit &>/dev/null; then
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
    if [ -n "$LAZYGIT_VERSION" ]; then
        curl -L "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" | \
            tar xz -C /tmp
        sudo install /tmp/lazygit /usr/local/bin
        log_info "lazygit installed"
    else
        log_warn "Could not determine lazygit version"
    fi
else
    log_info "lazygit already installed"
fi

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

# Configure UFW firewall
log_step "Configuring firewall..."
sudo ufw --force enable 2>/dev/null || true
sudo ufw default deny incoming 2>/dev/null || true
sudo ufw allow ssh 2>/dev/null || true
log_info "Firewall configured"

# Final verification
log_info "Verifying installation..."
echo ""
command -v hyprctl >/dev/null && log_info "✓ Hyprland installed" || log_warn "✗ Hyprland may not be available"
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
log_info "  3. If Hyprland is available, it will start automatically"
log_info "  4. Default keybind (Hyprland): SUPER + Q to open terminal"
echo ""
