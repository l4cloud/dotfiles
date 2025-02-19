# Environment
export EDITOR=nvim
export VISUAL="$EDITOR"
export PATH=$PATH:/usr/local/go/bin
DISABLE_LS_COLORS="true"
plugins=(vi-mode git)

# Aliases and functions
if [ -e ~/.aliases.zsh ]; then
  source ~/.aliases.zsh
fi

if [ -e ~/.func.zsh ]; then
  source ~/.aliases.zsh
fi


# Post Launch
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
eval "$(starship init zsh)"
set -o vi

precmd() {
  if [ ! -z "$BUFFER" ]; then
    precmd() {
      precmd() {
        echo
      }
    }
  fi
}
