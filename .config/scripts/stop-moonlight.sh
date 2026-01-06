#!/bin/bash

# --- CONFIGURATION ---
DUMMY="DP-3"

# 1. Kill any running games
# This ensures games don't keep running after the stream ends
echo "Stopping any running games..."

# Kill Cyberpunk 2077 specifically
pkill -f "Cyberpunk2077.exe" 2>/dev/null
pkill -f "cyberpunk" 2>/dev/null

# Kill Steam game processes (steam launches games with steam_app_ID)
pkill -f "steam_app_" 2>/dev/null
pkill -f "steamapps" 2>/dev/null
pkill -f "reaper" 2>/dev/null  # Steam's game process manager

# Give processes a moment to terminate gracefully
sleep 1

# Force kill Cyberpunk if still running
pkill -9 -f "Cyberpunk2077.exe" 2>/dev/null

echo "Game processes terminated."

# 2. Re-enable all monitors
# HDMI-A-1 and DP-1 are your main monitors based on hyprctl output
hyprctl keyword monitor "HDMI-A-1,preferred,auto,1"
hyprctl keyword monitor "DP-1,preferred,auto,1"

# 2. Small delay to let the GPU/Drivers handshake
sleep 1

# 3. Force DPMS (Display Power Management) to turn the screens back on
# This is often what prevents the "black screen" issue
hyprctl dispatch dpms on

# 4. Disable the dummy plug
hyprctl keyword monitor "$DUMMY,disable"

# 5. Final safety reload to snap workspaces and wallpapers back
sleep 0.5
hyprctl reload

echo "System restored. Main monitors re-enabled."
