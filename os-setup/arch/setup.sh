#!/bin/bash

##############################################################################
# Arch Linux Setup Script (Compatibility Wrapper)
# This script now redirects to the new modular installation system
##############################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NEW_INSTALLER="$SCRIPT_DIR/install.sh"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}[INFO]${NC} This script has been updated to use a modular installation system"
echo -e "${BLUE}[INFO]${NC} Redirecting to: $NEW_INSTALLER"
echo ""

if [ ! -f "$NEW_INSTALLER" ]; then
    echo -e "${YELLOW}[WARN]${NC} New installer not found at: $NEW_INSTALLER"
    echo -e "${YELLOW}[WARN]${NC} Falling back to old installation method..."
    
    # Determine which old script to run
    if [ "$1" = "--desktop" ] || [ "$1" = "-d" ]; then
        exec "$SCRIPT_DIR/install_arch_desktop.sh"
    else
        exec "$SCRIPT_DIR/install_arch_services.sh"
    fi
fi

# Map old arguments to new system
NEW_ARGS=()

for arg in "$@"; do
    case $arg in
        --desktop|-d)
            NEW_ARGS+=("--desktop")
            ;;
        --minimal|-m)
            NEW_ARGS+=("--minimal")
            ;;
        *)
            NEW_ARGS+=("$arg")
            ;;
    esac
done

# If no arguments provided, show info
if [ ${#NEW_ARGS[@]} -eq 0 ]; then
    echo -e "${GREEN}Available installation modes:${NC}"
    echo "  --minimal   Install only core packages (no desktop environment)"
    echo "  --desktop   Install desktop environment and essentials"
    echo "  --full      Install everything (default)"
    echo ""
    echo "Running with default (full) installation..."
    echo ""
    NEW_ARGS+=("--full")
fi

# Execute new installer
exec "$NEW_INSTALLER" "${NEW_ARGS[@]}"
