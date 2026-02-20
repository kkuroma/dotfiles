#!/bin/bash
wayfreeze &
PID=$!
sleep 0.1
REGION=$(slurp)
if [ -n "$REGION" ]; then
    TEMP_FILE="$HOME/.cache/temp-screenshot.png"
    TIMESTAMP=$(date +"%Y:%m:%d-%H:%M:%S:%3N")
    SAVE_PATH="$HOME/Pictures/Screenshots/${TIMESTAMP}.png"
    grim -g "$REGION" -t png "$TEMP_FILE"
    wl-copy -t image/png < "$TEMP_FILE"
    killall wayfreeze
    satty --disable-notifications --filename "$TEMP_FILE" --output-filename "$SAVE_PATH" --copy-command "wl-copy -t image/png && notify-send -a 'Screenshot' 'Screenshot Copied' 'Copied to clipboard' --icon='$TEMP_FILE'" --early-exit --init-tool crop 2>/dev/null
    if [ -f "$SAVE_PATH" ]; then
        notify-send -a "Screenshot" "Screenshot Saved" "Saved to $SAVE_PATH" --icon="$SAVE_PATH"
    fi
    rm -f "$TEMP_FILE"
else
    notify-send -a "Screenshot" "Screenshot Cancelled" "No region selected"
fi
kill $PID 2>/dev/null
wait $PID 2>/dev/null