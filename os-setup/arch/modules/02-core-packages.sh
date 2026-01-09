#!/bin/bash

##############################################################################
# Module: Core Development Packages
# Installs essential development tools and utilities
##############################################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

CORE_PACKAGES=(
    git curl wget
    neovim zsh tmux htop fastfetch
    jq gcc make patch unzip
    bzip2 readline sqlite openssl tk libffi xz ncurses
    python-pip stow go docker ethtool
    base-devel
)

main() {
    log_section "Core Development Packages Installation"
    
    if install_packages "${CORE_PACKAGES[@]}"; then
        log_success "Core development packages installed"
        
        # Verify critical packages
        log_step "Verifying critical packages..."
        verify_command git
        verify_command neovim
        verify_command zsh
        verify_command stow
        
        return 0
    else
        log_error "Failed to install core development packages"
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
