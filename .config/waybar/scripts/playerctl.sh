#!/usr/bin/env bash

# Simple wrapper for playerctl to provide consistent output for Waybar
# Usage: called by Waybar's "custom" or built-in playerctl module

if ! command -v playerctl >/dev/null 2>&1; then
  echo "playerctl not found"
  exit 1
fi

# Query metadata
status=$(playerctl status 2>/dev/null || echo "")
artist=$(playerctl metadata artist 2>/dev/null || echo "")
title=$(playerctl metadata title 2>/dev/null || echo "")

if [ -z "$status" ]; then
  echo ""
  exit 0
fi

# Compose output and truncate to 80 chars
OUT="${artist} - ${title}"
# Fallback prefix for paused state
if [ "$status" = "Paused" ]; then
  OUT=" ${OUT}"
fi
# Trim surrounding whitespace
OUT=$(echo "$OUT" | sed -E 's/^\s+|\s+$//g')
# Truncate to 80 characters
MAX=80
if [ ${#OUT} -gt $MAX ]; then
  OUT="${OUT:0:$MAX}…"
fi

echo "$OUT"
