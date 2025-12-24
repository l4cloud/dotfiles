#!/bin/bash
# Test script to verify SwayNotificationCenter and power-profiles-daemon installation

echo "=== Testing Package Installation ==="
echo ""

echo "1. Checking if packages are available in repos..."
echo ""
echo "SwayNotificationCenter:"
dnf list SwayNotificationCenter 2>&1 | grep -A2 "SwayNotificationCenter"
echo ""
echo "power-profiles-daemon:"
dnf list power-profiles-daemon 2>&1 | grep -A2 "power-profiles-daemon"
echo ""

echo "2. Checking for conflicting packages..."
if rpm -q tuned-ppd &>/dev/null; then
    echo "✗ tuned-ppd is INSTALLED - conflicts with power-profiles-daemon"
    echo "  Run: sudo dnf remove -y tuned tuned-ppd"
else
    echo "✓ tuned-ppd is not installed"
fi

if rpm -q tuned &>/dev/null; then
    echo "✗ tuned is INSTALLED - conflicts with power-profiles-daemon"
    echo "  Run: sudo dnf remove -y tuned tuned-ppd"
else
    echo "✓ tuned is not installed"
fi
echo ""

echo "3. Install packages (requires sudo)..."
echo "First remove conflicting packages:"
echo "  sudo dnf remove -y tuned tuned-ppd"
echo ""
echo "Then install:"
echo "  sudo dnf install -y SwayNotificationCenter power-profiles-daemon"
echo ""

echo "4. After installation, enable and start power-profiles-daemon:"
echo "  sudo systemctl enable power-profiles-daemon"
echo "  sudo systemctl start power-profiles-daemon"
echo ""

echo "5. Verify power-profiles-daemon is working:"
echo "  powerprofilesctl"
echo ""

echo "=== Test Complete ==="
