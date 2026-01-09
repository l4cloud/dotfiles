#!/bin/bash

##############################################################################
# Arch Linux Master Installation Script
# Orchestrates modular installation with comprehensive error handling
##############################################################################

set -euo pipefail

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULES_DIR="$SCRIPT_DIR/modules"

# Source common functions
source "$MODULES_DIR/common.sh"

# Track installation state
declare -A MODULE_STATUS
declare -A MODULE_ERRORS
FAILED_MODULES=()
SUCCESSFUL_MODULES=()
SKIPPED_MODULES=()

# Installation mode
INSTALL_MODE="full"  # full, minimal, desktop-only

# Module definitions
# Format: "priority:module_file:description:required"
declare -a MODULES=(
    "10:01-system-update.sh:System Update:true"
    "20:02-core-packages.sh:Core Development Packages:true"
    "30:04-yay.sh:AUR Helper (yay):true"
    "40:03-desktop-packages.sh:Desktop Environment Packages:desktop"
    "50:05-aur-packages.sh:AUR Packages:false"
    "60:06-services.sh:System Services:desktop"
    "70:07-fonts.sh:Fonts Installation:false"
    "80:08-devtools.sh:Development Tools:false"
    "90:09-nvidia.sh:NVIDIA Configuration:optional"
    "100:10-wol.sh:Wake-on-LAN:optional"
    "110:11-flatpak.sh:Flatpak Applications:false"
    "120:12-dotfiles.sh:Dotfiles Installation:false"
)

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --minimal)
                INSTALL_MODE="minimal"
                shift
                ;;
            --desktop)
                INSTALL_MODE="desktop"
                shift
                ;;
            --full)
                INSTALL_MODE="full"
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

show_help() {
    cat <<EOF
Arch Linux Modular Installation Script

Usage: $0 [OPTIONS]

Options:
    --minimal       Install only core packages (no desktop environment)
    --desktop       Install desktop environment and essentials
    --full          Install everything (default)
    --help, -h      Show this help message

Installation Modes:
    minimal:  System update, core packages, yay
    desktop:  minimal + desktop packages + services + dotfiles
    full:     desktop + all optional modules

Examples:
    $0                  # Full installation
    $0 --minimal        # Minimal server setup
    $0 --desktop        # Desktop environment setup

EOF
}

# Check if module should be installed based on mode
should_install_module() {
    local required=$1
    
    case "$required" in
        true)
            return 0  # Always install
            ;;
        false)
            [ "$INSTALL_MODE" = "full" ] && return 0 || return 1
            ;;
        desktop)
            [ "$INSTALL_MODE" = "desktop" ] || [ "$INSTALL_MODE" = "full" ] && return 0 || return 1
            ;;
        optional)
            [ "$INSTALL_MODE" = "full" ] && return 0 || return 1
            ;;
        *)
            return 1
            ;;
    esac
}

# Execute a module
execute_module() {
    local module_file=$1
    local description=$2
    local module_path="$MODULES_DIR/$module_file"
    
    log_section "Running: $description"
    log_info "Module: $module_file"
    echo ""
    
    if [ ! -f "$module_path" ]; then
        log_error "Module not found: $module_path"
        MODULE_STATUS["$module_file"]="MISSING"
        MODULE_ERRORS["$module_file"]="Module file not found"
        FAILED_MODULES+=("$module_file")
        return 1
    fi
    
    if [ ! -x "$module_path" ]; then
        chmod +x "$module_path"
    fi
    
    # Execute module and capture output
    local start_time=$(date +%s)
    local output
    local exit_code=0
    
    output=$("$module_path" 2>&1) || exit_code=$?
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    echo "$output"
    echo ""
    
    if [ $exit_code -eq 0 ]; then
        MODULE_STATUS["$module_file"]="SUCCESS"
        SUCCESSFUL_MODULES+=("$description")
        log_success "$description completed in ${duration}s"
    else
        MODULE_STATUS["$module_file"]="FAILED"
        MODULE_ERRORS["$module_file"]="Exit code: $exit_code"
        FAILED_MODULES+=("$description")
        log_error "$description failed (exit code: $exit_code)"
        
        # Decide whether to continue or abort
        return $exit_code
    fi
    
    echo ""
    echo "================================================================"
    echo ""
    
    return 0
}

# Print installation summary
print_summary() {
    echo ""
    echo "================================================================================"
    log_section "Installation Summary"
    echo "================================================================================"
    echo ""
    
    log_info "Installation Mode: $INSTALL_MODE"
    echo ""
    
    if [ ${#SUCCESSFUL_MODULES[@]} -gt 0 ]; then
        log_success "Successfully Completed (${#SUCCESSFUL_MODULES[@]}):"
        for module in "${SUCCESSFUL_MODULES[@]}"; do
            echo "  ✓ $module"
        done
        echo ""
    fi
    
    if [ ${#SKIPPED_MODULES[@]} -gt 0 ]; then
        log_info "Skipped Modules (${#SKIPPED_MODULES[@]}):"
        for module in "${SKIPPED_MODULES[@]}"; do
            echo "  ○ $module"
        done
        echo ""
    fi
    
    if [ ${#FAILED_MODULES[@]} -gt 0 ]; then
        log_error "Failed Modules (${#FAILED_MODULES[@]}):"
        for module in "${FAILED_MODULES[@]}"; do
            echo "  ✗ $module"
        done
        echo ""
        
        log_error "Detailed Errors:"
        for module_file in "${!MODULE_ERRORS[@]}"; do
            log_error "  $module_file: ${MODULE_ERRORS[$module_file]}"
        done
        echo ""
    fi
    
    echo "================================================================================"
    
    if [ ${#FAILED_MODULES[@]} -eq 0 ]; then
        log_success "Installation completed successfully!"
        echo ""
        log_info "Next steps:"
        log_info "  1. Review any warnings above"
        log_info "  2. Reboot your system: sudo reboot"
        log_info "  3. Log in and verify everything works"
        echo ""
        return 0
    else
        log_error "Installation completed with errors"
        echo ""
        log_info "To retry failed modules:"
        log_info "  cd $MODULES_DIR"
        for module in "${FAILED_MODULES[@]}"; do
            log_info "  ./<module-file>.sh"
        done
        echo ""
        return 1
    fi
}

# Main installation function
main() {
    log_section "Arch Linux Modular Installation"
    echo "Installation Mode: $INSTALL_MODE"
    echo "Script Directory: $SCRIPT_DIR"
    echo ""
    
    # Pre-flight checks
    log_step "Running pre-flight checks..."
    check_arch || exit 1
    check_sudo || exit 1
    check_internet || log_warn "No internet connection detected - some modules may fail"
    echo ""
    
    # Sort modules by priority
    IFS=$'\n' sorted_modules=($(sort -t: -k1 -n <<<"${MODULES[*]}"))
    unset IFS
    
    log_info "Modules to process: ${#sorted_modules[@]}"
    echo ""
    
    # Process each module
    for module_entry in "${sorted_modules[@]}"; do
        IFS=':' read -r priority module_file description required <<< "$module_entry"
        
        # Check if module should be installed
        if ! should_install_module "$required"; then
            log_info "Skipping: $description (not required for $INSTALL_MODE mode)"
            SKIPPED_MODULES+=("$description")
            echo ""
            continue
        fi
        
        # Execute module
        if ! execute_module "$module_file" "$description"; then
            # Check if module is required
            if [ "$required" = "true" ]; then
                log_error "Required module failed: $description"
                log_error "Cannot continue installation"
                print_summary
                exit 1
            else
                log_warn "Optional module failed: $description"
                log_info "Continuing with installation..."
                echo ""
            fi
        fi
    done
    
    # Print summary
    print_summary
    
    # Return exit code based on failures
    if [ ${#FAILED_MODULES[@]} -eq 0 ]; then
        exit 0
    else
        exit 1
    fi
}

# Script entry point
parse_args "$@"
main
