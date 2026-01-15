#!/bin/bash

# Script to set up Wake-on-LAN (WOL) on an Arch-based system
# Uses NetworkManager if available, otherwise creates a systemd service
# Ensures persistence and fails gracefully

set -e  # Exit on error

# Function to log messages
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" >&2
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    log "Error: This script must be run as root (use sudo)."
    exit 1
fi

# Function to find the primary Ethernet interface
find_ethernet_interface() {
    # Get the first Ethernet interface that's not loopback
    ip -o link show | grep -E '^[0-9]+: [a-z0-9]+:' | grep -v ' lo:' | head -1 | awk '{print $2}' | tr -d ':'
}

# Check and install prerequisites
if ! command -v nmcli >/dev/null 2>&1; then
    read -p "NetworkManager is not installed. Install it for better WOL persistence? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        pacman -S --noconfirm networkmanager
        # Enable and start NetworkManager if installed
        systemctl enable NetworkManager
        systemctl start NetworkManager
    fi
fi

# Check if NetworkManager is installed and available
if command -v nmcli >/dev/null 2>&1; then
    log "NetworkManager detected. Using NetworkManager to configure WOL."

    # Find active Ethernet connection
    active_conn=$(nmcli -t -f NAME,TYPE,STATE con show | grep 'ethernet:activated' | head -1 | cut -d: -f1)

    if [ -z "$active_conn" ]; then
        log "No active Ethernet connection found. Checking for any Ethernet connection..."
        active_conn=$(nmcli -t -f NAME,TYPE con show | grep 'ethernet' | head -1 | cut -d: -f1)
        if [ -z "$active_conn" ]; then
            log "Error: No Ethernet connection found in NetworkManager."
            exit 1
        fi
    fi

    log "Configuring WOL for connection: $active_conn"

    # Enable WOL magic packet
    nmcli con mod "$active_conn" ethernet.wake-on-lan magic

    # Bring the connection down and up to apply changes
    nmcli con down "$active_conn"
    nmcli con up "$active_conn"

    log "WOL enabled successfully using NetworkManager."

else
    log "NetworkManager not found. Using systemd service for WOL persistence."

    # Check if ethtool is available
    if ! command -v ethtool >/dev/null 2>&1; then
        read -p "ethtool is required but not installed. Install it? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            pacman -S --noconfirm ethtool
        else
            log "Error: ethtool is required for WOL setup."
            exit 1
        fi
    fi

    # Find Ethernet interface
    iface=$(find_ethernet_interface)
    if [ -z "$iface" ]; then
        log "Error: No Ethernet interface found."
        exit 1
    fi

    log "Found Ethernet interface: $iface"

    # Create systemd service file
    service_file="/etc/systemd/system/wol.service"
    cat > "$service_file" << EOF
[Unit]
Description=Enable Wake-on-LAN
After=network.target
Wants=network.target

[Service]
Type=oneshot
ExecStart=/usr/bin/ethtool -s $iface wol g
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

    log "Created systemd service: $service_file"

    # Reload systemd daemon
    systemctl daemon-reload

    # Enable the service
    systemctl enable wol.service

    # Start the service to apply immediately
    systemctl start wol.service

    log "WOL enabled successfully using systemd service."
fi

log "Setup complete. Your system should now support Wake-on-LAN."