#!/bin/bash

# Wallpaper directory - check multiple possible locations
WALLPAPER_DIRS=(
    "$HOME/.dotfiles/wallpapers/Wallpapers"
    "$HOME/Wallpapers"
    "$HOME/Pictures/Wallpapers"
    "$HOME/Pictures"
)

# Find the first existing wallpaper directory
WALLPAPER_DIR=""
for dir in "${WALLPAPER_DIRS[@]}"; do
    if [[ -d "$dir" ]]; then
        WALLPAPER_DIR="$dir"
        break
    fi
done

# If no wallpaper directory found, create default and exit
if [[ -z "$WALLPAPER_DIR" ]]; then
    echo "No wallpaper directory found. Creating $HOME/Wallpapers"
    mkdir -p "$HOME/Wallpapers"
    echo "Please add some wallpapers to $HOME/Wallpapers and try again."
    exit 1
fi
menu() {
    find -L "${WALLPAPER_DIR}" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) | awk '{print "img:"$0}'
}

main() {
    # Check if required tools are installed
    if ! command -v wal &> /dev/null; then
        echo "pywal is not installed. Installing..."
        # Try to install pywal - adjust for your package manager
        if command -v pacman &> /dev/null; then
            sudo pacman -S python-pywal --noconfirm
        elif command -v apt &> /dev/null; then
            sudo apt install python3-pywal -y
        elif command -v dnf &> /dev/null; then
            sudo dnf install python3-pywal -y
        else
            echo "Please install pywal manually and try again."
            exit 1
        fi
    fi

    if ! command -v swww &> /dev/null; then
        echo "swww is not installed. Please install it first."
        exit 1
    fi

    choice=$(menu | wofi -c ~/.config/wofi/wallpaper -s ~/.config/wofi/style-wallpaper.css --show dmenu --prompt "Select Wallpaper:" -n)
    if [ -z "$choice" ]; then
        exit 0
    fi
    
    selected_wallpaper=$(echo "$choice" | sed 's/^img://')
    
    # Set wallpaper on all monitors with swww
    swww img "$selected_wallpaper" --transition-type any --transition-fps 360 --transition-duration .5
    
    # Generate colors with pywal
    wal -i "$selected_wallpaper" -n
    
    # Reload Hyprland to apply new colors
    hyprctl keyword source ~/.cache/wal/colors-hyprland
    
    # Reload other components if they exist
    if command -v swaync-client &> /dev/null; then
        swaync-client --reload-css
    fi
    
    # Reload waybar
    pkill -USR2 waybar 2>/dev/null
    
    # Update kitty colors if config exists
    if [[ -f ~/.cache/wal/colors-kitty.conf ]] && [[ -d ~/.config/kitty ]]; then
        cp ~/.cache/wal/colors-kitty.conf ~/.config/kitty/current-theme.conf
    fi
    
    # Update cava colors if config exists
    if [[ -f ~/.config/cava/config ]] && [[ -f ~/.cache/wal/colors.sh ]]; then
        color1=$(awk 'match($0, /color2=\47(.*)\47/,a) { print a[1] }' ~/.cache/wal/colors.sh)
        color2=$(awk 'match($0, /color3=\47(.*)\47/,a) { print a[1] }' ~/.cache/wal/colors.sh)
        cava_config="$HOME/.config/cava/config"
        sed -i "s/^gradient_color_1 = .*/gradient_color_1 = '$color1'/" "$cava_config"
        sed -i "s/^gradient_color_2 = .*/gradient_color_2 = '$color2'/" "$cava_config"
        pkill -USR2 cava 2>/dev/null
    fi
    
    # Source the colors
    if [[ -f ~/.cache/wal/colors.sh ]]; then
        source ~/.cache/wal/colors.sh
    fi
}
main

