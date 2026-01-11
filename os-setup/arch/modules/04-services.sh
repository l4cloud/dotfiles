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


main() {
    log_section "User Services Configuration"
    
    local failed_services=()
    
    configure_pipewire || failed_services+=("pipewire")
    
    if [ ${#failed_services[@]} -eq 0 ]; then
        log_success "User services configured successfully"
        return 0
    else
        log_warn "Some services had issues:"
        for svc in "${failed_services[@]}"; do
            log_warn "  - $svc"
        done
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
