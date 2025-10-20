#!/bin/bash

STATE_FILE="/tmp/waybar_weather_unit"

# Handle toggle
if [ "$1" = "toggle" ]; then
    if [ -f "$STATE_FILE" ] && [ "$(cat "$STATE_FILE")" = "f" ]; then
        echo "c" > "$STATE_FILE"
    else
        echo "f" > "$STATE_FILE"
    fi
    # Force waybar to update
    pkill -RTMIN+8 waybar
    exit 0
fi

# Get current unit preference (default to Celsius)
if [ -f "$STATE_FILE" ]; then
    unit=$(cat "$STATE_FILE")
else
    unit="c"
    echo "c" > "$STATE_FILE"
fi

# Get weather condition code from wttr.in
weather_code=$(curl -s 'wttr.in/?format=%c' 2>/dev/null)

# Get temperature in the appropriate unit
if [ "$unit" = "f" ]; then
    temperature=$(curl -s 'wttr.in/?format=%t&u' 2>/dev/null | sed 's/+//g')
else
    temperature=$(curl -s 'wttr.in/?format=%t&m' 2>/dev/null | sed 's/+//g')
fi

# Map weather conditions to Nerd Font icons
case "$weather_code" in
    "✨"|"Clear") icon="󰖙" ;;           # Clear/Sunny
    "⛅"|"Partly cloudy") icon="󰖕" ;;  # Partly cloudy
    "☁️"|"Cloudy") icon="󰖐" ;;         # Cloudy
    "🌫️"|"Fog") icon="󰖑" ;;            # Fog
    "🌧️"|"Rain"|"Light rain") icon="󰖖" ;; # Rain
    "⛈️"|"Thunderstorm") icon="󰙾" ;;   # Thunderstorm
    "🌨️"|"Snow") icon="󰖘" ;;           # Snow
    "🌦️"|"Light showers") icon="󰼳" ;; # Light showers
    *) icon="󰖙" ;;                     # Default to sunny
esac

echo "$icon $temperature"
