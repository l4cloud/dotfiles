#!/bin/bash

##############################################################################
# Module: Desktop Environment Packages
# Installs Hyprland and related desktop packages
##############################################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

DESKTOP_PACKAGES=(
    hyprland kitty hypridle waybar swww swaync
    pipewire pipewire-pulse pipewire-alsa wireplumber
    brightnessctl playerctl power-profiles-daemon
    grim slurp hyprshot hyprlock
    thunar wofi flatpak steam
    yazi p7zip poppler fd ripgrep fzf zoxide imagemagick xclip
    bluez bluez-utils blueman
    linux-headers
    python-pywal unzip tmux
)

main() {
    log_section "Desktop Environment Packages Installation"
    
    log_info "Installing Hyprland desktop environment and dependencies..."
    
    # Track failed packages
    local failed_packages=()
    
    # Try to install all packages
    if ! install_packages "${DESKTOP_PACKAGES[@]}"; then
        log_warn "Some packages failed to install from official repos"
        
        # Check which packages are missing
        for pkg in "${DESKTOP_PACKAGES[@]}"; do
            if ! pacman -Q "$pkg" >/dev/null 2>&1; then
                failed_packages+=("$pkg")
            fi
        done
    fi
    
    # Verify critical desktop packages
    log_step "Verifying critical desktop packages..."
    local all_ok=true
    
    for pkg in hyprland kitty waybar swww swaync; do
        if ! verify_package "$pkg"; then
            all_ok=false
        fi
    done
    
    # Report any failures
    if [ ${#failed_packages[@]} -gt 0 ]; then
        log_warn "The following packages could not be installed:"
        for pkg in "${failed_packages[@]}"; do
            log_warn "  - $pkg"
        done
        log_info "These may need to be installed from AUR"
    fi
    
    if [ "$all_ok" = true ]; then
        log_success "Desktop environment packages installed"
        return 0
    else
        log_error "Some critical desktop packages failed to install"
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
