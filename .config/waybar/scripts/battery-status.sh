#!/usr/bin/env bash

# Check if battery exists
BATTERY_PATH="/sys/class/power_supply/BAT0"
if [ ! -d "$BATTERY_PATH" ] && [ ! -d "/sys/class/power_supply/BAT1" ]; then
    # No battery found - desktop PC
    echo '{"text":"󰐥","tooltip":"Power Menu","class":"no-battery"}'
    exit 0
fi

# Find battery (could be BAT0 or BAT1)
if [ -d "$BATTERY_PATH" ]; then
    BATTERY="BAT0"
elif [ -d "/sys/class/power_supply/BAT1" ]; then
    BATTERY="BAT1"
    BATTERY_PATH="/sys/class/power_supply/BAT1"
fi

# Get battery info
capacity=$(cat "$BATTERY_PATH/capacity")
status=$(cat "$BATTERY_PATH/status")

# Determine icon based on capacity and status
if [ "$status" = "Charging" ]; then
    icon="󰂄"  # Charging icon
    class="charging"
elif [ "$status" = "Full" ]; then
    icon="󰁹"  # Full battery
    class="full"
else
    # Discharging - show appropriate battery level icon
    if [ "$capacity" -ge 90 ]; then
        icon="󰁹"
        class="full"
    elif [ "$capacity" -ge 70 ]; then
        icon="󰂀"
        class="good"
    elif [ "$capacity" -ge 50 ]; then
        icon="󰁾"
        class="medium"
    elif [ "$capacity" -ge 30 ]; then
        icon="󰁼"
        class="low"
    elif [ "$capacity" -ge 10 ]; then
        icon="󰁺"
        class="critical"
    else
        icon="󰂃"
        class="critical"
    fi
fi

# Calculate time remaining/until full
if [ -f "$BATTERY_PATH/power_now" ] && [ -f "$BATTERY_PATH/energy_now" ]; then
    power_now=$(cat "$BATTERY_PATH/power_now")
    energy_now=$(cat "$BATTERY_PATH/energy_now")

    if [ "$power_now" -gt 0 ]; then
        if [ "$status" = "Charging" ]; then
            energy_full=$(cat "$BATTERY_PATH/energy_full")
            time_seconds=$(( (energy_full - energy_now) * 3600 / power_now ))
            hours=$((time_seconds / 3600))
            minutes=$(( (time_seconds % 3600) / 60 ))
            tooltip="$icon $capacity% - ${hours}h ${minutes}m until full"
        else
            time_seconds=$(( energy_now * 3600 / power_now ))
            hours=$((time_seconds / 3600))
            minutes=$(( (time_seconds % 3600) / 60 ))
            tooltip="$icon $capacity% - ${hours}h ${minutes}m remaining"
        fi
    else
        tooltip="$icon $capacity% - $status"
    fi
else
    tooltip="$icon $capacity% - $status"
fi

# Output JSON for waybar
echo "{\"text\":\"$icon $capacity%\",\"tooltip\":\"$tooltip\",\"class\":\"$class\"}"
