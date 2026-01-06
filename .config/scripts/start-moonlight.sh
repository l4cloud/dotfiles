#!/bin/bash

# --- CONFIGURATION ---
DUMMY="DP-3"

# Sunshine variables
WIDTH=${SUNSHINE_CLIENT_WIDTH:-1920}
HEIGHT=${SUNSHINE_CLIENT_HEIGHT:-1080}
FPS=${SUNSHINE_CLIENT_FPS:-60}

# 1. Driver-Level FPS Limits (No Overlays)
# DXVK_FRAME_RATE limits most games (DX9/10/11)
# VKD3D_FRAME_RATE limits DX12 games
export DXVK_FRAME_RATE=$FPS
export VKD3D_FRAME_RATE=$FPS
# This tells NVIDIA to sync to the refresh rate of the monitor
export __GL_SYNC_TO_VBLANK=1

# 2. Disable all monitors except the dummy monitor
ALL_MONITORS=$(hyprctl monitors -j | jq -r '.[].name')
for monitor in $ALL_MONITORS; do
    if [ "$monitor" != "$DUMMY" ]; then
        hyprctl keyword monitor "$monitor,disable"
        echo "Disabled monitor: $monitor"
    fi
done

# 3. Set Monitor & Refresh Rate for the streaming monitor
# Matching the Hz to the FPS is the best way to prevent stutter on NVIDIA
hyprctl keyword monitor "$DUMMY,${WIDTH}x${HEIGHT}@${FPS},0x0,1"

# 4. Efficiency Settings
hyprctl keyword misc:vfr true
hyprctl keyword misc:vrr 0  # VRR can cause flicker on some dummy plugs

echo "NVIDIA Stream: ${WIDTH}x${HEIGHT}@${FPS} cap applied on $DUMMY."
echo "All other monitors disabled."
