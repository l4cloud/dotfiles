#!/usr/bin/bash

echo "installing dependencies for ubuntu"

dependencies="tmux stow xclip zsh ninja-build gettext cmake unzip curl build-essential"

sudo apt update
sudo apt install $dependencies

git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
chsh -s $(which zsh)
curl -sS https://starship.rs/install.sh | sh

cd /tmp

git clone https://github.com/neovim/neovim.git
cd /tmp/neovim && git checkout stable

make CMAKE_BUILD_TYPE=Release
sudo make install
