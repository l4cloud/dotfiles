# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Environment
export EDITOR=nvim
export VISUAL="$EDITOR"
export PATH=$PATH:/usr/local/go/bin
DISABLE_LS_COLORS="true"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

if [ ! -f /usr/local/bin/starship ]; then 
  curl -sS https://starship.rs/install.sh | sh
fi

#!/bin/bash

# Check if fzf is installed
if ! command -v fzf &> /dev/null; then
    echo "fzf not found, installing..."
    # Install fzf
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --all
else
    echo "fzf is already installed"
fi


# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions

autoload -Uz compinit && compinit

HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Aliases and functions
if [ -e ~/.aliases.zsh ]; then
  source ~/.aliases.zsh
fi

if [ -e ~/.func.zsh ]; then
  source ~/.func.zsh
fi

eval "$(fzf --zsh)"
eval "$(starship init zsh)"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
