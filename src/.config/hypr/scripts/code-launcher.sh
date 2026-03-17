#!/bin/bash

MODE=${1:-1} # vscode or neovim
if [ "$MODE" -eq 0 ]; then
    IDE="VSCode"
else
    IDE="Neovim"
fi

search_paths=(~/ /opt)

path=$( fd -H -E .git -t f -t d . "${search_paths[@]}" | fzf \
    --pointer="" \
    --marker="" \
    --prompt="Open in $IDE: " \
    --height=100% \
    --reverse \
    --preview="bat --color=always --style=numbers {}" \
    --preview-window=right:50%:wrap \
    --color=fg:7,bg:-1,hl:4,fg+:7,bg+:-1,hl+:4,info:2,prompt:4,pointer:3,marker:7,spinner:7,header:4)

if [ -n "$path" ]; then
    if [ "$MODE" -eq 0 ]; then
        codium --ozone-platform=wayland "$path"
    else
        ~/.config/hypr/scripts/nvim.sh "$path"
    fi
    notify-send -a "System" "Code launcher" "Launched $IDE: $path" -i preferences-desktop
fi
