#!/usr/bin/env bash
# Automatically disable eDP-1 (laptop display) when external monitors are
# connected, and re-enable it when all external monitors are removed.
#
# Polls hyprctl every second. Uses hyprctl eval (Lua API) since this
# config uses the Lua parser, not legacy keyword format.

set -uo pipefail

LAPTOP="eDP-1"
LAPTOP_MODE="1920x1200@60.0"
LAPTOP_POS="0x0"
LAPTOP_SCALE="1.2"

last_ext_count=""

# Give Hyprland a moment to fully start before first check
sleep 2

while true; do
    ext_count=$(hyprctl monitors -j 2>/dev/null | jq '[.[] | select(.name != "'"$LAPTOP"'")] | length' 2>/dev/null || echo "0")

    if [ "$ext_count" != "$last_ext_count" ]; then
        if [ "$ext_count" -gt 0 ]; then
            hyprctl eval 'hl.monitor({ output = "'"$LAPTOP"'", disabled = true })' 2>/dev/null
        else
            hyprctl eval 'hl.monitor({ output = "'"$LAPTOP"'", disabled = false, mode = "'"$LAPTOP_MODE"'", position = "'"$LAPTOP_POS"'", scale = '"$LAPTOP_SCALE"' })' 2>/dev/null
        fi
        last_ext_count="$ext_count"
    fi

    sleep 1
done
