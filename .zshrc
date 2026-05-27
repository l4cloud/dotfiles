# Terminal
if [[ -n "$TMUX" ]]; then
  export TERM=tmux-256color
else
  export TERM=xterm-256color
fi

# Zinit
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

if [[ ! -d "$ZINIT_HOME" ]]; then
  mkdir -p "$(dirname "$ZINIT_HOME")"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"

# Plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions

# Completion
autoload -Uz compinit
compinit

zstyle ':completion:*' menu select
DISABLE_LS_COLORS="true"

# History
HISTFILE=~/.zsh_history
HISTSIZE=5000
SAVEHIST=$HISTSIZE
HISTDUP=erase

setopt appendhistory sharehistory
setopt hist_ignore_space hist_ignore_all_dups hist_save_no_dups hist_find_no_dups

# Key bindings
bindkey '^k' history-incremental-search-forward
bindkey '^j' history-incremental-search-backward

# fzf
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh

# NVM
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"

# Aliases & functions
[[ -f ~/.aliases.zsh ]] && source ~/.aliases.zsh
[[ -f ~/.func.zsh ]]    && source ~/.func.zsh

# Prompt
eval "$(starship init zsh)"
