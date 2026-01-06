#!/usr/bin/env python3
import json
import subprocess

try:
    md = subprocess.run(["playerctl", "metadata", "--format", "{{artist}} - {{title}}"], capture_output=True, text=True).stdout.strip()
except Exception:
    md = ""
print(json.dumps({"text": "⏮", "tooltip": md}))
