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
        opencl-nvidia
        cuda
        libvdpau
        libva-nvidia-driver
    )
    
    if install_packages "${nvidia_packages[@]}"; then
        log_success "NVIDIA packages installed"
        return 0
    else
        log_error "Failed to install NVIDIA packages"
        return 1
    fi
}

configure_nvidia_modules() {
    log_step "Configuring NVIDIA kernel modules..."
    
    # Create modprobe config
    sudo tee /etc/modprobe.d/nvidia.conf > /dev/null <<'EOF'
# Enable NVIDIA DRM kernel mode setting
options nvidia_drm modeset=1
options nvidia_drm fbdev=1
EOF
    
    # Update mkinitcpio
    if ! grep -q "nvidia nvidia_modeset nvidia_uvm nvidia_drm" /etc/mkinitcpio.conf; then
        sudo sed -i 's/^MODULES=.*/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
        log_info "Added NVIDIA modules to mkinitcpio.conf"
    else
        log_info "NVIDIA modules already in mkinitcpio.conf"
    fi
    
    # Regenerate initramfs
    log_step "Regenerating initramfs..."
    if sudo mkinitcpio -P 2>&1; then
        log_success "Initramfs regenerated"
        return 0
    else
        log_warn "Initramfs regeneration had issues"
        return 1
    fi
}

configure_nvidia_environment() {
    log_step "Configuring NVIDIA environment variables..."
    
    sudo tee /etc/environment.d/90-nvidia.conf > /dev/null <<'EOF'
# NVIDIA environment variables for Hyprland - Performance & Compatibility
LIBVA_DRIVER_NAME=nvidia
XDG_SESSION_TYPE=wayland
GBM_BACKEND=nvidia-drm
__GLX_VENDOR_LIBRARY_NAME=nvidia
WLR_NO_HARDWARE_CURSORS=1

# Performance optimization variables
__NV_PRIME_RENDER_OFFLOAD=1
__VK_LAYER_NV_optimus=NVIDIA_only
__GL_VRR_ALLOWED=1
PROTON_ENABLE_NVAPI=1
PROTON_ENABLE_NGX_UPSCALING=1

# Video acceleration and codec support
VDPAU_DRIVER=nvidia
NVHPC_CUDA_ENABLE=1

# OpenGL and Vulkan optimizations
__GL_THREADED_OPTIMIZATIONS=1
__GL_SHADER_DISK_CACHE=1
__GL_SHADER_DISK_CACHE_PATH=/tmp

# Wayland specific optimizations
WLR_DRM_NO_ATOMIC=1
WLR_RENDERER=vulkan
EOF
    
    log_success "NVIDIA environment variables configured"
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
    log_warn "System reboot required for NVIDIA changes to take effect"
    return 0
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    check_arch || exit 1
    check_sudo || exit 1
    main
    exit $?
fi
