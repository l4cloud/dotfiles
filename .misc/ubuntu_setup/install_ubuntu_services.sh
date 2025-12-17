#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Check if running on an Ubuntu-based system
if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [ "$ID" != "ubuntu" ]; then
        echo "This script is intended for Ubuntu-based systems."
        exit 1
    fi
else
    echo "This script is intended for Ubuntu-based systems."
    exit 1
fi

# Install Ansible if it's not already installed.
if ! command -v ansible >/dev/null 2>&1; then
    echo "Ansible is not installed. Installing now with apt..."
    sudo apt update
    sudo apt install -y ansible
else
    echo "Ansible is already installed."
fi

echo "Running Ansible playbook to provision machine..."
# Get the directory of the script.
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
# Run the playbook from the script's directory.
# The playbook will handle privilege escalation.
ansible-playbook "${SCRIPT_DIR}/ubuntu_services.yml" --ask-become-pass

echo "Sourcing .zshrc for validation..."
zsh -x -c "source ~/.zshrc"

echo "Provisioning complete."
