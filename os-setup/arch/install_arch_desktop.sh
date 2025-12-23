#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Color output for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Check if running on an Arch-based system by checking for /etc/arch-release
if [ ! -f /etc/arch-release ]; then
    log_error "This script is intended for Arch-based systems."
    exit 1
fi

log_info "Starting Arch Linux desktop environment setup..."

# Check for internet connectivity
if ! ping -c 1 8.8.8.8 &> /dev/null; then
    log_warn "No internet connectivity detected. Some features may fail."
    log_warn "Please ensure you have internet access before continuing."
fi

# Check if sudo is available
if ! command -v sudo >/dev/null 2>&1; then
    log_error "sudo is not installed. This script requires sudo for privilege escalation."
    exit 1
fi

# Install Ansible if it's not already installed.
if ! command -v ansible >/dev/null 2>&1; then
    log_info "Ansible is not installed. Installing now with pacman..."
    # Update package manager
    sudo pacman -Sy --noconfirm
    sudo pacman -S --noconfirm ansible
    if [ $? -ne 0 ]; then
        log_error "Failed to install Ansible"
        exit 1
    fi
else
    log_info "Ansible is already installed."
fi

log_info "Running Ansible playbook to provision machine..."
# Get the directory of the script.
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Verify playbook exists
if [ ! -f "${SCRIPT_DIR}/arch_desktop_setup.yml" ]; then
    log_error "Playbook not found at ${SCRIPT_DIR}/arch_desktop_setup.yml"
    exit 1
fi

# Run the playbook from the script's directory.
# The playbook will handle privilege escalation.
if ! ansible-playbook "${SCRIPT_DIR}/arch_desktop_setup.yml" --ask-become-pass; then
    log_error "Ansible playbook execution failed"
    exit 1
fi

log_info "Validating shell configuration..."
if ! zsh -x -c "source ~/.zshrc" 2>/dev/null; then
    log_warn "Shell configuration validation had issues, but setup may still be complete"
fi

log_info "Provisioning complete."
log_info "Please restart your terminal or run 'exec zsh' to load the new configuration."