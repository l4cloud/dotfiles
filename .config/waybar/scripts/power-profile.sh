#!/bin/bash

# Get current power profile
get_profile() {
    powerprofilesctl get
}

# Toggle between profiles
toggle_profile() {
    current=$(get_profile)
    case "$current" in
        "power-saver")
            powerprofilesctl set balanced
            ;;
        "balanced")
            powerprofilesctl set performance
            ;;
        "performance")
            powerprofilesctl set power-saver
            ;;
    esac
    # Send signal to waybar to update
    pkill -RTMIN+8 waybar
}

# Output JSON for waybar
output_json() {
    profile=$(get_profile)
    
    case "$profile" in
        "power-saver")
            icon="󰌪"
            text="Power Saver"
            class="power-saver"
            ;;
        "balanced")
            icon="󰗑"
            text="Balanced"
            class="balanced"
            ;;
        "performance")
            icon="󱐋"
            text="Performance"
            class="performance"
            ;;
        *)
            icon="󰚥"
            text="Unknown"
            class="unknown"
            ;;
    esac
    
    echo "{\"text\":\"$icon\",\"tooltip\":\"$text\",\"class\":\"$class\"}"
}

# Main logic
if [ "$1" = "toggle" ]; then
    toggle_profile
else
    output_json
fi
