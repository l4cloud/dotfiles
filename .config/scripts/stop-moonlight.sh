#!/bin/bash

# --- CONFIGURATION ---
DUMMY="DP-3"
DUMMY_WORKSPACE="9"
MAIN_WORKSPACE="2"
IDLE_RESOLUTION="1280x800@60"

# 1. Kill running games
echo "Stopping running games..."

# Kill specific known games
pkill -f "Cyberpunk2077.exe" 2>/dev/null
pkill -f "cyberpunk" 2>/dev/null

# Kill Steam game processes
pkill -f "steam_app_" 2>/dev/null
pkill -f "steamapps" 2>/dev/null
pkill -f "reaper" 2>/dev/null

# Give processes time to terminate gracefully
sleep 1

# Force kill if still running
pkill -9 -f "Cyberpunk2077.exe" 2>/dev/null

echo "Game processes terminated."

# 2. Remove the temporary Steam Big Picture window rule
hyprctl keyword windowrulev2 "unset,class:^(steam)$,title:^(Steam Big Picture Mode)$"

# 3. Reset dummy plug to Steam Deck idle resolution
hyprctl keyword monitor "$DUMMY,$IDLE_RESOLUTION,3440x975,1"

# 4. Return focus to main workspace on DP-1
hyprctl dispatch workspace $MAIN_WORKSPACE

# 5. Small delay to let everything settle
sleep 0.5

echo "═══════════════════════════════════════════════════"
echo "  Streaming Cleanup Complete"
echo "═══════════════════════════════════════════════════"
echo "  DP-3 reset to: $IDLE_RESOLUTION"
echo "  Returned to workspace: $MAIN_WORKSPACE"
echo "  System ready for normal use"
echo "═══════════════════════════════════════════════════"
