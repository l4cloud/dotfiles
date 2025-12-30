# NVIDIA Configuration for Arch Linux

## Driver Options

### 1. nvidia (Recommended for most users)
- Latest drivers for modern GPUs (GTX 10 series and newer)
- Best performance and latest features
- Compatible with regular kernel

### 2. nvidia-lts
- Stable drivers for LTS kernel users
- More stable but potentially older features
- Good for servers or systems requiring stability

### 3. nvidia-dkms
- Dynamic Kernel Module Support
- Automatically rebuilds on kernel updates
- Good for custom kernels or frequent kernel changes

### 4. nvidia-open
- Open source kernel modules (RTX 20 series and newer)
- Limited to newer hardware
- Still requires proprietary userspace components

## Required Kernel Modules

The installation script now includes these essential NVIDIA kernel modules:

- **nvidia** - Main kernel module
- **nvidia_modeset** - Mode setting support
- **nvidia_uvm** - Unified Virtual Memory for CUDA
- **nvidia_drm** - DRM integration for Wayland
- **nvidia-dkms** - Dynamic Kernel Module Support (auto-rebuild on kernel updates)

## Prerequisites for Kernel Module Building

- **linux-headers** - Required for building any kernel modules (DKMS, NVIDIA)
- **base-devel** - Development tools for compilation (usually in base system)

Note: The script installs `linux-headers` automatically when NVIDIA GPU is detected.

## Additional Packages Installed

- **opencl-nvidia** - OpenCL support
- **cuda** - CUDA toolkit for GPU computing
- **libvdpau** - VDPAU video acceleration
- **libva-nvidia-driver** - VA-API video acceleration
- **nvtop** - GPU monitoring utility

## Post-Installation Steps

1. **Reboot** after driver installation
2. **Verify installation**: `nvidia-smi`
3. **Check kernel modules**: `lsmod | grep nvidia`
4. **Verify DKMS**: `sudo dkms status`
5. **Configure Hyprland**: The playbook automatically sets required environment variables
6. **Verify environment variables**: Check `/etc/environment.d/90-nvidia.conf`

## Environment Variables Explained

The script automatically configures these environment variables in `/etc/environment.d/90-nvidia.conf`:

### Core Variables (Required)
- `LIBVA_DRIVER_NAME=nvidia` - VA-API video acceleration
- `XDG_SESSION_TYPE=wayland` - Wayland session type
- `GBM_BACKEND=nvidia-drm` - Generic Buffer Manager backend
- `__GLX_VENDOR_LIBRARY_NAME=nvidia` - OpenGL vendor library
- `WLR_NO_HARDWARE_CURSORS=1` - Fix cursor issues on Wayland

### Performance Optimizations
- `__NV_PRIME_RENDER_OFFLOAD=1` - Optimus laptop GPU switching
- `__VK_LAYER_NV_optimus=NVIDIA_only` - Force Vulkan on NVIDIA
- `__GL_VRR_ALLOWED=1` - Variable refresh rate (G-Sync)
- `__GL_THREADED_OPTIMIZATIONS=1` - Multi-threaded OpenGL
- `__GL_SHADER_DISK_CACHE=1` - Cache compiled shaders
- `__GL_SHADER_DISK_CACHE_PATH=/tmp` - Shader cache location

### Video Acceleration
- `VDPAU_DRIVER=nvidia` - VDPAU video backend
- `CLGL_SHARE_GL_RESOURCES=1` - OpenCL/OpenGL resource sharing

### Gaming Enhancements
- `PROTON_ENABLE_NVAPI=1` - Enable NVIDIA API in Proton
- `PROTON_ENABLE_NGX_UPSCALING=1` - Enable DLSS/NGX upscaling

### Wayland-Specific
- `WLR_DRM_NO_ATOMIC=1` - DRM compatibility mode
- `WLR_RENDERER=vulkan` - Use Vulkan renderer when possible

### Memory & Performance
- `__GL_IGNORE_MIPMAP_LEVEL=1` - Texture optimization
- `__GL_MAX_TEXTURE_UNITS=32` - Increase texture units
- `__GL_HEAP_MEMORY_LIMIT_KB=1048576` - OpenGL memory limit

### Frame Sync
- `__GL_SYNC_TO_VBLANK=0` - Disable vertical sync (let apps control)
- `__NV_REGISTERS=0` - Power management optimization

## Manual Configuration (if needed)

### For Hyprland specifically:
```bash
# Add to ~/.config/hypr/hyprland.conf
env = LIBVA_DRIVER_NAME,nvidia
env = XDG_SESSION_TYPE,wayland
env = GBM_BACKEND,nvidia-drm
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
env = WLR_NO_HARDWARE_CURSORS,1

# Performance optimizations
env = __NV_PRIME_RENDER_OFFLOAD,1
env = __VK_LAYER_NV_optimus,NVIDIA_only
env = __GL_VRR_ALLOWED,1
env = __GL_THREADED_OPTIMIZATIONS,1
env = __GL_SHADER_DISK_CACHE,1
env = __GL_SHADER_DISK_CACHE_PATH,/tmp

# Video acceleration
env = VDPAU_DRIVER,nvidia
env = CLGL_SHARE_GL_RESOURCES,1

# Gaming optimizations
env = PROTON_ENABLE_NVAPI,1
env = PROTON_ENABLE_NGX_UPSCALING,1

# Wayland optimizations
env = WLR_DRM_NO_ATOMIC,1
env = WLR_RENDERER,vulkan
```

### For general NVIDIA optimization:
```bash
# Add to /etc/X11/xorg.conf.d/20-nvidia.conf (if using X11)
Section "Device"
    Identifier "NVIDIA Card"
    Driver "nvidia"
    Option "NoLogo" "true"
    Option "UseEDID" "false"
    Option "ConnectedMonitor" "DFP"
EndSection
```

## Troubleshooting

### Common Issues:
1. **Black screen after installation**: Try adding `nvidia-drm.modeset=1` to kernel parameters
2. **Missing kernel modules**: Check `lsmod | grep nvidia` and rebuild with `sudo mkinitcpio -P`
3. **DKMS not working**: Verify `sudo dkms status` and rebuild with `sudo dkms autoinstall`
4. **Wayland issues**: Ensure environment variables are set correctly
5. **Performance issues**: Consider switching between driver versions
6. **Suspend/resume problems**: May need additional kernel parameters

### Module-Specific Issues:
- **nvidia_uvm not loaded**: Run `sudo modprobe nvidia_uvm` and check `/dev/nvidia-uvm`
- **DRM issues**: Ensure `nvidia-drm.modeset=1` is in kernel cmdline
- **CUDA not working**: Check `nvcc --version` and ensure `nvidia_uvm` module is loaded
- **DKMS build failures**: Ensure `linux-headers` installed: `pacman -Q linux-headers`
- **Module compilation errors**: Check `sudo dkms status` and rebuild: `sudo dkms autoinstall`

### Useful Commands:
- Check driver version: `cat /proc/driver/nvidia/version`
- Monitor GPU: `nvidia-smi -l 1`
- Check CUDA: `nvcc --version` (requires CUDA toolkit)
- View GPU info: `lspci -k | grep -A 2 -E "(VGA|3D)"`
- Check loaded kernel modules: `lsmod | grep nvidia`
- Verify DKMS modules: `sudo dkms status`
- Check GPU utilization: `nvtop`
- Verify environment variables: `cat /etc/environment.d/90-nvidia.conf`
- Check loaded environment: `env | grep -i nvidia`
- Test Vulkan support: `vulkaninfo | grep NVIDIA`