selected=$(awk '/^Host / { print $2 }' ~/.ssh/config | fzf)
ssh $(echo "$selected" | tr -d '\r')



