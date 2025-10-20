#!/bin/bash

# Scan for WiFi networks and show in rofi
nmcli device wifi rescan

# Get list of available networks
wifi_list=$(nmcli -f SSID,SECURITY,SIGNAL device wifi list | tail -n +2)

# Show in rofi and get selection
selected=$(echo "$wifi_list" | rofi -dmenu -i -p "Select WiFi Network" | awk '{print $1}')

if [ -n "$selected" ]; then
    # Check if network requires password
    security=$(nmcli -f SSID,SECURITY device wifi list | grep "^$selected" | awk '{print $2}')

    if [ "$security" != "--" ]; then
        # Prompt for password
        password=$(rofi -dmenu -password -p "Password for $selected")
        if [ -n "$password" ]; then
            nmcli device wifi connect "$selected" password "$password"
        fi
    else
        # No password needed
        nmcli device wifi connect "$selected"
    fi

    # Show notification
    if [ $? -eq 0 ]; then
        notify-send "WiFi" "Connected to $selected"
    else
        notify-send "WiFi" "Failed to connect to $selected"
    fi
fi
