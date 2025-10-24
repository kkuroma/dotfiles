#!/bin/bash

nmcli device wifi rescan --wait 8
current=$(nmcli -t -f NAME connection show --active | grep -v "lo" | head -n 1)
wifi_list=$(nmcli -t -f SSID,SECURITY,SIGNAL device wifi list | \
            sort -t: -k3 -rn | \
            awk -F: '!seen[$1]++')
display_list=$(echo "$wifi_list" | awk -F: '{
    ssid = $1
    security = $2
    signal = $3
    # Add lock icon based on security
    if (security == "--") {
        icon = ""
        sec_text = "Open"
    } else {
        icon = ""
        sec_text = security
    }
    printf "%s %-35s %3s%%\n", icon, ssid " (" sec_text ")", signal
}')
if [ -n "$current" ]; then
    display_list="󰖪 Disconnect from: $current
$display_list"
fi

selected_display=$(echo -e "$display_list" | rofi -dmenu -i -p "Select WiFi Network")
if [ -z "$selected_display" ]; then
    exit 0
fi
if [[ "$selected_display" == "󰖪 Disconnect from:"* ]]; then
    nmcli connection down "$current"
    if [ $? -eq 0 ]; then
        notify-send "WiFi Manager" "󰖪 Disconnected from $current"
    else
        notify-send "WiFi Manager" " Failed to disconnect"
    fi
else
    # Remove icon and extract SSID
    ssid=$(echo "$selected_display" | sed 's/^. //' | sed -E 's/\s+\(.*\)\s+[0-9]+%?$//')
    security=$(echo "$wifi_list" | grep -F "^$ssid:" | cut -d: -f2)
    
    if [ -z "$security" ] || [ "$security" == "--" ]; then
        # Open Network
        nmcli device wifi connect "$ssid"
        
    elif [[ "$security" == *"EAP"* ]]; then
        if nmcli -t -f NAME connection show | grep -q "^$ssid$"; then
            nmcli connection up id "$ssid"
        else
            notify-send -u critical "WiFi" "No profile for '$ssid'. Please create one first."
            exit 1
        fi
        
    else
        if nmcli -t -f NAME connection show | grep -q "^$ssid$"; then
            nmcli connection up id "$ssid"
        else
            password=$(rofi -dmenu -password -p "Password for $ssid")
            if [ -n "$password" ]; then
                nmcli device wifi connect "$ssid" password "$password"
            else
                exit 0
            fi
        fi
    fi
    if [ $? -eq 0 ]; then
        sleep 4
        connectivity=$(nmcli -t -f CONNECTIVITY general | cut -d: -f2)
        if [ "$connectivity" == "portal" ]; then
            notify-send "WiFi Manager" "󰖩 Connected to $ssid.
Portal detected, please log in."
        else
            notify-send "WiFi Manager" "󰖩 Connected to $ssid"
        fi
    else
        notify-send "WiFi Manager" " Failed to connect to $ssid"
    fi
fi