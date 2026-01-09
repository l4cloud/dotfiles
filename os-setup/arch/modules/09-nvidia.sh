#!/bin/bash

##############################################################################
# Module: NVIDIA Configuration
# Configures NVIDIA drivers for Hyprland (Wayland)
##############################################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

detect_nvidia() {
    if command -v lspci >/dev/null 2>&1 && lspci | grep -i nvidia >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

install_nvidia_packages() {
    log_step "Installing NVIDIA driver packages..."
    
    local nvidia_packages=(
        nvidia
        nvidia-utils
        nvidia-settings
        nvidia-dkms
        # opencl-nvidia    # Uncomment for OpenCL compute support
        # cuda             # Uncomment for CUDA development (large download ~3GB)
        libvdpau
        libva-nvidia-driver
    )
    
    if install_packages "${nvidia_packages[@]}"; then
        log_success "NVIDIA packages installed"
        return 0
    else
        log_error "Failed to install NVIDIA packages. Check your internet connection and pacman mirrors."
        return 1
    fi
}

configure_nvidia_modules() {
    log_step "Configuring NVIDIA kernel modules..."
    
    # Check if mkinitcpio.conf exists
    if [ ! -f /etc/mkinitcpio.conf ]; then
        log_error "mkinitcpio.conf not found. This is required for Arch Linux."
        log_error "Make sure you're running this on a proper Arch Linux installation."
        return 1
    fi
    
    # Create modprobe config
    if ! sudo tee /etc/modprobe.d/nvidia.conf > /dev/null <<'EOF'
# Enable NVIDIA DRM kernel mode setting
options nvidia_drm modeset=1
options nvidia_drm fbdev=1
EOF
    then
        log_error "Failed to create /etc/modprobe.d/nvidia.conf. Check sudo permissions."
        return 1
    fi
    log_info "Created NVIDIA modprobe configuration"
    
    # Backup mkinitcpio.conf before modification
    if [ -f /etc/mkinitcpio.conf ] && [ ! -f /etc/mkinitcpio.conf.backup ]; then
        sudo cp /etc/mkinitcpio.conf /etc/mkinitcpio.conf.backup
        log_info "Backed up mkinitcpio.conf"
    fi
    
    # Append NVIDIA modules to existing MODULES array (preserves other modules like Intel/AMD)
    if ! grep -q "nvidia nvidia_modeset nvidia_uvm nvidia_drm" /etc/mkinitcpio.conf; then
        # Check if MODULES line exists
        if ! grep -q "^MODULES=" /etc/mkinitcpio.conf; then
            log_error "Could not find MODULES= line in /etc/mkinitcpio.conf"
            return 1
        fi
        
        # Append NVIDIA modules to existing MODULES array
        if sudo sed -i '/^MODULES=/ s/)/ nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf; then
            log_info "Added NVIDIA modules to mkinitcpio.conf (preserving existing modules)"
            log_info "New MODULES line:"
            grep "^MODULES=" /etc/mkinitcpio.conf | sed 's/^/  /'
        else
            log_error "Failed to modify mkinitcpio.conf. Restore from /etc/mkinitcpio.conf.backup if needed."
            return 1
        fi
    else
        log_info "NVIDIA modules already present in mkinitcpio.conf"
    fi
    
    # Regenerate initramfs
    log_step "Regenerating initramfs..."
    local mkinitcpio_output
    if ! mkinitcpio_output=$(sudo mkinitcpio -P 2>&1); then
        log_error "Initramfs regeneration failed. Output:"
        echo "$mkinitcpio_output"
        log_error "This may indicate missing kernel headers or module compilation issues."
        log_error "Try: sudo pacman -S linux-headers"
        return 1
    fi
    log_success "Initramfs regenerated successfully"
    return 0
}

configure_nvidia_environment() {
    log_step "Configuring NVIDIA environment variables..."
    
    if ! sudo tee /etc/environment.d/90-nvidia.conf > /dev/null <<'EOF'
# NVIDIA environment variables for Wayland/Hyprland
# Essential variables for proper NVIDIA driver operation
LIBVA_DRIVER_NAME=nvidia
GBM_BACKEND=nvidia-drm
__GLX_VENDOR_LIBRARY_NAME=nvidia

# Gaming and performance optimizations (safe for RTX 40 series)
__GL_THREADED_OPTIMIZATIONS=1
__GL_SHADER_DISK_CACHE=1
__GL_SHADER_DISK_CACHE_PATH=/tmp
__GL_VRR_ALLOWED=1

# Video acceleration
VDPAU_DRIVER=nvidia

# Vulkan renderer for Wayland compositors
WLR_RENDERER=vulkan

# Prime render offload (for hybrid graphics - safe to set even on discrete GPU)
__NV_PRIME_RENDER_OFFLOAD=1
__VK_LAYER_NV_optimus=NVIDIA_only

# Proton/Gaming support
PROTON_ENABLE_NVAPI=1
PROTON_ENABLE_NGX_UPSCALING=1
EOF
    then
        log_error "Failed to create /etc/environment.d/90-nvidia.conf. Check sudo permissions."
        return 1
    fi
    
    log_success "NVIDIA environment variables configured"
    log_info "Configuration file: /etc/environment.d/90-nvidia.conf"
    return 0
}

main() {
    log_section "NVIDIA Configuration"
    
    if ! detect_nvidia; then
        log_info "No NVIDIA GPU detected, skipping NVIDIA configuration"
        return 0
    fi
    
    log_info "NVIDIA GPU detected"
    
    local gpu_info=$(lspci | grep -i nvidia | head -1)
    log_info "GPU: $gpu_info"
    
    if ! install_nvidia_packages; then
        return 1
    fi
    
    if ! configure_nvidia_modules; then
        return 1
    fi
    
    if ! configure_nvidia_environment; then
        return 1
    fi
    
    log_success "NVIDIA configuration complete"
    echo ""
    log_warn "=========================================="
    log_warn "CRITICAL: REBOOT REQUIRED"
    log_warn "=========================================="
    log_warn "NVIDIA kernel modules will NOT work until you reboot!"
    log_warn ""
    log_warn "Before starting Hyprland/Wayland:"
    log_warn "  1. Complete the entire installation"
    log_warn "  2. Run: sudo reboot"
    log_warn "  3. After reboot, NVIDIA modules will be loaded"
    log_warn ""
    log_warn "If you try to start Hyprland NOW, you will see:"
    log_warn "  'failed to open nvidia-drm: No such file or directory'"
    log_warn ""
    log_warn "To verify NVIDIA is loaded after reboot:"
    log_warn "  lsmod | grep nvidia"
    log_warn "=========================================="
    echo ""
    return 0
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    check_arch || exit 1
    check_sudo || exit 1
    main
    exit $?
fi
