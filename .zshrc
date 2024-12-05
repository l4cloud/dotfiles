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

plugins=(git)

if [ -e "~/.aliases.zsh" ]; then
  source "~/.aliases.zsh"
fi

function ti() {
  dir=$(basename "$PWD")
  tx new-session -d -s ${dir// /_} -n nvim 'nvim'
  tx new-window -t ${dir// /_}:2 -n zsh
  tx attach-session -t ${dir// /_}
}

function ty() {
  if [ -d "$1" ]; then
    search="$(echo $1 | sed 's/\/$//')/"
    echo "Searching directory: ${search}"
  else
    echo "Searching home"
    search=$HOME
  fi

  local dir=$(find ${search} -type d -name ".git" -exec dirname {} \; | fzf --height 50% --margin 1%,10% --layout reverse --border --no-hscroll --exact)
  if [ -n "$dir" ]; then
    tmp=$(basename "${dir//./}")
    echo "Creating Session: ${tmp}"
    cd -- "$dir" || return
    tmux new-session -d -s $tmp -n nvim 'nvim'
    tmux new-window -t $tmp:2 -n zsh
    tmux attach-session -t $tmp
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
