#!/usr/bin/env python3
import json
import subprocess

try:
    status = subprocess.run(["playerctl", "status"], capture_output=True, text=True).stdout.strip()
    md = subprocess.run(["playerctl", "metadata", "--format", "{{artist}} - {{title}}"], capture_output=True, text=True).stdout.strip()
except Exception:
    status = ""
    md = ""
icon = "⏯"
if status == "Playing":
    icon = "⏸"
elif status == "Paused":
    icon = "▶"
print(json.dumps({"text": icon, "tooltip": md}))
