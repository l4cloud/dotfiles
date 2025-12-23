#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

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

# Detect operating system
detect_os() {
    if [ -f /etc/arch-release ]; then
        echo "arch"
    elif [ -f /etc/fedora-release ]; then
        echo "fedora"
    elif [ -f /etc/lsb-release ]; then
        if grep -qi "ubuntu" /etc/lsb-release; then
            echo "ubuntu"
        else
            echo "unknown"
        fi
    else
        echo "unknown"
    fi
}

# Main script logic
main() {
    print_info "Detecting operating system..."
    OS=$(detect_os)

    case "$OS" in
        arch)
            print_success "Detected Arch Linux"
            SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
            bash "${SCRIPT_DIR}/arch/install_arch_services.sh"
            ;;
        fedora)
            print_success "Detected Fedora"
            SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
            bash "${SCRIPT_DIR}/fedora/install_fedora_services.sh"
            ;;
        ubuntu)
            print_success "Detected Ubuntu"
            SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
            bash "${SCRIPT_DIR}/ubuntu/install_ubuntu_services.sh"
            ;;
        *)
            print_error "Unsupported operating system."
            print_info "Supported systems: Arch Linux, Fedora, Ubuntu"
            exit 1
            ;;
    esac

    print_success "OS setup provisioning complete."
}

# Run main function
main "$@"
