export ZSH="$HOME/.oh-my-zsh"
eval "$(starship init zsh)"

export PATH=$PATH:/usr/local/go/bin
ZSH_THEME="robbyrussell"

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

alias ll="ls -l"
alias la="ls -al"
alias tmi='tmux new-session -s $(basename "$PWD") \; rename-window nvim \; new-window \; rename-window -t 2 term'

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}
