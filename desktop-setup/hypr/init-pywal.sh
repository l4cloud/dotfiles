#!/bin/bash

# Initialize pywal on fresh system installs
echo "Initializing pywal for fresh install..."

# Check if pywal is installed
if ! command -v wal &> /dev/null; then
    echo "Installing pywal..."
    if command -v pacman &> /dev/null; then
        sudo pacman -S python-pywal --noconfirm
    elif command -v apt &> /dev/null; then
        sudo apt update && sudo apt install python3-pywal -y
    elif command -v dnf &> /dev/null; then
        sudo dnf install python3-pywal -y
    elif command -v pip &> /dev/null; then
        pip install pywal
    else
        echo "Could not install pywal automatically. Please install it manually."
        exit 1
    fi
fi

# Find a default wallpaper to use for initialization
DEFAULT_WALLPAPER=""
WALLPAPER_DIRS=(
    "$HOME/.dotfiles/wallpapers/Wallpapers"
    "$HOME/Wallpapers"
    "$HOME/Pictures/Wallpapers"
    "$HOME/Pictures"
    "/usr/share/pixmaps"
    "/usr/share/backgrounds"
)

for dir in "${WALLPAPER_DIRS[@]}"; do
    if [[ -d "$dir" ]]; then
        DEFAULT_WALLPAPER=$(find "$dir" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | head -1)
        if [[ -n "$DEFAULT_WALLPAPER" ]]; then
            break
        fi
    fi
done

# If no wallpaper found, create a simple colored background
if [[ -z "$DEFAULT_WALLPAPER" ]]; then
    echo "No wallpaper found. Creating a default background..."
    mkdir -p "$HOME/Pictures"
    # Create a simple gradient background using ImageMagick if available
    if command -v convert &> /dev/null; then
        convert -size 1920x1080 gradient:#2e3440-#3b4252 "$HOME/Pictures/default-bg.png"
        DEFAULT_WALLPAPER="$HOME/Pictures/default-bg.png"
    else
        # Use a solid color as fallback
        wal --theme base16-default-dark
        echo "Created default color scheme. You can change wallpaper later with Alt+W"
        exit 0
    fi
fi

echo "Using wallpaper: $DEFAULT_WALLPAPER"

# Initialize pywal with the default wallpaper
wal -i "$DEFAULT_WALLPAPER" -n

# Notify user
echo "Pywal initialized successfully! You can change wallpaper with Alt+W"