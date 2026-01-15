#!/bin/bash

##############################################################################
# Arch Linux Hyprland Ecosystem Installer
# Runs Hyprland add-on modules sequentially with clear output and summary
##############################################################################

set -euo pipefail

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULES_DIR="$SCRIPT_DIR/modules"

# Source common functions
source "$MODULES_DIR/common.sh"

# Tracking
SUCCESSFUL_MODULES=()
FAILED_MODULE=""

# Installer focuses on Hyprland ecosystem by default
INSTALL_MODE="de"
DE_ENABLED=true
SKIP_DESKTOP=false

# Module definitions
# Format: "priority:module_file:description:required"
# Sorted by priority for readability
declare -a MODULES=(
    "10:02-yay.sh:AUR Helper (yay):true"
    "20:06-devtools.sh:Development Tools:true"
    "30:08-dotfiles.sh:Dotfiles Installation:true"
    "40:01-desktop.sh:Desktop Environment Packages:de"
    "50:03-aur.sh:AUR Packages:de"
    "60:04-services.sh:User Services (PipeWire):de"
    "70:05-fonts.sh:Fonts Installation:de"
    "80:07-flatpak.sh:Flatpak Applications:de"
)

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help|-h)
                show_help
                exit 0
                ;;
            --skip-desktop)
                SKIP_DESKTOP=true
                shift
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    export INSTALL_MODE
    export DE_ENABLED
    export SKIP_DESKTOP
}

show_help() {
    cat <<EOF
Arch Linux Hyprland Ecosystem Installer

Usage: $0 [OPTIONS]

Options:
    --help, -h          Show this help message
    --skip-desktop      Skip desktop environment apps/modules (for WSL/headless)

Behavior:
    Default: Installs Hyprland ecosystem programs (waybar, swww, swaync, hypridle, hyprlock, thunar, wofi, pywal, etc.), fonts/devtools, Flatpak, dotfiles; configures PipeWire user services; writes SDDM Hyprland session default if SDDM/Hyprland are present.

Notes:
    Core system configuration (kernel, drivers, mkinitcpio, display manager enablement) is not handled here. Manage these via Archinstall or manually.

Examples:
    $0                      # Install Hyprland ecosystem

EOF
}

# Decide if module should run based on tag and SKIP_DESKTOP
should_install_module() {
    local required="$1"
    if [[ "$SKIP_DESKTOP" == true && "$required" == "de" ]]; then
        return 1
    fi
    return 0
}

# Execute a module
execute_module() {
    local module_file=$1
    local description=$2
    local module_path="$MODULES_DIR/$module_file"

    log_section "→ $description"
    log_info "Running: $module_file"

    if [ ! -f "$module_path" ]; then
        log_error "Missing: $module_path"
        FAILED_MODULE="$description (missing file)"
        return 1
    fi

    chmod +x "$module_path" 2>/dev/null || true

    local start_time=$(date +%s)
    if "$module_path"; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        log_success "$description completed in ${duration}s"
        SUCCESSFUL_MODULES+=("$description")
        echo "--------------------------------------------------------------"
        return 0
    else
        FAILED_MODULE="$description"
        log_error "$description failed"
        echo "--------------------------------------------------------------"
        return 1
    fi
}

# Print installation summary
print_summary() {
    echo ""
    echo "=============================================================="
    log_section "Summary"
    echo "=============================================================="

    if [ -z "$FAILED_MODULE" ]; then
        log_success "All modules completed successfully"
    else
        log_error "Failed: $FAILED_MODULE"
    fi

    echo ""
    log_info "Completed modules: ${#SUCCESSFUL_MODULES[@]}"
    for module in "${SUCCESSFUL_MODULES[@]}"; do
        echo "  ✓ $module"
    done
    echo "=============================================================="
}

# Main installation function
main() {
    log_section "Hyprland Ecosystem Setup"
    log_info "Script Directory: $SCRIPT_DIR"

    # Pre-flight checks
    log_step "Pre-flight checks"
    check_arch || exit 1
    check_sudo || exit 1
    check_internet || log_warn "No internet connection detected - some modules may fail"

    # Sort modules by priority
    IFS=$'\n' sorted_modules=($(sort -t: -k1 -n <<<"${MODULES[*]}"))
    unset IFS

    log_info "Modules to process: ${#sorted_modules[@]}"

    # Run modules sequentially, abort on first failure
    for module_entry in "${sorted_modules[@]}"; do
        IFS=':' read -r priority module_file description required <<< "$module_entry"
        if ! should_install_module "$required"; then
            log_info "Skipping: $description (flag --skip-desktop)"
            continue
        fi
        if ! execute_module "$module_file" "$description"; then
            print_summary
            exit 1
        fi
    done

    print_summary
    exit 0
}

# Script entry point
parse_args "$@"
main
