#!/bin/bash

WAYBAR_DIR="$HOME/.config/waybar"
IS_VERTICAL_FILE="$WAYBAR_DIR/is_vertical"

# If argument is 1, toggle the current value
if [ "$1" = "1" ]; then
    current=$(cat "$IS_VERTICAL_FILE")
    if [ "$current" = "0" ]; then
        echo "1" > "$IS_VERTICAL_FILE"
    else
        echo "0" > "$IS_VERTICAL_FILE"
    fi
fi

is_vertical=$(cat "$IS_VERTICAL_FILE")

killall waybar 2>/dev/null
sleep 0.2

if [ "$is_vertical" = "1" ]; then
    waybar -c "$WAYBAR_DIR/config_vertical.jsonc" &
    hyprctl keyword scrolling:direction "down"
    hyprctl keyword animation "workspaces, 1, 1.0, md3_decel, slidefadevert 15%"
else
    waybar -c "$WAYBAR_DIR/config_horizontal.jsonc" &
    hyprctl keyword scrolling:direction "right"
    hyprctl keyword animation "workspaces, 1, 1.0, md3_decel, slidefade 15%"
fi
