#!/bin/bash

# Standalone yay installer script
# This script builds and installs yay from source with clear error messages

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Check if yay is already installed
if command -v yay &> /dev/null; then
    log_info "yay is already installed"
    yay --version
    exit 0
fi

log_info "yay is not installed. Starting installation..."

# Check for required tools
log_step "Checking for required dependencies..."
for cmd in git make gcc; do
    if ! command -v "$cmd" &> /dev/null; then
        log_error "$cmd is not installed"
        log_info "Installing base-devel which includes $cmd..."
        sudo pacman -S --noconfirm base-devel
        if ! command -v "$cmd" &> /dev/null; then
            log_error "Failed to install base-devel. Cannot continue."
            exit 1
        fi
    fi
done
log_info "All dependencies found"

# Setup build directory
BUILD_DIR="/tmp/yay-build-$$"
log_step "Setting up build directory at $BUILD_DIR..."

if [ -d "$BUILD_DIR" ]; then
    rm -rf "$BUILD_DIR"
fi
mkdir -p "$BUILD_DIR"

# Clone yay repository
log_step "Cloning yay from AUR..."
if ! git clone https://aur.archlinux.org/yay.git "$BUILD_DIR" 2>&1; then
    log_error "Failed to clone yay repository"
    rm -rf "$BUILD_DIR"
    exit 1
fi
log_info "Repository cloned successfully"

# Build yay
log_step "Building yay (this may take a while)..."
cd "$BUILD_DIR"

if ! makepkg -si --noconfirm 2>&1; then
    log_error "Failed to build/install yay"
    log_warn "Build output above may help diagnose the issue"
    
    # Try to provide helpful hints
    if [ ! -f PKGBUILD ]; then
        log_error "PKGBUILD file not found in $BUILD_DIR"
    fi
    
    cd /
    rm -rf "$BUILD_DIR"
    exit 1
fi

log_info "yay built and installed successfully"

# Verify installation
log_step "Verifying installation..."
if command -v yay &> /dev/null; then
    log_info "yay installation verified"
    yay --version
else
    log_error "yay was not found after installation"
    cd /
    rm -rf "$BUILD_DIR"
    exit 1
fi

# Cleanup
log_step "Cleaning up build directory..."
cd /
rm -rf "$BUILD_DIR"
log_info "Build directory cleaned up"

log_info "yay installation complete!"
log_info "Test with: yay -S --noconfirm <package-name>"
