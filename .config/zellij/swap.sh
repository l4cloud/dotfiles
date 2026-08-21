SELECTED=$(zellij list-sessions | sed -e 's/\x1b\[[0-9;]*m//g'| awk '{print $1}' | fzf --reverse --style=full --prompt="Session> ")

zellij action switch-session $SELECTED

exit 0


