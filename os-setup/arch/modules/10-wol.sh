#!/bin/bash

##############################################################################
# Module: Wake-on-LAN Configuration
# Configures Wake-on-LAN for ethernet devices
##############################################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

detect_ethernet_interface() {
    local iface=$(ip -o link show | awk -F': ' '{print $2}' | grep -E '^(eth|enp|eno)' | head -1)
    echo "$iface"
}

configure_network_manager_wol() {
    local interface=$1
    
    if ! command -v nmcli >/dev/null 2>&1; then
        log_info "NetworkManager not installed, skipping NM configuration"
        return 1
    fi
    
    local connection=$(nmcli -t -f NAME,DEVICE connection show --active 2>/dev/null | grep "$interface" | cut -d: -f1)
    
    if [ -z "$connection" ]; then
        log_warn "No active NetworkManager connection found for $interface"
        return 1
    fi
    
    if nmcli connection modify "$connection" 802-3-ethernet.wake-on-lan magic 2>/dev/null; then
        nmcli connection up "$connection" 2>/dev/null || true
        log_info "✓ WoL enabled in NetworkManager for '$connection'"
        return 0
    else
        log_warn "Failed to configure WoL in NetworkManager"
        return 1
    fi
}

enable_wol_ethtool() {
    local interface=$1
    
    if ! command -v ethtool >/dev/null 2>&1; then
        log_error "ethtool not installed"
        return 1
    fi
    
    if sudo ethtool -s "$interface" wol g 2>/dev/null; then
        log_info "✓ WoL enabled for $interface using ethtool"
        
        # Verify
        local wol_status=$(sudo ethtool "$interface" 2>/dev/null | grep "Wake-on:" | awk '{print $2}')
        if [ "$wol_status" = "g" ]; then
            log_info "✓ WoL status verified: magic packet enabled"
            return 0
        else
            log_warn "WoL status: $wol_status (expected: g)"
            return 1
        fi
    else
        log_error "Failed to enable WoL with ethtool"
        return 1
    fi
}

create_wol_systemd_service() {
    local interface=$1
    
    log_step "Creating WoL systemd service..."
    
    sudo tee /etc/systemd/system/wol@.service > /dev/null <<'EOF'
[Unit]
Description=Wake-on-LAN for %i
Requires=network.target
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/bin/ethtool -s %i wol g
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
    
    if sudo systemctl enable "wol@${interface}.service" 2>/dev/null && \
       sudo systemctl start "wol@${interface}.service" 2>/dev/null; then
        log_success "WoL systemd service created and enabled for $interface"
        return 0
    else
        log_warn "Failed to enable WoL systemd service"
        return 1
    fi
}

configure_acpi_wakeup() {
    log_step "Configuring ACPI wakeup for ethernet device..."
    
    local ethernet_pci=$(lspci 2>/dev/null | grep -i "ethernet controller" | head -1 | cut -d' ' -f1)
    
    if [ -z "$ethernet_pci" ]; then
        log_warn "Could not detect ethernet PCI device"
        return 1
    fi
    
    log_info "Ethernet controller at PCI address: $ethernet_pci"
    
    # Create ACPI wakeup service
    sudo tee /etc/systemd/system/acpi-wakeup-ethernet.service > /dev/null <<'EOF'
[Unit]
Description=Enable ACPI Wake for Ethernet Device
After=multi-user.target
DefaultDependencies=no

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'for device in $(grep "disabled.*pci:" /proc/acpi/wakeup 2>/dev/null | grep -i "ethernet\|EP00\|LN00" | awk "{print \$1}"); do echo $device > /proc/acpi/wakeup 2>/dev/null || true; done'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
    
    if sudo systemctl enable acpi-wakeup-ethernet.service 2>/dev/null; then
        log_success "ACPI wakeup service created and enabled"
        return 0
    else
        log_warn "Failed to enable ACPI wakeup service"
        return 1
    fi
}

main() {
    log_section "Wake-on-LAN Configuration"
    
    # Detect ethernet interface
    local interface=$(detect_ethernet_interface)
    
    if [ -z "$interface" ]; then
        log_warn "No ethernet interface detected (checked: eth*, enp*, eno*)"
        log_info "Available interfaces:"
        ip -o link show | awk -F': ' '{print $2}' | grep -v "lo" | while read iface; do
            log_info "  - $iface"
        done
        log_warn "Skipping WoL configuration"
        return 1
    fi
    
    log_info "Detected ethernet interface: $interface"
    
    # Check WoL support
    local wol_support=$(sudo ethtool "$interface" 2>/dev/null | grep "Supports Wake-on" | awk '{print $3}')
    if [ -n "$wol_support" ]; then
        log_info "WoL capabilities: $wol_support"
    fi
    
    local success=true
    
    # Configure WoL
    configure_network_manager_wol "$interface" || true
    enable_wol_ethtool "$interface" || success=false
    create_wol_systemd_service "$interface" || success=false
    configure_acpi_wakeup || true
    
    if [ "$success" = true ]; then
        log_success "Wake-on-LAN configuration complete"
        log_info ""
        log_info "IMPORTANT: WoL also requires BIOS/UEFI configuration:"
        log_info "  1. Enter BIOS/UEFI setup (usually DEL, F2, or F12 during boot)"
        log_info "  2. Look for Power Management or Advanced settings"
        log_info "  3. Enable 'Wake on LAN' or 'Wake on PCIe/PCI'"
        log_info "  4. Save and exit BIOS"
        return 0
    else
        log_warn "Wake-on-LAN configuration had issues"
        return 1
    fi
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    check_arch || exit 1
    check_sudo || exit 1
    main
    exit $?
fi
