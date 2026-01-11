#!/bin/bash

##############################################################################
# Module: Development Tools & Version Managers
# Installs pyenv, nvm, opencode, and other development tools
##############################################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

install_pyenv() {
    log_step "Installing pyenv..."
    
    if [ -d ~/.pyenv ]; then
        log_info "pyenv already installed"
        return 0
    fi
    
    if git clone https://github.com/pyenv/pyenv.git ~/.pyenv 2>/dev/null; then
        log_success "pyenv installed"
        return 0
    else
        log_error "Failed to install pyenv"
        return 1
    fi
}

install_nvm() {
    log_step "Installing nvm..."
    
    if [ -d ~/.nvm ]; then
        log_info "nvm already installed"
        return 0
    fi
    
    if curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh 2>/dev/null | bash; then
        log_success "nvm installed"
        return 0
    else
        log_error "Failed to install nvm"
        return 1
    fi
}

install_opencode() {
    log_step "Installing opencode..."
    
    if [ -f ~/.opencode/bin/opencode ]; then
        log_info "opencode already installed"
        return 0
    fi
    
    if curl -fsSL https://opencode.ai/install 2>/dev/null | bash; then
        log_success "opencode installed"
        return 0
    else
        log_warn "Failed to install opencode"
        return 1
    fi
}

configure_zsh() {
    log_step "Setting Zsh as default shell..."
    
    if [ "$SHELL" = "/bin/zsh" ] || [ "$SHELL" = "/usr/bin/zsh" ]; then
        log_info "Zsh already set as default shell"
        return 0
    fi
    
    if sudo usermod -s /bin/zsh $USER 2>/dev/null; then
        log_success "Zsh set as default shell (logout/login required)"
        return 0
    else
        log_warn "Failed to set Zsh as default shell"
        return 1
    fi
}

main() {
    log_section "Development Tools & Version Managers"
    
    local failed_tools=()
    
    install_pyenv || failed_tools+=("pyenv")
    install_nvm || failed_tools+=("nvm")
    install_opencode || failed_tools+=("opencode")
    configure_zsh || failed_tools+=("zsh-config")
    
    if [ ${#failed_tools[@]} -eq 0 ]; then
        log_success "All development tools installed successfully"
        return 0
    else
        log_warn "Some tools failed to install:"
        for tool in "${failed_tools[@]}"; do
            log_warn "  - $tool"
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
