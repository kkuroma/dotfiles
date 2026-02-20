#!/bin/bash

MODE=${1:-1}

TEMP_FILE="$HOME/.cache/temp-screenshot.png"
TIMESTAMP=$(date +"%Y:%m:%d-%H:%M:%S:%3N")
SAVE_PATH="$HOME/Pictures/Screenshots/${TIMESTAMP}.png"

grim -t png "$TEMP_FILE"

if [ $? -ne 0 ]; then
    notify-send -a "Screenshot" "Screenshot Failed" "Could not capture the screen."
    exit 1
fi

wl-copy -t image/png < "$TEMP_FILE"

if [ "$MODE" -eq 0 ]; then
    
    notify-send -a "Screenshot" "Full Screenshot Taken" "Copied to clipboard." --icon="$TEMP_FILE"
    
    rm -f "$TEMP_FILE"

elif [ "$MODE" -eq 1 ]; then

    satty \
        --disable-notifications \
        --filename "$TEMP_FILE" \
        --output-filename "$SAVE_PATH" \
        --copy-command "wl-copy -t image/png && notify-send -a 'Screenshot' 'Screenshot Copied' 'Copied to clipboard' --icon='$TEMP_FILE'" \
        --early-exit \
        2>/dev/null

    if [ -f "$SAVE_PATH" ]; then
        notify-send -a "Screenshot" "Screenshot Saved" "Saved to $SAVE_PATH" --icon="$SAVE_PATH"
    fi
    
    rm -f "$TEMP_FILE"

else
    notify-send -a "Screenshot" "Invalid Mode" "Usage: take-screenshot.sh [0|1]"
fi