# Set Zinit home
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Environment
export EDITOR=nvim
export VISUAL="$EDITOR"
export PATH="$PATH:/usr/local/go/bin:$HOME/.local/bin"
export PATH="$HOME/.opencode/bin:$PATH"
export GOPATH="$HOME/.go"
DISABLE_LS_COLORS="true"

# Install Zinit if missing
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Install starship if missing
if [ ! -f /usr/local/bin/starship ]; then 
  curl -sS https://starship.rs/install.sh | sh
fi

# Install fzf if missing
if [ ! -f "$HOME/.fzf/bin/fzf" ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --all
fi

# Install tpm if missing
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# Always source fzf key bindings & completion
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Plugins
zinit ice depth=1
zinit light jeffreytse/zsh-vi-mode

zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions

# Completion (only run once, at the right place)
autoload -Uz compinit
compinit

# Zsh history settings
HISTSIZE=5000
SAVEHIST=$HISTSIZE
HISTFILE=~/.zsh_history
HISTDUP=erase
setopt appendhistory sharehistory
setopt hist_ignore_space hist_ignore_all_dups hist_save_no_dups hist_ignore_dups hist_find_no_dups

# Aliases & functions
[ -e ~/.aliases.zsh ] && source ~/.aliases.zsh
[ -e ~/.func.zsh ] && source ~/.func.zsh

# Starship prompt
eval "$(starship init zsh)"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Completion menu style
zstyle ':completion:*' menu select




if [ -n "$TMUX" ]; then
  export TERM=tmux-256color
else
  export TERM=xterm-256color
fi
export XDG_SESSION_TYPE=wayland
export PATH="/home/lu/.local/bin:${PATH}"
export EDITOR=nvim
export PATH="/home/lu/.local/bin:${PATH}"
