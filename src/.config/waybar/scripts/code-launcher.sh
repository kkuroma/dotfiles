#!/bin/bash

path=$(fd -H -E .git -t f -t d | fzf \
    --pointer="" \
    --marker="" \
    --prompt="Open in VS Code: " \
    --height=100% \
    --reverse \
    --preview="bat --color=always --style=numbers {}" \
    --preview-window=right:50%:wrap \
    --color=fg:7,bg:-1,hl:4,fg+:7,bg+:-1,hl+:4,info:2,prompt:4,pointer:3,marker:7,spinner:7,header:4)

if [ -n "$path" ]; then
    codium --ozone-platform=wayland "$path"
    notify-send -a "System" "Code launcher" "Opened $path" -i preferences-desktop
fi