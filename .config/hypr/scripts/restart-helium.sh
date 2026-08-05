#!/usr/bin/env bash
set -euo pipefail

HELIUM_BIN="${HELIUM_BIN:-/etc/profiles/per-user/lu/bin/helium}"
HELIUM_MATCH='extracted/opt/helium/helium '

if ! pgrep -f "$HELIUM_MATCH" >/dev/null 2>&1; then
  exit 0
fi

pkill -f 'helium-0[.]15[.]1[.]1' 2>/dev/null || true

for _ in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20; do
  pgrep -f "$HELIUM_MATCH" >/dev/null 2>&1 || break
  sleep 0.2
done

setsid "$HELIUM_BIN" </dev/null >/dev/null 2>&1 &
disown 2>/dev/null || true
