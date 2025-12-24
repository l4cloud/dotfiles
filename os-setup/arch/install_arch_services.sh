#!/bin/bash

##############################################################################
# Arch Linux Development Environment Setup Script
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

# Check if running on Arch
if [ ! -f /etc/arch-release ]; then
    log_error "This script requires Arch Linux"
    exit 1
fi

log_info "Starting Arch Linux development environment setup..."

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
sudo pacman -Syu --noconfirm

# Install development packages
log_step "Installing development packages..."
sudo pacman -S --noconfirm \
    git curl wget \
    neovim zsh tmux htop fastfetch \
    jq gcc make patch unzip \
    zlib bzip2 readline sqlite openssl tk libffi xz ncurses \
    python-pip stow go docker

# Install AUR helper (yay) dependencies
log_step "Setting up yay AUR helper..."
if ! command -v yay &>/dev/null; then
    sudo pacman -S --noconfirm base-devel
    mkdir -p /tmp/yay-build
    cd /tmp/yay-build
    git clone https://aur.archlinux.org/yay.git . 2>/dev/null || true
    if [ -f PKGBUILD ]; then
        makepkg -si --noconfirm 2>&1 || log_warn "yay build had issues"
    fi
    cd /
    rm -rf /tmp/yay-build
fi

if command -v yay &>/dev/null; then
    log_info "yay installed successfully"
    log_step "Installing lazygit from AUR..."
    yay -S --noconfirm lazygit 2>&1 || log_warn "lazygit installation skipped"
else
    log_warn "yay installation failed, continuing without AUR packages"
fi

# Install Yazi and dependencies
log_step "Installing Yazi and dependencies..."
sudo pacman -S --noconfirm \
    yazi p7zip poppler fd ripgrep fzf zoxide imagemagick xclip 2>/dev/null || log_warn "Some Yazi dependencies skipped"

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

# Set Zsh as default shell
log_step "Setting Zsh as default shell..."
sudo usermod -s /bin/zsh $USER

# Install dotfiles with stow
log_step "Installing dotfile configs using stow..."
DOTFILES_DIR="$HOME/.dotfiles"

if [ ! -d "$DOTFILES_DIR" ]; then
    log_error "Dotfiles directory not found at $DOTFILES_DIR"
    exit 1
fi

log_info "Removing existing files to allow stow to overwrite..."
# Remove all existing files/symlinks that stow will replace
for item in .config wallpapers nvim starship.toml .aliases.zsh .func.zsh .ssh_fzf.zsh .tmux.conf .zshrc; do
    target="$HOME/$item"
    if [ -e "$target" ] || [ -L "$target" ]; then
        rm -rf "$target"
        log_info "  Removed $item"
    fi
done

log_info "Running stow to install dotfiles..."
cd "$HOME" || exit 1

if stow -d "$DOTFILES_DIR" -t "$HOME" -R . 2>&1; then
    log_info "✓ Dotfiles installed successfully"
else
    log_warn "stow installation had issues"
fi

# Final verification
log_info "Verifying installation..."
echo ""
command -v git >/dev/null && log_info "✓ Git installed" || log_error "✗ Git not found"
command -v neovim >/dev/null && log_info "✓ Neovim installed" || log_error "✗ Neovim not found"
command -v zsh >/dev/null && log_info "✓ Zsh installed" || log_error "✗ Zsh not found"
command -v yay >/dev/null && log_info "✓ yay installed" || log_warn "✗ yay not installed (non-critical)"
command -v lazygit >/dev/null && log_info "✓ lazygit installed" || log_warn "✗ lazygit not installed (non-critical)"

echo ""
log_info "Development environment setup complete!"
log_info "Next steps:"
log_info "  1. Log out and back in to apply shell changes"
log_info "  2. Run 'source ~/.zshrc' to reload shell configuration"
log_info "  3. To install desktop environment, use: install.sh --desktop"
echo ""