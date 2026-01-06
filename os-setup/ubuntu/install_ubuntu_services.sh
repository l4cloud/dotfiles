#!/bin/bash

##############################################################################
# Ubuntu Development Environment Setup Script
# Installs core development tools and utilities (no desktop environment)
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

log_info "Starting Ubuntu development environment setup..."
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

# Install development packages
log_step "Installing development packages..."
sudo apt install -y \
    git curl wget \
    neovim zsh tmux htop fastfetch \
    jq gcc g++ make patch unzip \
    zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev libssl-dev \
    libffi-dev liblzma-dev python3-dev python3-pip \
    stow docker.io \
    p7zip-full poppler-utils fd-find ripgrep fzf zoxide imagemagick xclip \
    build-essential apt-transport-https ca-certificates gnupg lsb-release

# Configure Docker
log_step "Setting up Docker..."
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER
log_info "Docker configured (you may need to log out and back in)"

# Install Rust for Yazi
log_step "Installing Rust (for Yazi)..."
if ! command -v cargo &>/dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y 2>/dev/null || log_warn "Rust installation skipped"
    # Source cargo environment
    source "$HOME/.cargo/env" 2>/dev/null || true
else
    log_info "Rust already installed"
fi

# Install Yazi via Cargo
log_step "Installing Yazi..."
if ! command -v yazi &>/dev/null; then
    if command -v cargo &>/dev/null; then
        source "$HOME/.cargo/env" 2>/dev/null || true
        cargo install --locked yazi-fm yazi-cli 2>/dev/null || log_warn "Yazi installation skipped"
        # Create symlinks
        mkdir -p "$HOME/.local/bin"
        ln -sf "$HOME/.cargo/bin/yazi" "$HOME/.local/bin/yazi" 2>/dev/null || true
        ln -sf "$HOME/.cargo/bin/ya" "$HOME/.local/bin/ya" 2>/dev/null || true
    else
        log_warn "Cargo not available, skipping Yazi"
    fi
else
    log_info "Yazi already installed"
fi

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

# If dotfiles exist, prepare existing files for stow (safe mode)
if [ -d "$HOME/.dotfiles" ]; then
    log_info "Preparing existing files for stow (safe mode)..."
    stamp=$(date +%Y%m%d%H%M%S)
    TMPBACKDIR=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-backup-$stamp-XXXX")
    moved_any=0
    for item in .config wallpapers nvim starship.toml .aliases.zsh .func.zsh .ssh_fzf.zsh .tmux.conf .zshrc; do
        target="$HOME/$item"
        if [ -L "$target" ]; then
            rm -f "$target"
            log_info "  Removed existing symlink $item"
        elif [ -e "$target" ]; then
            mkdir -p "$(dirname "$TMPBACKDIR/$item")" 2>/dev/null || true
            mv "$target" "$TMPBACKDIR/$item"
            log_warn "  Moved existing $item to backup directory"
            moved_any=1
        else
            log_info "  No existing $item found"
        fi
    done

    if [ "$moved_any" -eq 1 ]; then
        archive="${TMPDIR:-/tmp}/dotfiles-backup-$stamp.tar.gz"
        if command -v tar >/dev/null 2>&1; then
            tar -C "$TMPBACKDIR" -czf "$archive" . || log_warn "Failed to create archive $archive"
            if [ -f "$archive" ]; then
                log_info "Backups archived to $archive"
                rm -rf "$TMPBACKDIR"
            else
                log_warn "Archive creation failed; backups remain in $TMPBACKDIR"
            fi
        else
            log_warn "tar not available; backups are in $TMPBACKDIR"
        fi
    else
        rmdir "$TMPBACKDIR" 2>/dev/null || true
    fi
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
command -v git >/dev/null && log_info "✓ Git installed" || log_error "✗ Git not found"
command -v neovim >/dev/null && log_info "✓ Neovim installed" || log_error "✗ Neovim not found"
command -v zsh >/dev/null && log_info "✓ Zsh installed" || log_error "✗ Zsh not found"
command -v docker >/dev/null && log_info "✓ Docker installed" || log_error "✗ Docker not found"
command -v lazygit >/dev/null && log_info "✓ lazygit installed" || log_warn "✗ lazygit not installed (non-critical)"
command -v yazi >/dev/null && log_info "✓ yazi installed" || log_warn "✗ yazi not installed (non-critical)"

echo ""
log_info "Development environment setup complete!"
log_info "Next steps:"
log_info "  1. Log out and back in to apply group changes (docker, shell)"
log_info "  2. Run 'source ~/.zshrc' to reload shell configuration"
log_info "  3. To install desktop environment (Hyprland), run: ./setup.sh"
echo ""
