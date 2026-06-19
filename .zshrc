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
HISTSIZE=10000
SAVEHIST=10000

setopt appendhistory sharehistory
setopt hist_ignore_space hist_ignore_all_dups hist_save_no_dups hist_find_no_dups

# Vi mode
bindkey -v
KEYTIMEOUT=1

# Key bindings
bindkey '^k' history-incremental-search-forward
bindkey '^j' history-incremental-search-backward
bindkey '^r' history-incremental-search-backward

# fzf
source <(fzf --zsh)

# fzf history picker on Alt+H
fzf-history-widget() {
  local selected
  zle -I
  {
    selected=$(fc -ln 1 | awk '!seen[$0]++' | fzf \
      --height 40% \
      --reverse \
      --no-sort \
      --tac \
      --scheme history \
      --bind 'ctrl-r:toggle-sort' \
      --preview 'echo {}' \
      --preview-window 'down:3:wrap' \
      --query "$BUFFER")
  } always {
    zle -R
  }
  if [[ -n "$selected" ]]; then
    BUFFER="$selected"
    CURSOR=${#BUFFER}
  fi
}
zle -N fzf-history-widget
bindkey '^h' fzf-history-widget

# NVM
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"

# Aliases & functions
[[ -f ~/.aliases.zsh ]] && source ~/.aliases.zsh
[[ -f ~/.func.zsh ]]    && source ~/.func.zsh
[[ -f ~/.zshenv ]]    && source ~/.zshenv

# Prompt
eval "$(starship init zsh)"

