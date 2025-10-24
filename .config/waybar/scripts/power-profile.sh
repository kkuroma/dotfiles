#!/usr/bin/env bash

# Get current power profile
current=$(powerprofilesctl get)

# Build menu with icons
menu=()

if [ "$current" = "performance" ]; then
    menu+=("󰓅 Performance (Active)")
else
    menu+=("󰓅 Performance")
fi

if [ "$current" = "balanced" ]; then
    menu+=("󰾅 Balanced (Active)")
else
    menu+=("󰾅 Balanced")
fi

if [ "$current" = "power-saver" ]; then
    menu+=("󰾆 Power Saver (Active)")
else
    menu+=("󰾆 Power Saver")
fi

# Show rofi menu
selected=$(printf '%s\n' "${menu[@]}" | rofi -dmenu -i -p "Power Profile")

# Handle selection
if [ -n "$selected" ]; then
    case "$selected" in
        "󰓅 Performance"*|"󰓅 Performance (Active)")
            powerprofilesctl set performance
            notify-send "Power Profile" "Switched to Performance mode"
            ;;
        "󰾅 Balanced"*|"󰾅 Balanced (Active)")
            powerprofilesctl set balanced
            notify-send "Power Profile" "Switched to Balanced mode"
            ;;
        "󰾆 Power Saver"*|"󰾆 Power Saver (Active)")
            powerprofilesctl set power-saver
            notify-send "Power Profile" "Switched to Power Saver mode"
            ;;
    esac
fi
