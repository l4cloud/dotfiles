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

## Post-Installation Steps

1. **Reboot** after driver installation
2. **Verify installation**: `nvidia-smi`
3. **Configure Hyprland**: The playbook automatically sets required environment variables
4. **Optional**: Install `nvtop` for GPU monitoring: `sudo pacman -S nvtop`

## Manual Configuration (if needed)

### For Hyprland specifically:
```bash
# Add to ~/.config/hypr/hyprland.conf
env = LIBVA_DRIVER_NAME,nvidia
env = XDG_SESSION_TYPE,wayland
env = GBM_BACKEND,nvidia-drm
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
env = WLR_NO_HARDWARE_CURSORS,1
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
2. **Wayland issues**: Ensure environment variables are set correctly
3. **Performance issues**: Consider switching between driver versions
4. **Suspend/resume problems**: May need additional kernel parameters

### Useful Commands:
- Check driver version: `cat /proc/driver/nvidia/version`
- Monitor GPU: `nvidia-smi -l 1`
- Check CUDA: `nvcc --version` (requires CUDA toolkit)
- View GPU info: `lspci -k | grep -A 2 -E "(VGA|3D)"`