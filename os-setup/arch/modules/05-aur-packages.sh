#!/bin/bash

##############################################################################
# Module: AUR Packages
# Installs packages from AUR using yay
##############################################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

AUR_PACKAGES=(
    lazygit
    wlogout
)

main() {
    log_section "AUR Packages Installation"
    
    # Check if yay is available
    if ! command -v yay &> /dev/null; then
        log_error "yay is not installed. Cannot install AUR packages."
        log_info "Run module 04-yay.sh first"
        return 1
    fi
    
    local failed_packages=()
    
    for pkg in "${AUR_PACKAGES[@]}"; do
        log_step "Installing $pkg from AUR..."
        if yay -S --noconfirm "$pkg" 2>&1; then
            log_info "✓ $pkg installed"
        else
            log_warn "✗ Failed to install $pkg"
            failed_packages+=("$pkg")
        fi
    done
    
    if [ ${#failed_packages[@]} -eq 0 ]; then
        log_success "All AUR packages installed successfully"
        return 0
    else
        log_warn "Some AUR packages failed to install:"
        for pkg in "${failed_packages[@]}"; do
            log_warn "  - $pkg"
        done
        return 1
    fi
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    check_arch || exit 1
    main
    exit $?
fi
