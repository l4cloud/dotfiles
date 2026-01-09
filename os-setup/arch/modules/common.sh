#!/bin/bash

##############################################################################
# Common library functions for Arch Linux installation scripts
# Provides logging, error handling, and utility functions
##############################################################################

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Logging functions
log_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_step() { echo -e "${BLUE}[STEP]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_section() { echo -e "${CYAN}[====]${NC} $1"; }

# Check if running on Arch
check_arch() {
    if [ ! -f /etc/arch-release ]; then
        log_error "This script requires Arch Linux"
        return 1
    fi
    return 0
}

# Check for internet connectivity
check_internet() {
    if ! ping -c 1 8.8.8.8 &> /dev/null; then
        log_warn "No internet connectivity detected"
        return 1
    fi
    return 0
}

# Check if sudo is available
check_sudo() {
    if ! command -v sudo >/dev/null 2>&1; then
        log_error "sudo is not installed. This script requires sudo for privilege escalation."
        return 1
    fi
    return 0
}

# Verify package installation
verify_package() {
    local package=$1
    if pacman -Q "$package" >/dev/null 2>&1; then
        log_info "✓ $package installed"
        return 0
    else
        log_warn "✗ $package not found"
        return 1
    fi
}

# Verify command availability
verify_command() {
    local command=$1
    local package_name=${2:-$command}
    if command -v "$command" >/dev/null 2>&1; then
        log_info "✓ $package_name available"
        return 0
    else
        log_warn "✗ $package_name not found"
        return 1
    fi
}

# Install packages with error handling
install_packages() {
    local packages="$@"
    log_step "Installing packages: $packages"
    
    if sudo pacman -S --noconfirm $packages 2>&1; then
        log_success "Packages installed successfully"
        return 0
    else
        log_error "Failed to install some packages"
        return 1
    fi
}

# Enable and start systemd service
enable_service() {
    local service=$1
    local user_mode=${2:-false}
    
    if [ "$user_mode" = true ]; then
        if systemctl --user enable "$service" 2>/dev/null && \
           systemctl --user start "$service" 2>/dev/null; then
            log_info "✓ $service enabled and started (user)"
            return 0
        else
            log_warn "Failed to enable/start $service (user)"
            return 1
        fi
    else
        if sudo systemctl enable "$service" 2>/dev/null && \
           sudo systemctl start "$service" 2>/dev/null; then
            log_info "✓ $service enabled and started (system)"
            return 0
        else
            log_warn "Failed to enable/start $service (system)"
            return 1
        fi
    fi
}

# Export functions for use in other scripts
export -f log_error log_info log_warn log_step log_success log_section
export -f check_arch check_internet check_sudo
export -f verify_package verify_command
export -f install_packages enable_service
