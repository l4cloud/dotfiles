#!/bin/bash

##############################################################################
# Module: System Update
# Updates Arch Linux system packages
##############################################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

main() {
    log_section "System Update"
    
    log_step "Updating system packages..."
    if sudo pacman -Syu --noconfirm; then
        log_success "System updated successfully"
        return 0
    else
        log_error "System update failed"
        return 1
    fi
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    check_arch || exit 1
    check_sudo || exit 1
    check_internet || log_warn "No internet connection - update may fail"
    main
    exit $?
fi
