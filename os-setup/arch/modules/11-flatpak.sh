#!/bin/bash

##############################################################################
# Module: Flatpak Applications
# Installs applications via Flatpak
##############################################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

FLATPAK_APPS=(
    "md.obsidian.Obsidian"
    "app.zen_browser.zen"
)

setup_flatpak() {
    log_step "Setting up Flatpak repository..."
    
    if ! command -v flatpak >/dev/null 2>&1; then
        log_error "Flatpak not installed"
        return 1
    fi
    
    if flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo 2>/dev/null; then
        log_info "Flathub repository configured"
        return 0
    else
        log_warn "Failed to configure Flathub repository"
        return 1
    fi
}

main() {
    log_section "Flatpak Applications Installation"
    
    if ! setup_flatpak; then
        return 1
    fi
    
    local failed_apps=()
    
    for app in "${FLATPAK_APPS[@]}"; do
        local app_name=$(echo "$app" | rev | cut -d'.' -f1 | rev)
        log_step "Installing $app_name..."
        
        if flatpak install -y flathub "$app" 2>&1; then
            log_info "✓ $app_name installed"
        else
            log_warn "✗ Failed to install $app_name"
            failed_apps+=("$app_name")
        fi
    done
    
    if [ ${#failed_apps[@]} -eq 0 ]; then
        log_success "All Flatpak applications installed"
        return 0
    else
        log_warn "Some Flatpak applications failed to install:"
        for app in "${failed_apps[@]}"; do
            log_warn "  - $app"
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
