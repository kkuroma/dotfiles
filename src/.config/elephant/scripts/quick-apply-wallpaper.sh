#!/bin/bash
# Quick-apply wallpaper: uses first color + scheme-content, no color picker
WALLPAPER_PATH="$1"
THUMB_DIR="$HOME/Pictures/Thumbnails"

extension="${WALLPAPER_PATH##*.}"
extension="${extension,,}"

# Get source for color extraction (frame for videos)
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

# Apply with default: first color (index 0), scheme-content
matugen image "$COLOR_SOURCE" --source-color-index 0 -t scheme-content

# Store for next boot
echo "$WALLPAPER_PATH" > "$HOME/.cache/last_wallpaper"

filename=$(basename "$WALLPAPER_PATH")

killall gslapper 2>/dev/null

if [ "$extension" = "mp4" ]; then
    base=$(basename "$WALLPAPER_PATH")
    thumbnail_path="$THUMB_DIR/${base%.*}.jpg"
    cp "$thumbnail_path" "$HOME/.cache/last_wallpaper_static.jpg"
    swww img "$thumbnail_path" \
        --transition-type grow \
        --transition-pos 0.5,0.5 \
        --transition-duration 1.5 \
        --transition-fps 60 \
        --transition-bezier "0.68,-0.55,0.27,1.55" \
        --transition-step 60
    gslapper -o "loop full" "*" "$WALLPAPER_PATH" &
else
    magick "$WALLPAPER_PATH[0]" +adjoin "$HOME/.cache/last_wallpaper_static.jpg"
    swww img "$WALLPAPER_PATH" \
        --transition-type grow \
        --transition-pos 0.5,0.5 \
        --transition-duration 1.5 \
        --transition-fps 60 \
        --transition-bezier "0.68,-0.55,0.27,1.55" \
        --transition-step 60
fi

magick "$HOME/.cache/last_wallpaper_static.jpg" \
    -gravity center \
    -extent "%[fx:min(w,h)]x%[fx:min(w,h)]" \
    "$HOME/.cache/last_wallpaper_static_square.jpg"

notify-send -a "Wallpaper" "Applied Wallpaper" "$filename" -i "$WALLPAPER_PATH"
