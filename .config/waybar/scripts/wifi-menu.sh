#!/bin/bash

# Scan for WiFi networks and show in rofi
nmcli device wifi rescan

# Get current connection
current=$(nmcli -t -f NAME connection show --active | grep -v "lo" | head -n 1)

# Get list of available networks (deduplicated by SSID, keeping highest signal)
wifi_list=$(nmcli -f SSID,SECURITY,SIGNAL device wifi list | tail -n +2 | sort -k3 -rn | awk '!seen[$1]++')

# Add disconnect option if connected
if [ -n "$current" ]; then
    wifi_list="󰖪 Disconnect from: $current
$wifi_list"
fi

# Show in rofi and get selection
selected=$(echo "$wifi_list" | rofi -dmenu -i -p "Select WiFi Network")

if [ -n "$selected" ]; then
    # Check if disconnect option was selected
    if [[ "$selected" == "󰖪 Disconnect from:"* ]]; then
        nmcli connection down "$current"
        if [ $? -eq 0 ]; then
            notify-send "WiFi" "Disconnected from $current"
        else
            notify-send "WiFi" "Failed to disconnect"
        fi
    else
        # Extract just the SSID (first word)
        ssid=$(echo "$selected" | awk '{print $1}')

        # Check if network requires password
        security=$(nmcli -f SSID,SECURITY device wifi list | grep "^$ssid" | awk '{print $2}')

        if [ "$security" != "--" ]; then
            # Prompt for password
            password=$(rofi -dmenu -password -p "Password for $ssid")
            if [ -n "$password" ]; then
                nmcli device wifi connect "$ssid" password "$password"
            else
                # No password provided, try connecting without it (might use saved credentials)
                nmcli device wifi connect "$ssid"
            fi
        else
            # No password needed
            nmcli device wifi connect "$ssid"
        fi

        # Show notification
        if [ $? -eq 0 ]; then
            notify-send "WiFi" "Connected to $ssid"
        else
            notify-send "WiFi" "Failed to connect to $ssid"
        fi
    fi
fi
