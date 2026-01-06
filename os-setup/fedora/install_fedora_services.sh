#!/bin/bash

##############################################################################
# Fedora Development Environment Setup Script
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

# Verify running on Fedora
if [ ! -f /etc/fedora-release ]; then
    log_error "This script requires Fedora Linux"
    exit 1
fi

log_info "Starting Fedora development environment setup..."

# Check for internet connectivity
if ! ping -c 1 8.8.8.8 &> /dev/null; then
    log_warn "No internet connectivity detected. Some features may fail."
    log_warn "Please ensure you have internet access before continuing."
fi

# Check if sudo is available
if ! command -v sudo >/dev/null 2>&1; then
    log_error "sudo is not installed. This script requires sudo for privilege escalation."
    exit 1
fi

# Update system
log_step "Updating system packages..."
sudo dnf upgrade -y

# Install development packages
log_step "Installing development packages..."
sudo dnf install -y \
    git curl wget \
    neovim zsh tmux htop fastfetch \
    jq gcc gcc-c++ make patch unzip \
    zlib-devel bzip2-devel readline-devel sqlite-devel openssl-devel \
    tk-devel libffi-devel xz-devel ncurses-devel \
    python3-pip stow docker \
    yazi p7zip poppler fd-find ripgrep fzf zoxide ImageMagick xclip

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
log_info "  3. To install desktop environment, run: ./setup.sh"
echo ""
