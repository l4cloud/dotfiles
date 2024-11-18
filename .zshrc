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
alias zscf="nvim ~/.zshrc"
alias nvcf="nvim ~/.config/nvim/init.lua"
alias tmcf="nvim ~/.tmux.conf"

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
  tx new-window -t $(basename "$PWD"):2 -n shell
  tx attach-session -t $(basename "$PWD")
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
else
fi
