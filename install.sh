#!/bin/bash
set -euo pipefail

# Gather all packages from the packages file, skipping blanks and comments
packages=()
while IFS= read -r line; do
    line="${line%%#*}"           # strip inline comments
    line="$(echo "$line" | xargs)" # trim whitespace
    [[ -n "$line" ]] && packages+=("$line")
done < packages

if [[ ${#packages[@]} -eq 0 ]]; then
    echo "No packages found in packages file"
    exit 0
fi

# Enable third-party COPR repos (Hyprland + noctalia-shell meta package)
sudo dnf -y copr enable lionheartp/Hyprland

sudo dnf -y install "${packages[@]}"


# Agent harnesses
#curl -fsSL https://pi.dev/install.sh | sh
#curl -fsSL https://opencode.ai/v2/install | bash


