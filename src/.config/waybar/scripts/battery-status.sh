#!/usr/bin/env bash

MODE=${1:-1} # 0 horizontal 1 vertical

# Check if battery exists
BATTERY_PATH="/sys/class/power_supply/BAT0"
if [ ! -d "$BATTERY_PATH" ] && [ ! -d "/sys/class/power_supply/BAT1" ]; then
    # No battery found - desktop PC
    echo '{"text":"","tooltip":"<b><span color='"'"'#fab387'"'"'><big>󰐥 Power</big></span></b>\n<span color='"'"'#cdd6f4'"'"'>Desktop — Click for power menu</span>","class":"no-battery"}'
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

if [ -f "$BATTERY_PATH/power_now" ] && [ -f "$BATTERY_PATH/energy_now" ]; then
    power_now=$(cat "$BATTERY_PATH/power_now")
    energy_now=$(cat "$BATTERY_PATH/energy_now")

    if [ "$power_now" -gt 0 ]; then
        if [ "$status" = "Charging" ]; then
            energy_full=$(cat "$BATTERY_PATH/energy_full")
            time_seconds=$(( (energy_full - energy_now) * 3600 / power_now ))
            hours=$((time_seconds / 3600))
            minutes=$(( (time_seconds % 3600) / 60 ))
            tooltip="<b><span color='#fab387'><big>$icon Battery</big></span></b>\n<span color='#89dceb'>Status:</span> <span color='#a6e3a1'>Charging</span>\n<span color='#89dceb'>Level:</span> <span color='#cdd6f4'>${capacity}%</span>\n<span color='#89dceb'>Time:</span> <span color='#cdd6f4'>${hours}h ${minutes}m until full</span>"
        else
            time_seconds=$(( energy_now * 3600 / power_now ))
            hours=$((time_seconds / 3600))
            minutes=$(( (time_seconds % 3600) / 60 ))
            tooltip="<b><span color='#fab387'><big>$icon Battery</big></span></b>\n<span color='#89dceb'>Status:</span> <span color='#f9e2af'>Discharging</span>\n<span color='#89dceb'>Level:</span> <span color='#cdd6f4'>${capacity}%</span>\n<span color='#89dceb'>Time:</span> <span color='#cdd6f4'>${hours}h ${minutes}m remaining</span>"
        fi
    else
        tooltip="<b><span color='#fab387'><big>$icon Battery</big></span></b>\n<span color='#89dceb'>Status:</span> <span color='#cdd6f4'>$status</span>\n<span color='#89dceb'>Level:</span> <span color='#cdd6f4'>${capacity}%</span>"
    fi
elif [ -f "$BATTERY_PATH/current_now" ] && [ -f "$BATTERY_PATH/charge_now" ]; then
    current_now=$(cat "$BATTERY_PATH/current_now")
    charge_now=$(cat "$BATTERY_PATH/charge_now")

    absolute_current_now=${current_now#-}

    if [ "$absolute_current_now" -gt 0 ]; then
        if [ "$status" = "Charging" ]; then
            charge_full=$(cat "$BATTERY_PATH/charge_full")

            time_seconds=$(( (charge_full - charge_now) * 3600 / absolute_current_now ))

            hours=$((time_seconds / 3600))
            minutes=$(( (time_seconds % 3600) / 60 ))
            tooltip="<b><span color='#fab387'><big>$icon Battery</big></span></b>\n<span color='#89dceb'>Status:</span> <span color='#a6e3a1'>Charging</span>\n<span color='#89dceb'>Level:</span> <span color='#cdd6f4'>${capacity}%</span>\n<span color='#89dceb'>Time:</span> <span color='#cdd6f4'>${hours}h ${minutes}m until full</span>"
        else
            time_seconds=$(( charge_now * 3600 / absolute_current_now ))

            hours=$((time_seconds / 3600))
            minutes=$(( (time_seconds % 3600) / 60 ))
            tooltip="<b><span color='#fab387'><big>$icon Battery</big></span></b>\n<span color='#89dceb'>Status:</span> <span color='#f9e2af'>Discharging</span>\n<span color='#89dceb'>Level:</span> <span color='#cdd6f4'>${capacity}%</span>\n<span color='#89dceb'>Time:</span> <span color='#cdd6f4'>${hours}h ${minutes}m remaining</span>"
        fi
    else
        tooltip="<b><span color='#fab387'><big>$icon Battery</big></span></b>\n<span color='#89dceb'>Status:</span> <span color='#cdd6f4'>$status</span>\n<span color='#89dceb'>Level:</span> <span color='#cdd6f4'>${capacity}%</span>"
    fi
else
    tooltip="<b><span color='#fab387'><big>$icon Battery</big></span></b>\n<span color='#89dceb'>Status:</span> <span color='#cdd6f4'>$status</span>\n<span color='#89dceb'>Level:</span> <span color='#cdd6f4'>${capacity}%</span>"
fi

if [ "$MODE" -eq 0 ]; then
    echo "{\"text\":\"$icon $capacity%\",\"tooltip\":\"$tooltip\",\"class\":\"$class\"}"
else
    echo "{\"text\":\"$icon\",\"tooltip\":\"$tooltip\",\"class\":\"$class\"}"
fi