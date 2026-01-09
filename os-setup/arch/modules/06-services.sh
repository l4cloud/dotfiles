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
    
    # Enable SDDM but DO NOT start it (would take over display during install)
    if enable_service_no_start sddm false; then
        log_info "SDDM display manager enabled for next boot"
        log_warn "SDDM will start after reboot - do not start it manually during installation"
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
        log_warn "IMPORTANT: SDDM display manager is enabled but NOT started"
        log_warn "  - SDDM will automatically start after reboot"
        log_warn "  - Do NOT manually start SDDM during installation"
        log_warn "  - Reboot your system when installation is complete"
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
