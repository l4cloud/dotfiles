#!/bin/bash

# Gaming Helper Script for Fedora Desktop Setup
# This script provides easy commands for launching Steam with gamescope

show_help() {
    echo "Gaming Helper for Fedora Desktop Setup"
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  steam-bigpicture    Launch Steam Big Picture mode with gamescope"
    echo "  steam-desktop       Launch Steam desktop mode with gamescope" 
    echo "  steam-normal        Launch Steam normally (without gamescope)"
    echo "  gamemode-test       Test if gamemode is working"
    echo "  help               Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 steam-bigpicture"
    echo "  $0 steam-desktop"
}

launch_steam_bigpicture() {
    echo "Launching Steam Big Picture with gamescope..."
    gamescope -W 1920 -H 1080 -r 60 -- steam -gamepadui
}

launch_steam_desktop() {
    echo "Launching Steam desktop with gamescope..."
    gamescope -W 1920 -H 1080 -r 60 -- steam
}

launch_steam_normal() {
    echo "Launching Steam normally..."
    steam
}

test_gamemode() {
    if command -v gamemoded >/dev/null 2>&1; then
        echo "Gamemode is installed. Testing..."
        gamemoded -t
    else
        echo "Gamemode is not installed. Consider installing it with:"
        echo "sudo dnf install gamemode"
    fi
}

# Main script logic
case "$1" in
    steam-bigpicture)
        launch_steam_bigpicture
        ;;
    steam-desktop)
        launch_steam_desktop
        ;;
    steam-normal)
        launch_steam_normal
        ;;
    gamemode-test)
        test_gamemode
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "Error: Unknown option '$1'"
        echo ""
        show_help
        exit 1
        ;;
esac