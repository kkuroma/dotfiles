#!/usr/bin/env bash

# Check if hypridle is running
if pgrep -x hypridle > /dev/null; then
    timeout_status="󰈈 Active"
else
    timeout_status="󰈉 Inactive"
fi

menu=(
    " Keybinds"
    "$timeout_status"
    " Layout"
    "󰹑 Screenshot"
    "󰅇 Clipboard"
    "󰞅 Emojis"
    " Icons"
    " Picker"
    " VPN"
    " Packages"
    " Bluetooth"
    "󰁹 Power"
)

# Show rofi menu
selected=$(printf '%s\n' "${menu[@]}" | rofi -dmenu -i -p "Quick Actions" -theme ~/.config/rofi/quick-actions.rasi)

# Handle selection
if [ -n "$selected" ]; then
    case "$selected" in
        "󰹑 Screenshot")
            ~/.config/waybar/scripts/take-screenshot.sh
            ;;
        " Layout")
            ~/.config/waybar/scripts/layout-switch-gui.sh
            ;;
        "󰅇 Clipboard")
            clipse-gui
            ;;
        "󰞅 Emojis")
            rofi -show emoji -theme ~/.config/rofi/config.rasi
            ;;
        " Icons")
            ~/.config/waybar/scripts/icon-picker.sh
            ;;
        " Picker")
            ~/.config/waybar/scripts/color-picker.sh
            ;;
        " VPN")
            ~/.config/waybar/scripts/tailscale.sh
            ;;
        " Packages")
            ~/.config/waybar/scripts/installer-wrapper.sh
            ;;
        " Bluetooth")
            kitty --class floating --title 'bluetui' -e bluetui
            ;;
        "󰁹 Power")
            ~/.config/waybar/scripts/power-profile.sh
            ;;
        " Keybinds")
            ~/.config/hypr/scripts/cheatsheet.sh
            ;;
        " Layouts")
            ~/.config/waybar/scripts/layout-switcher.sh
            ;;
        "󰈈 Active")
            pkill hypridle
            notify-send -a "System" "Screen Timeout" "Screen timeout disabled" -i preferences-desktop
            ;;
        "󰈉 Inactive")
            hypridle &
            notify-send -a "System" "Screen Timeout" "Screen timeout enabled" -i preferences-desktop
            ;;
    esac
fi
