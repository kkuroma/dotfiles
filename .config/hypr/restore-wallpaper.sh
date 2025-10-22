#!/bin/bash

# Path to store the last wallpaper
LAST_WALLPAPER="$HOME/.cache/last_wallpaper"
THUMBNAIL_DIR="$HOME/Pictures/Thumbnails"

# Wait a bit for everything to initialize
sleep 2

# Check if last wallpaper file exists and restore it
if [ -f "$LAST_WALLPAPER" ]; then
    wallpaper_path=$(cat "$LAST_WALLPAPER")
    if [ -f "$wallpaper_path" ]; then
        # Get file extension
        extension="${wallpaper_path##*.}"

        if [ "${extension,,}" = "mp4" ]; then
            # Handle MP4 animated wallpaper with gslapper
            killall gslapper 2>/dev/null
            gslapper -o "loop" "*" "$wallpaper_path" &
        else
            # Handle static image wallpaper
            # You can use swww for static images or gslapper for both
            swww img "$wallpaper_path" --transition-type fade --transition-duration 1
        fi
    fi
fi
