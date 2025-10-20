#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
CACHE_DIR="$HOME/.cache/wallpaper-thumbnails"

# Create cache directory if it doesn't exist
mkdir -p "$CACHE_DIR"

# Generate thumbnails for all wallpapers
generate_thumbnails() {
    find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.webp" \) | while read -r img; do
        filename=$(basename "$img")
        thumbnail="$CACHE_DIR/${filename%.*}.png"

        # Only generate if thumbnail doesn't exist or is older than original
        if [ ! -f "$thumbnail" ] || [ "$img" -nt "$thumbnail" ]; then
            # Use [0] to explicitly get the first frame for GIFs
            convert "$img[0]" -resize 200x200^ -gravity center -extent 200x200 "$thumbnail" 2>/dev/null
        fi
    done
}

# Check if ImageMagick is installed
if command -v convert &> /dev/null; then
    generate_thumbnails &
fi

# Build rofi entries with image previews
build_menu() {
    find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.webp" \) -printf "%f\n" | sort | while read -r wallpaper; do
        thumbnail="$CACHE_DIR/${wallpaper%.*}.png"
        if [ -f "$thumbnail" ]; then
            printf "%s\0icon\x1f%s\n" "$wallpaper" "$thumbnail"
        else
            echo "$wallpaper"
        fi
    done
}

# Show rofi menu with image previews
selected=$(build_menu | rofi -dmenu -i -p "Wallpaper" -show-icons -theme-str 'element-icon { size: 3em; }' -me-select-entry '' -me-accept-entry MousePrimary)

# If user selected something, set it as wallpaper
if [ -n "$selected" ]; then
    # Clean up the selection (remove any null bytes or extra data)
    selected=$(echo "$selected" | tr -d '\0')
    wallpaper_path="$WALLPAPER_DIR/$selected"

    # Check if file exists
    if [ -f "$wallpaper_path" ]; then
        # Reset notification and send notification
        notify-send "Applying Wallpaper & Theme" "$selected" -i "$wallpaper_path"
        killall dunst; dunst &
        # Apply wallpaper and generate colors system-wide using matugen
        matugen image "$wallpaper_path" &
        
    else
        notify-send "Error" "Wallpaper file not found: $wallpaper_path"
    fi
fi
