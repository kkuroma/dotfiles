#!/bin/bash

color=$(hyprpicker -a -f hex)

if [ $? -eq 0 ] && [ -n "$color" ]; then
    # Create a temporary image file with the picked color
    TEMP_ICON="/tmp/color-picker-icon.png"
    magick -size 128x128 xc:"$color" "$TEMP_ICON"
    
    notify-send -a "Color Picker" "Picked Color" "Copied: $color" --icon="$TEMP_ICON"
else
    notify-send -a "Color Picker" "Cancelled" "No colors picked"
fi