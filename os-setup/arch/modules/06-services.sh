#!/bin/bash

##############################################################################
# Module: System Services Configuration
# Configures and enables essential system services
##############################################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

configure_pipewire() {
    log_step "Configuring Pipewire audio..."
    
    enable_service pipewire true
    enable_service pipewire-pulse true
    enable_service wireplumber true
    
    log_info "Pipewire audio configured"
}

configure_bluetooth() {
    log_step "Configuring Bluetooth (BlueZ)..."
    
    if enable_service bluetooth false; then
        log_info "Bluetooth configured"
        return 0
    else
        log_warn "Bluetooth configuration had issues"
        return 1
    fi
}

configure_power_management() {
    log_step "Configuring power profile management..."
    
    if enable_service power-profiles-daemon false; then
        log_info "Power profile management configured"
        return 0
    else
        log_warn "Power profile management configuration had issues"
        return 1
    fi
}

configure_sddm() {
    log_step "Configuring SDDM display manager..."
    
    if ! pacman -Q sddm >/dev/null 2>&1; then
        log_warn "SDDM not installed, skipping configuration"
        return 1
    fi
    
    # Verify Hyprland is installed (required for SDDM to have a session)
    if ! pacman -Q hyprland >/dev/null 2>&1; then
        log_warn "Hyprland not installed - SDDM needs a desktop session to start"
        log_warn "Install Hyprland first before enabling SDDM"
        return 1
    fi
    
    # Create SDDM configuration directory
    sudo mkdir -p /etc/sddm.conf.d
    
    # Create SDDM configuration to prevent crashes
    log_step "Creating SDDM configuration..."
    if ! sudo tee /etc/sddm.conf.d/10-wayland.conf > /dev/null <<'EOF'
[General]
# Use Wayland for SDDM itself (better for Wayland compositors)
DisplayServer=wayland

# Set default session to Hyprland
DefaultSession=hyprland.desktop

# Number of login attempts
Numlock=on

[Wayland]
# Compositor command for SDDM greeter
CompositorCommand=kwin_wayland --no-global-shortcuts --no-kactivities --no-lockscreen --locale1

[Theme]
# Use breeze theme (comes with sddm)
Current=breeze

[Users]
# Remember last logged in user
RememberLastUser=true
RememberLastSession=true
EOF
    then
        log_error "Failed to create SDDM configuration file"
        return 1
    fi
    log_info "Created SDDM configuration at /etc/sddm.conf.d/10-wayland.conf"
    
    # Verify Hyprland session file exists
    if [ ! -f /usr/share/wayland-sessions/hyprland.desktop ]; then
        log_warn "Hyprland session file not found at /usr/share/wayland-sessions/hyprland.desktop"
        log_warn "SDDM may crash on login. Hyprland package should create this file."
        log_info "You may need to reinstall Hyprland: sudo pacman -S hyprland"
    else
        log_info "✓ Hyprland session file found"
    fi
    
    # Enable SDDM but DO NOT start it (would take over display during install)
    if enable_service_no_start sddm false; then
        log_info "SDDM display manager enabled for next boot"
        log_warn ""
        log_warn "SDDM Configuration Summary:"
        log_warn "  - Display server: Wayland"
        log_warn "  - Default session: Hyprland"
        log_warn "  - Will start automatically after reboot"
        log_warn "  - Do NOT manually start SDDM during installation"
        return 0
    else
        log_warn "SDDM configuration had issues"
        return 1
    fi
}

configure_docker() {
    log_step "Configuring Docker..."
    
    if ! pacman -Q docker >/dev/null 2>&1; then
        log_warn "Docker not installed, skipping configuration"
        return 1
    fi
    
    if enable_service docker false; then
        # Add user to docker group
        sudo usermod -aG docker $USER 2>/dev/null || log_warn "Could not add user to docker group"
        log_info "Docker configured (logout/login required for group changes)"
        return 0
    else
        log_warn "Docker configuration had issues"
        return 1
    fi
}

main() {
    log_section "System Services Configuration"
    
    local failed_services=()
    
    configure_pipewire || failed_services+=("pipewire")
    configure_bluetooth || failed_services+=("bluetooth")
    configure_power_management || failed_services+=("power-profiles-daemon")
    configure_sddm || failed_services+=("sddm")
    configure_docker || failed_services+=("docker")
    
    if [ ${#failed_services[@]} -eq 0 ]; then
        log_success "All system services configured successfully"
        log_warn ""
        log_warn "========================================"
        log_warn "SDDM Display Manager Configuration"
        log_warn "========================================"
        log_warn "SDDM is enabled but NOT started"
        log_warn "  - Will start automatically after reboot"
        log_warn "  - Configured for Wayland + Hyprland"
        log_warn "  - Do NOT manually start SDDM now"
        log_warn ""
        log_warn "If SDDM crashes after reboot:"
        log_warn "  1. Press Ctrl+Alt+F2 to get to TTY"
        log_warn "  2. Check logs: journalctl -u sddm -b"
        log_warn "  3. Verify session: ls /usr/share/wayland-sessions/"
        log_warn "  4. Disable SDDM: sudo systemctl disable sddm"
        log_warn "  5. Start Hyprland manually: Hyprland"
        log_warn "========================================"
        return 0
    else
        log_warn "Some services failed to configure:"
        for svc in "${failed_services[@]}"; do
            log_warn "  - $svc"
        done
        log_warn ""
        log_warn "IMPORTANT: Reboot required for display manager and service changes"
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
