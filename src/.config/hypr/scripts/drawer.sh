#!/bin/bash
CLASS="kitty-drawer"
if ! hyprctl clients | grep -q "class: $CLASS"; then
    hyprctl dispatch exec "[workspace special:drawer silent] env KITTY_DRAWER=1 kitty --class $CLASS"
    sleep 0.3
fi

read -r MON_NAME MON_W MON_H MON_X MON_Y MON_T MON_SCALE < <(
    hyprctl monitors -j | jq -r '.[] | select(.focused==true) | "\(.name) \(.width) \(.height) \(.x) \(.y) \(.transform) \(.scale)"'
)

if [ "$MON_T" = "1" ] || [ "$MON_T" = "3" ]; then
    TMP=$MON_W; MON_W=$MON_H; MON_H=$TMP
fi

MON_W_L=$(awk "BEGIN {printf \"%d\", $MON_W / $MON_SCALE}")
MON_H_L=$(awk "BEGIN {printf \"%d\", $MON_H / $MON_SCALE}")

DW=$((MON_W_L * 40 / 100))
DH=$((MON_H_L * 40 / 100))

if [ "$MON_T" = "1" ] || [ "$MON_T" = "3" ]; then
    TMP=$DW; DW=$DH; DH=$TMP
fi

DX=$((MON_X + (MON_W_L - DW) / 2))
DY=$((MON_Y + MON_H_L - DH - MON_H_L * 5 / 100))

hyprctl dispatch moveworkspacetomonitor "special:drawer $MON_NAME"

ADDRESS=$(hyprctl clients -j | jq -r ".[] | select(.class==\"$CLASS\") | .address")
if [ -n "$ADDRESS" ]; then
    hyprctl dispatch resizewindowpixel "exact $DW $DH,address:$ADDRESS"
    hyprctl dispatch movewindowpixel "exact $DX $DY,address:$ADDRESS"
fi

hyprctl dispatch togglespecialworkspace drawer