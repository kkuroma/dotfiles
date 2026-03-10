#!/bin/bash
# Bridge between wallpaper.lua (stage 1) and apply-wallpaper.lua (stage 2)
# Extracts matugen colors, generates swatches, then opens the color picker menu

WALLPAPER_PATH="$1"
STATE_DIR="$HOME/.cache/walker-wallpaper"
COLOR_CACHE="$STATE_DIR/colors"

mkdir -p "$COLOR_CACHE"

# Store selected wallpaper path for stage 2
echo "$WALLPAPER_PATH" > "$STATE_DIR/selected_wallpaper"

# Clean old swatches
rm -f "$COLOR_CACHE"/*.png

# For videos, extract colors from the cached frame instead of the raw mp4
THUMB_DIR="$HOME/Pictures/Thumbnails"
extension="${WALLPAPER_PATH##*.}"
extension="${extension,,}"
if [ "$extension" = "mp4" ] || [ "$extension" = "webm" ]; then
    base=$(basename "$WALLPAPER_PATH")
    frame="$THUMB_DIR/${base%.*}.jpg"
    if [ ! -f "$frame" ]; then
        mkdir -p "$THUMB_DIR"
        ffmpeg -i "$WALLPAPER_PATH" -vframes 1 -q:v 2 "$frame" -y 2>/dev/null
    fi
    COLOR_SOURCE="$frame"
else
    COLOR_SOURCE="$WALLPAPER_PATH"
fi

# Extract unique hex colors from matugen debug output
colors=$(matugen -d image "$COLOR_SOURCE" 2>&1 | grep -oP '#[0-9a-fA-F]{6}' | sort -u)

if [ -z "$colors" ]; then
    notify-send "Wallpaper" "No colors extracted from $WALLPAPER_PATH"
    exit 1
fi

# Generate a 128x128 swatch PNG for each color
while read -r hex; do
    [ -z "$hex" ] && continue
    clean="${hex#\#}"
    magick -size 128x128 "xc:$hex" "$COLOR_CACHE/$clean.png"
done <<< "$colors"

# Store the color list for the lua script
echo "$colors" > "$STATE_DIR/colors.txt"

# Open walker with the color picker menu
walker -m menus:apply-wallpaper -t colorpicker
