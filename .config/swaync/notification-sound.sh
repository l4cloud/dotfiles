#!/bin/bash

# Notification sound script for SwayNC
# This script monitors for new notifications and plays a sound

SOUND_FILE="$HOME/.config/swaync/sounds/Bones_to_Peaches.ogg"
LOG_FILE="$HOME/.config/swaync/notification-sound.log"
# Volume level (0.0 to 1.0) - adjust this to control notification sound volume
VOLUME="1"

# Function to play notification sound
play_sound() {
    if [ -f "$SOUND_FILE" ]; then
        ffplay -nodisp -autoexit -volume "$(echo "$VOLUME * 100" | bc | cut -d. -f1)" "$SOUND_FILE" 2>/dev/null &
        echo "$(date): Played notification sound (volume: $VOLUME)" >> "$LOG_FILE"
    fi
}

# Monitor dbus for notification signals
dbus-monitor --session "type='method_call',interface='org.freedesktop.Notifications',member='Notify'" 2>/dev/null |
while read -r line; do
    if echo "$line" | grep -q "method call"; then
        play_sound
    fi
done
