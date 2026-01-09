#!/bin/bash

##############################################################################
# Module: AUR Helper (yay)
# Installs yay AUR helper for accessing AUR packages
##############################################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

main() {
    log_section "AUR Helper (yay) Installation"
    
    # Check if yay is already installed
    if command -v yay &> /dev/null; then
        log_info "yay is already installed"
        yay --version
        return 0
    fi
    
    log_step "Installing yay from AUR..."
    
    # Ensure base-devel is installed
    if ! pacman -Q base-devel >/dev/null 2>&1; then
        log_step "Installing base-devel (required for AUR builds)..."
        install_packages base-devel
    fi
    
    # Setup build directory
    local build_dir="/tmp/yay-build-$$"
    mkdir -p "$build_dir"
    
    # Clone and build
    log_step "Cloning yay repository..."
    if ! git clone https://aur.archlinux.org/yay.git "$build_dir" 2>&1; then
        log_error "Failed to clone yay repository"
        rm -rf "$build_dir"
        return 1
    fi
    
    log_step "Building yay (this may take a moment)..."
    cd "$build_dir"
    
    if makepkg -si --noconfirm 2>&1; then
        log_success "yay built and installed successfully"
        cd /
        rm -rf "$build_dir"
        
        # Verify installation
        if command -v yay &> /dev/null; then
            yay --version
            return 0
        else
            log_error "yay command not found after installation"
            return 1
        fi
    else
        log_error "Failed to build yay"
        cd /
        rm -rf "$build_dir"
        return 1
    fi
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    check_arch || exit 1
    check_sudo || exit 1
    main
    exit $?
fi
