#!/bin/bash

# Get list of sinks
sinks=($(pactl list short sinks | cut -f2))
current_sink=$(pactl get-default-sink)

# Find next sink in list
next_sink=""
for i in "${!sinks[@]}"; do
    if [[ "${sinks[$i]}" == "$current_sink" ]]; then
        next_index=$(((i + 1) % ${#sinks[@]}))
        next_sink="${sinks[$next_index]}"
        break
    fi
done

# If we couldn't find current sink, use first one
if [[ -z "$next_sink" ]]; then
    next_sink="${sinks[0]}"
fi

# Switch to next sink
pactl set-default-sink "$next_sink"

# Move all playing audio to new sink
pactl list short sink-inputs | while read -r input; do
    input_id=$(echo "$input" | cut -f1)
    pactl move-sink-input "$input_id" "$next_sink"
done

# Send signal to waybar to update
pkill -RTMIN+10 waybar