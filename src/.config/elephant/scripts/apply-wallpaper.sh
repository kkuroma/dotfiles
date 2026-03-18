#!/bin/bash
# Final stage: apply wallpaper + matugen color scheme
# VALUE format: "HEXCOLOR|scheme-name" or "fixed|theme-name"

STATE_DIR="$HOME/.cache/walker-wallpaper"
THUMB_DIR="$HOME/Pictures/Thumbnails"
VALUE="$1"

HEX="${VALUE%%|*}"
SCHEME="${VALUE##*|}"

WALLPAPER_PATH=$(cat "$STATE_DIR/selected_wallpaper")

if [ -z "$WALLPAPER_PATH" ] || [ ! -f "$WALLPAPER_PATH" ]; then
    notify-send "Wallpaper" "Error: wallpaper not found"
    exit 1
fi

filename=$(basename "$WALLPAPER_PATH")
extension="${filename##*.}"
extension="${extension,,}"

# Store for next boot
echo "$WALLPAPER_PATH" > "$HOME/.cache/last_wallpaper"

# Apply color scheme
if [ "$HEX" = "fixed" ]; then
    /usr/bin/python3 "$HOME/.config/matugen/fixed-themes/apply.py" "$SCHEME"
    kill -SIGUSR1 $(pgrep kitty) 2>/dev/null
else
    matugen color hex "#$HEX" -t "$SCHEME"
fi

# Kill any running animated wallpaper
killall gslapper 2>/dev/null

if pgrep "swww-daemon" > /dev/null; then
    echo "Do nothing lol"
else
    swww-daemon &
fi

if [ "$extension" = "mp4" ]; then
    base="${filename%.*}"
    thumbnail_path="$THUMB_DIR/${base}.jpg"
    cp "$thumbnail_path" "$HOME/.cache/last_wallpaper_static.jpg"

    swww img "$thumbnail_path" \
        --transition-type grow \
        --transition-pos 0.5,0.5 \
        --transition-duration 1.5 \
        --transition-fps 60 \
        --transition-bezier "0.68,-0.55,0.27,1.55" \
        --transition-step 60

    gslapper -o "loop fill" "*" "$WALLPAPER_PATH" &
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

# Generate square crop for other uses
magick "$HOME/.cache/last_wallpaper_static.jpg" \
    -gravity center \
    -extent "%[fx:min(w,h)]x%[fx:min(w,h)]" \
    "$HOME/.cache/last_wallpaper_static_square.jpg"

if [ "$HEX" = "fixed" ]; then
    notify-send -a "Theme" "Applied Fixed Theme" "$SCHEME | $filename" -i "$WALLPAPER_PATH"
else
    notify-send -a "Wallpaper" "Applied Wallpaper" "$filename | #$HEX | $SCHEME" -i "$WALLPAPER_PATH"
fi
