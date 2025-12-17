#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Check if running on Ubuntu 22.04
if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [ "$ID" != "ubuntu" ]; then
        echo "This script is intended for Ubuntu systems."
        echo "Detected: $PRETTY_NAME"
        exit 1
    fi
    
    # Check for Ubuntu 22.04 specifically (recommended)
    if [ "$VERSION_ID" != "22.04" ]; then
        echo "Warning: This script is optimized for Ubuntu 22.04."
        echo "Detected: $PRETTY_NAME"
        read -p "Do you want to continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Exiting..."
            exit 1
        fi
    else
        echo "Detected: Ubuntu 22.04 LTS - Proceeding with setup..."
    fi
else
    echo "This script is intended for Ubuntu systems."
    exit 1
fi

# Install Ansible if it's not already installed.
if ! command -v ansible >/dev/null 2>&1; then
    echo "Ansible is not installed. Installing now with apt..."
    sudo apt update
    sudo apt install -y ansible python3-pip
    
    # Install additional ansible dependencies for Ubuntu 22.04
    sudo apt install -y python3-apt python3-docker
else
    echo "Ansible is already installed."
    ansible --version
fi

echo "Running Ansible playbook to provision Ubuntu 22.04 machine..."
# Get the directory of the script.
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Check if packages.yml exists
if [ ! -f "${SCRIPT_DIR}/vars/packages.yml" ]; then
    echo "Error: vars/packages.yml not found!"
    echo "Please ensure the packages file exists before running this script."
    exit 1
fi

# Run the playbook from the script's directory.
# The playbook will handle privilege escalation.
echo "Starting provisioning process..."
ansible-playbook "${SCRIPT_DIR}/ubuntu_services.yml" --ask-become-pass

echo "Sourcing .zshrc for validation..."
if [ -f ~/.zshrc ]; then
    zsh -c "source ~/.zshrc && echo 'Shell configuration loaded successfully'"
else
    echo "Warning: ~/.zshrc not found. You may need to configure your shell manually."
fi

echo ""
echo "============================================="
echo "Ubuntu 22.04 provisioning complete!"
echo "============================================="
echo ""
echo "Next steps:"
echo "1. Log out and back in to apply group changes (docker)"
echo "2. Run 'source ~/.zshrc' to reload shell configuration"
echo "3. Verify installations:"
echo "   - docker --version"
echo "   - lazygit --version" 
echo "   - yazi --version"
echo "   - pyenv --version"
echo "   - nvm --version"
echo ""
echo "For additional fonts, use: getnf"
echo "============================================="
