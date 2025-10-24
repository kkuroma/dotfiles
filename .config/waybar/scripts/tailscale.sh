#!/usr/bin/env bash

# Flag directory
FLAG_DIR="$HOME/Pictures/Flags"

# Function to convert country code to flag SVG path
country_code_to_flag() {
    local code="$1"
    local flag_file="$FLAG_DIR/${code,,}.svg"
    if [ -f "$flag_file" ]; then
        echo "$flag_file"
    else
        echo ""
    fi
}

# Get current exit node status using JSON output
CURRENT_NODE=$(tailscale status --json 2>/dev/null | jq -r '.ExitNodeStatus.TailscaleIPs[0] // empty')

# Build rofi menu from tailscale JSON status
build_menu() {
    # Add "Disconnect VPN" option first with current country flag
    if [ -n "$CURRENT_NODE" ]; then
        # Get current exit node's country code
        current_country_code=$(tailscale status --json 2>/dev/null | jq -r '
            .Peer |
            to_entries[] |
            select(.value.ExitNode == true) |
            .value.Location.CountryCode // empty
        ')

        if [ -n "$current_country_code" ]; then
            current_flag=$(country_code_to_flag "$current_country_code")
            echo "$current_flag"
        else
            echo ""  # Empty flag path if can't determine
        fi
        echo "Disconnect VPN"
        echo "DISABLE"
    fi

    # Parse peers from JSON and extract exit node options, sort by country, remove duplicates
    tailscale status --json 2>/dev/null | jq -r '
        .Peer |
        to_entries[] |
        select(.value.ExitNodeOption == true and .value.Location != null) |
        "\(.value.Location.Country)|\(.value.Location.CountryCode)|\(.value.Location.City)|\(.value.TailscaleIPs[0])"
    ' | sort -t'|' -k1,1 -k3,3 -u | while IFS='|' read -r country country_code city ip; do
        # Get flag SVG path
        flag=$(country_code_to_flag "$country_code")

        # Create menu entry - flag path, country-city as text, IP
        echo "$flag"
        echo "$country - $city"
        echo "$ip"
    done
}

# Create temporary file with menu data
TEMP_MENU=$(mktemp)
build_menu > "$TEMP_MENU"

# Build rofi input with icon\x1ftext format
ROFI_INPUT=$(mktemp)
line_num=1
while read -r line; do
    case $((line_num % 3)) in
        1) flag="$line" ;;
        2) label="$line" ;;
        0)
            ip="$line"
            # Output in rofi format: text\0icon\x1ficon_path
            printf "%s\0icon\x1f%s\n" "$label" "$flag"
            ;;
    esac
    ((line_num++))
done < "$TEMP_MENU" > "$ROFI_INPUT"

# Show rofi menu with grid theme
selected_label=$(cat "$ROFI_INPUT" | rofi -dmenu -i -p "Tailscale VPN" -theme ~/.config/rofi/grid.rasi -format "s")

# Get the corresponding IP from temp menu
if [ -n "$selected_label" ]; then
    # Find the line number of the selected label in TEMP_MENU
    line_num=1
    selected_ip=""
    while read -r line; do
        if [ "$line" = "$selected_label" ]; then
            # IP is on the next line
            selected_ip=$(sed -n "$((line_num + 1))p" "$TEMP_MENU")
            selected_text="$selected_label"
            break
        fi
        ((line_num++))
    done < "$TEMP_MENU"

    if [ "$selected_ip" = "DISABLE" ]; then
        # Disconnect from exit node
        tailscale set --exit-node="" 2>&1 > /dev/null
        if [ $? -eq 0 ]; then
            notify-send "Tailscale VPN" "Disconnected from VPN"
        else
            notify-send "Tailscale VPN" "Failed to disconnect from VPN"
        fi
    elif [ -n "$selected_ip" ]; then
        # Connect to selected exit node
        tailscale set --exit-node="$selected_ip" 2>&1 > /dev/null
        if [ $? -eq 0 ]; then
            notify-send "Tailscale VPN" "Connected to: $selected_text"
        else
            notify-send "Tailscale VPN" "Failed to connect to exit node"
        fi
    fi
fi

# Cleanup
rm -f "$TEMP_MENU" "$ROFI_INPUT"
