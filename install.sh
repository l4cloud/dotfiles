#!/bin/bash
set -euo pipefail

# Run from the repo root regardless of where the script is invoked from
cd "$(dirname "$(readlink -f "$0")")"

# Print a package list, skipping blanks and comments
read_packages() {
    local file="$1"
    [[ -f "$file" ]] || { echo "Missing package file: $file" >&2; exit 1; }
    while IFS= read -r line; do
        line="${line%%#*}"             # strip inline comments
        line="$(echo "$line" | xargs)" # trim whitespace
        [[ -n "$line" ]] && printf '%s\n' "$line"
    done < "$file"
}

# Enable a dnf repo from a .repo URL, unless its id is already enabled
add_repo() {
    local id="$1" url="$2"
    if dnf repolist --enabled 2>/dev/null | awk 'NR>1 {print $1}' | grep -qx "$id"; then
        return
    fi
    echo "Adding dnf repo: $id"
    sudo curl -fsSL "$url" -o "/etc/yum.repos.d/${id}.repo"
}

# Choose a profile
echo "Select install profile:"
echo "  1) minimal  - base packages only (WSL / headless)"
echo "  2) full     - base + desktop packages"
read -rp "Choice [1/2] (default: 2): " choice

case "${choice:-2}" in
    1|minimal|m)        profile="minimal" ;;
    2|full|desktop|f|d) profile="full" ;;
    *) echo "Invalid choice: ${choice}" >&2; exit 1 ;;
esac

echo "Installing '$profile' profile..."

# Gather package lists for the chosen profile
files=("packages.base")
[[ "$profile" == "full" ]] && files+=("packages.desktop")

packages=()
for f in "${files[@]}"; do
    while IFS= read -r pkg; do
        packages+=("$pkg")
    done < <(read_packages "$f")
done

if [[ ${#packages[@]} -eq 0 ]]; then
    echo "No packages found for '$profile' profile"
    exit 0
fi

# Third-party repos required by base packages (docker-ce, terraform)
add_repo docker-ce-stable https://download.docker.com/linux/fedora/docker-ce.repo
add_repo hashicorp https://rpm.releases.hashicorp.com/fedora/hashicorp.repo

# Hyprland + noctalia-shell meta package (desktop only)
if [[ "$profile" == "full" ]]; then
    sudo dnf -y copr enable lionheartp/Hyprland
fi

sudo dnf -y install "${packages[@]}"

# tflint isn't packaged in any repo — install it with the Go toolchain
if command -v go >/dev/null 2>&1; then
    mkdir -p "$HOME/.local/bin"
    GOBIN="$HOME/.local/bin" go install github.com/terraform-linters/tflint@latest \
        || echo "warning: tflint install failed, skipping"
fi

# Swap default shell to zsh
ZSH_PATH="$(command -v zsh)"
if [[ -n "$ZSH_PATH" ]] && [[ "$SHELL" != "$ZSH_PATH" ]]; then
    sudo chsh -s "$ZSH_PATH" "$USER"
    echo "Default shell changed to $ZSH_PATH (log out/in to take effect)"
fi

# Agent harnesses
curl -fsSL https://pi.dev/install.sh | sh
curl -fsSL https://opencode.ai/v2/install | bash

# Conda install
curl -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
