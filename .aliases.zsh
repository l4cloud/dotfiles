alias vim="nvim"

# ls — prefer lsd if available
if command -v lsd &>/dev/null; then
  alias ls="lsd"
fi

alias ll="ls -l"
alias la="ls -al"
alias lt="ls --tree"

# tmux
alias tx="tmux"
alias txa="tmux a"

# tools
alias lg="lazygit"
alias yh='cd ~ && y'

# WSL
if [[ -d "/mnt/c" ]]; then
  alias ff="/mnt/c/Program\ Files/Mozilla\ Firefox/firefox.exe --new-tab --url about:newtab"
  alias ex="explorer.exe ."
  alias aws-login="saml2aws.exe login --profile=saml --force"
  alias k9="aws-login && k9s.exe"
fi
