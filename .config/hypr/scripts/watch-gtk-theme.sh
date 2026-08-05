#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
pidfile="${XDG_RUNTIME_DIR:-/tmp}/watch-gtk-theme.pid"

if [[ -f "$pidfile" ]] && kill -0 "$(<"$pidfile")" 2>/dev/null; then
  exit 0
fi
echo $$ > "$pidfile"
trap 'rm -f "$pidfile"' EXIT

gtk3="$HOME/.config/gtk-3.0/noctalia.css"
gtk4="$HOME/.config/gtk-4.0/noctalia.css"

last=""
while true; do
  cur="$(stat -c '%Y' "$gtk3" "$gtk4" 2>/dev/null | paste -sd ',' - || true)"
  if [[ -n "$last" && -n "$cur" && "$cur" != "$last" ]]; then
    "$script_dir/restart-helium.sh"
    echo "$(date +%H:%M:%S) gtk theme changed, restarted helium" >> "${XDG_RUNTIME_DIR:-/tmp}/gtk-theme-reload.log"
  fi
  [[ -n "$cur" ]] && last="$cur"
  sleep 2
done
