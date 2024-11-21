export ZSH="$HOME/.oh-my-zsh"
eval "$(starship init zsh)"
export EDITOR=nvim
export VISUAL="$EDITOR"
export PATH=$PATH:/usr/local/go/bin
ZSH_THEME="robbyrussell"

precmd() {
  if [ ! -z "$BUFFER" ]; then
    precmd() {
      precmd() {
        echo
      }
    }
  fi
}

DISABLE_LS_COLORS="true"


# CASE_SENSITIVE="true"
# HYPHEN_INSENSITIVE="true"
# DISABLE_MAGIC_FUNCTIONS="true"

plugins=(git)

# - Alias' - 
# Config
alias conf-zsh="nvim ~/.zshrc"
alias conf-tmux="nvim ~/.tmux.conf"
alias zshr="source ~/.zshrc"


# Programs
alias nv="nvim"

if command -v lsd >/dev/null 2>&1; then
  alias ll="lsd -l"
  alias ls="lsd"
  alias la="lsd -al"
else
  alias ll="ls -l"
  alias la="ls -al"
fi

alias tx="tmux"

function ti() {
  tx new-session -d -s $(basename "$PWD") -n nvim 'nvim'
  tx new-window -t $(basename "$PWD"):2 -n zsh
  tx attach-session -t $(basename "$PWD")
}

function ty() {
  local dir=$(find ~/ -type d \( -path '*/.*' -prune \) -o -type d -print | grep -v '/\.' | fzf --height 50% --margin 1%,10% --layout reverse --border --no-hscroll --exact)
  if [ -n "$dir" ]; then
    cd -- "$dir" || return
    tmux new-session -d -s $(basename "$dir") -n nvim 'nvim'
    tmux new-window -t $(basename "$dir"):2 -n zsh
    tmux attach-session -t $(basename "$dir")
  else
    echo "No directory selected."
  fi
}

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

alias yh='cd ~ && y'

if [ -d "/mnt/c/" ]; then
  alias ff="/mnt/c/Program\ Files/Mozilla\ Firefox/firefox.exe --new-tab --url about:newtab"
  alias ex="explorer.exe ."
else
fi
