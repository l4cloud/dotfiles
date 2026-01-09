#!/bin/bash

##############################################################################
# Main Installation Script for Dotfiles Setup
# Detects OS and routes to appropriate installation scripts
# Usage: ./install.sh [--desktop] [--nvidia]
##############################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Function to print colored output
print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${YELLOW}ℹ${NC} $1"
}

print_step() {
    echo -e "${BLUE}→${NC} $1"
}

# Show help
show_help() {
    cat << EOF
╔════════════════════════════════════════════════════════════════════════════╗
║                      Dotfiles Installation Script                          ║
╚════════════════════════════════════════════════════════════════════════════╝

USAGE:
    ./install.sh [OPTIONS]

OPTIONS:
    --desktop       Install desktop environment (Hyprland) after services
    --nvidia        Enable NVIDIA driver configuration (requires GPU detection)
    --help          Show this help message

EXAMPLES:
    # Services only (development tools)
    ./install.sh

    # Services + Desktop environment
    ./install.sh --desktop

    # Services + Desktop + NVIDIA drivers
    ./install.sh --desktop --nvidia

SUPPORTED SYSTEMS:
    • Arch Linux (with/without desktop)
    • Fedora Linux (with/without desktop)
    • Ubuntu 22.04+ (with/without desktop)

EOF
}

# Parse arguments
INSTALL_DESKTOP=0
INSTALL_NVIDIA=0

while [[ $# -gt 0 ]]; do
    case $1 in
        --desktop)
            INSTALL_DESKTOP=1
            shift
            ;;
        --nvidia)
            INSTALL_NVIDIA=1
            shift
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Detect operating system
detect_os() {
    if [ -f /etc/arch-release ]; then
        echo "arch"
    elif [ -f /etc/fedora-release ]; then
        echo "fedora"
    elif [ -f /etc/os-release ]; then
        . /etc/os-release
        if [ "$ID" = "ubuntu" ]; then
            echo "ubuntu"
        else
            echo "unknown"
        fi
    else
        echo "unknown"
    fi
}

# Check for NVIDIA GPU
check_nvidia_gpu() {
    if command -v lspci >/dev/null 2>&1; then
        if lspci | grep -i nvidia >/dev/null 2>&1; then
            return 0
        fi
    fi
    return 1
}

# Main script logic
main() {
    print_info "Detecting operating system..."
    OS=$(detect_os)

    case "$OS" in
        arch)
            print_success "Detected Arch Linux"
            SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
            
            # Use modular installation system
            if [ "$INSTALL_DESKTOP" = "1" ]; then
                print_step "Installing full system (development + desktop)..."
                bash "${SCRIPT_DIR}/arch/install.sh" --desktop
            else
                print_step "Installing development environment only..."
                bash "${SCRIPT_DIR}/arch/install.sh" --minimal
            fi
            ;;
            
        fedora)
            print_success "Detected Fedora"
            SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
            
            # Install services (always)
            print_step "Installing development environment..."
            bash "${SCRIPT_DIR}/fedora/install_fedora_services.sh"
            
            # Install desktop if requested
            if [ "$INSTALL_DESKTOP" = "1" ]; then
                print_step "Installing desktop environment..."
                bash "${SCRIPT_DIR}/fedora/install_fedora_desktop.sh"
            fi
            ;;
            
        ubuntu)
            print_success "Detected Ubuntu"
            SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
            
            # Install services (always)
            print_step "Installing development environment..."
            bash "${SCRIPT_DIR}/ubuntu/install_ubuntu_services.sh"
            
            # Install desktop if requested
            if [ "$INSTALL_DESKTOP" = "1" ]; then
                print_step "Installing desktop environment..."
                bash "${SCRIPT_DIR}/ubuntu/install_ubuntu_desktop.sh"
            fi
            ;;
            
        *)
            print_error "Unsupported operating system."
            print_info "Supported systems: Arch Linux, Fedora, Ubuntu 22.04+"
            exit 1
            ;;
    esac

    echo ""
    print_success "Installation complete!"
    echo ""
    
    if [ "$INSTALL_DESKTOP" = "1" ]; then
        print_info "Desktop environment installed. Next steps:"
        print_info "  1. Log out and back in to apply changes"
        print_info "  2. Restart your system: sudo reboot"
        if check_nvidia_gpu && [ "$INSTALL_NVIDIA" = "1" ]; then
            print_info "  3. NVIDIA drivers have been configured"
        fi
    else
        print_info "Development environment installed. Next steps:"
        print_info "  1. Log out and back in to apply changes"
        print_info "  2. To install desktop environment: ./install.sh --desktop"
    fi
    
    echo ""
}

# Run main function
main "$@"
