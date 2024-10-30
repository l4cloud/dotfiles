#!/usr/bin/bash

echo "installing dependencies for ubuntu"


dependencies = ["stow", "xclip", "zsh"]

sudo apt update
sudo apt install $dependencies

curl -sS https://starship.rs/install.sh | sh
