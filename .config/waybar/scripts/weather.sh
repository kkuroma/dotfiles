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

# get unit, defaults to f
if [ -f "$STATE_FILE" ]; then
    unit=$(cat "$STATE_FILE")
else
    unit="f"
    echo "f" > "$STATE_FILE"
fi

# get weather condition from wttr.in
weather_code=$(curl -s 'wttr.in/?format=%c' 2>/dev/null)

# get temperature in the appropriate unit
if [ "$unit" = "f" ]; then
    temperature=$(curl -s 'wttr.in/?format=%t&u' 2>/dev/null | sed 's/+//g')
else
    temperature=$(curl -s 'wttr.in/?format=%t&m' 2>/dev/null | sed 's/+//g')
fi

# map weather code to
case "$weather_code" in
    "✨ "|"Clear") icon="󰖙" ;;                   # Clear/Sunny
    "⛅️ "|"Partly cloudy") icon="󰖕" ;;           # Partly cloudy
    "☁️ "|"Cloudy") icon="󰖐" ;;                  # Cloudy
    "🌫️ "|"Fog") icon="󰖑" ;;                     # Fog
    "🌧️ "|"Rain"|"Light rain") icon="󰖖" ;;       # Rain
    "⛈️ "|"Thunderstorm") icon="󰙾" ;;            # Thunderstorm
    "🌨️ "|"Snow") icon="󰖘" ;;                    # Snow
    "🌦️ "|"Light showers") icon="󰼳" ;;           # Light showers
    *) icon="󰖙" ;;                              # Default = sunny
esac

echo "$icon $temperature"
