#!/bin/bash

# --- CONFIGURATION ---
DUMMY="DP-3"
DUMMY_WORKSPACE="9"

# Sunshine variables
WIDTH=${SUNSHINE_CLIENT_WIDTH:-1920}
HEIGHT=${SUNSHINE_CLIENT_HEIGHT:-1080}
FPS=${SUNSHINE_CLIENT_FPS:-60}

# 1. Configure the dummy monitor for streaming
hyprctl keyword monitor "$DUMMY,${WIDTH}x${HEIGHT}@${FPS},3440x975,1"

# 2. Efficiency Settings
hyprctl keyword misc:vfr true
hyprctl keyword misc:vrr 0

# 3. Focus workspace 9 (DP-3) so Steam Big Picture launches there
hyprctl dispatch workspace $DUMMY_WORKSPACE

# 4. Add window rule to force ONLY Steam Big Picture to workspace 9
# This uses title matching so normal Steam windows can still open on desktop
hyprctl keyword windowrulev2 "workspace $DUMMY_WORKSPACE silent,class:^(steam)$,title:^(Steam Big Picture Mode)$"

# 5. Move cursor to DP-3 to ensure focus
hyprctl dispatch focusmonitor $DUMMY

echo "═══════════════════════════════════════════════════"
echo "  Streaming Setup Complete"
echo "═══════════════════════════════════════════════════"
echo "  Monitor:    $DUMMY"
echo "  Resolution: ${WIDTH}x${HEIGHT}@${FPS}Hz"
echo "  Workspace:  $DUMMY_WORKSPACE"
echo "  Steam Big Picture will launch on DP-3"
echo "═══════════════════════════════════════════════════"
