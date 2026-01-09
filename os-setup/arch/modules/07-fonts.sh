#!/bin/bash

##############################################################################
# Module: Fonts Installation
# Installs Nerd Fonts and other required fonts
##############################################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

install_hack_nerd_font() {
    log_step "Installing Hack Nerd Font..."
    
    # Check if already installed
    if command -v fc-list >/dev/null 2>&1 && fc-list 2>/dev/null | grep -q "Hack Nerd"; then
        log_info "Hack Nerd Font already installed"
        return 0
    fi
    
    local tmp_dir="/tmp/font-install-$$"
    mkdir -p "$tmp_dir"
    cd "$tmp_dir"
    
    log_step "Downloading Hack Nerd Font..."
    if wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Hack.zip; then
        log_step "Extracting and installing font..."
        sudo unzip -q Hack.zip -d /usr/share/fonts/hack-nerd-font
        
        if command -v fc-cache >/dev/null 2>&1; then
            sudo fc-cache -fv >/dev/null 2>&1
        fi
        
        cd /
        rm -rf "$tmp_dir"
        log_success "Hack Nerd Font installed"
        return 0
    else
        log_error "Failed to download Hack Nerd Font"
        cd /
        rm -rf "$tmp_dir"
        return 1
    fi
}

install_getnf() {
    log_step "Installing getnf font installer..."
    
    if [ -f ~/.local/bin/getnf ]; then
        log_info "getnf already installed"
        return 0
    fi
    
    if curl -fsSL https://raw.githubusercontent.com/MounirErhili/getnf/main/install.sh 2>/dev/null | bash; then
        log_success "getnf installed"
        return 0
    else
        log_warn "getnf installation failed"
        return 1
    fi
}

main() {
    log_section "Fonts Installation"
    
    local success=true
    
    install_hack_nerd_font || success=false
    install_getnf || success=false
    
    if [ "$success" = true ]; then
        log_success "Font installation complete"
        return 0
    else
        log_warn "Some fonts failed to install"
        return 1
    fi
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    check_arch || exit 1
    main
    exit $?
fi
