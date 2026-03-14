#!/bin/bash
# Open a path in neovim via tmux
# - Directories: create/attach a named tmux session with nvim + opencode + shell
# - Files: open directly in nvim (no tmux)

path="${1/#\~/$HOME}"
path="$(realpath "$path" 2>/dev/null || echo "$path")"

if [ -d "$path" ]; then
    # Use full path as session name (replace problematic chars)
    session_name="$(echo "$path" | tr '/.' '_-')"
    if tmux has-session -t "=$session_name" 2>/dev/null; then
        kitty --detach --class neovim -e tmux attach-session -t "$session_name"
    else
        kitty --detach --class neovim -e tmux new-session -s "$session_name" -c "$path" \
            "cd '$path' && nvim ./; exec $SHELL" \; \
            split-window -h -p 25 -c "$path" "cd '$path' && opencode; exec $SHELL" \; \
            split-window -v -p 25 -t 0 -c "$path" \; \
            select-pane -t 0 &
        disown
    fi
else
    kitty --detach --class neovim -e nvim "$path"
fi
