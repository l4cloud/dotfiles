function ti() {
  dir=$(basename "$PWD")
  workspace=${dir//.}
  tx new-session -d -s $workspace -n nvim 'nvim'
  tx new-window -t $workspace:2 -n ai 'gemini'
  tx new-window -t $workspace:3 -n shell
  tx attach-session -t $workspace
}

function ty() {
  if [ -d "$1" ]; then
    search="$(echo $1 | sed 's/\/$//')/"
    echo "Searching directory: ${search}"
  else
    echo "Searching home"
    search=$HOME
  fi

  local git_dirs=$(find "${search}" -type d -name ".git" -exec dirname {} \; -print)
  if [ -z "$git_dirs" ]; then
    echo "No git repositories found."
    return
  fi
  local dir=$(echo "$git_dirs" | fzf --height 60% --layout reverse --border --no-hscroll --exact)
  if [ -n "$dir" ]; then
    tmp=$(basename $dir)
    workspace=${tmp//.}
    echo "Creating Session: ${workspace}"
    cd -- $dir || return
    tmux new-session -d -s $workspace -n nvim 'nvim'
    tmux new-window -t $workspace:2 -n zsh
    tmux new-window -t $workspace:3 -n zsh
    tmux attach-session -t $workspace
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

function yt() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
      if [ -n "$cwd" ]; then
        tmp=$(basename "${cwd//./}")
        echo "Creating Session: ${tmp}"
        cd -- "$cwd" || return
        tmux new-session -d -s $tmp -n nvim 'nvim'
        tmux new-window -t $tmp:2 -n zsh
        tmux attach-session -t $tmp
      fi
  fi
  rm -f -- "$tmp"
}

function fssh ()
{
  selected=$(awk '/^Host / { print $2 }' ~/.ssh/config | fzf)
  ssh $(echo "$selected" | tr -d '\r')
}


