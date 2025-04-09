alias conf-zsh="nvim ~/.zshrc"
alias conf-tmux="nvim ~/.tmux.conf"
alias zshr="source ~/.zshrc"

alias nv="nvim"
alias test="echo $HOME"

if command -v lsd >/dev/null 2>&1; then
  alias ls="lsd"  
fi

alias ll="ls -l"
alias la="ls -al"
alias lt="ls --tree"  
alias tx="tmux"
alias txa="tmux a"
alias yh='cd ~ && y'
alias lg="lazygit"
alias aws-login="saml2aws.exe login --profile=saml --force"
alias k9="aws-login && k9s.exe"
bindkey '^k' .history-incremental-search-forward
bindkey '^j' .history-incremental-search-backward

if [ -d "/mnt/c/" ]; then
  alias ff="/mnt/c/Program\ Files/Mozilla\ Firefox/firefox.exe --new-tab --url about:newtab"
  alias ex="explorer.exe ."
else
fi
