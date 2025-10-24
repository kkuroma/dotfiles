#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
CACHE_DIR="$HOME/.cache/wallpaper-thumbnails"
THUMBNAIL_DIR="$HOME/Pictures/Thumbnails"

# Create directories if they don't exist
mkdir -p "$CACHE_DIR"
mkdir -p "$THUMBNAIL_DIR"

# Generate thumbnails for all wallpapers (static images)
generate_thumbnails() {
    find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.webp" -o -iname "*.webm" \) | while read -r img; do
        filename=$(basename "$img")
        thumbnail="$CACHE_DIR/${filename%.*}.png"

        # Only generate if thumbnail doesn't exist or is older than original
        if [ ! -f "$thumbnail" ] || [ "$img" -nt "$thumbnail" ]; then
            # Use [0] to explicitly get the first frame for GIFs
            convert "$img[0]" -resize 200x200^ -gravity center -extent 200x200 "$thumbnail" 2>/dev/null
        fi
    done
}

# Generate thumbnails for mp4 files
generate_video_thumbnails() {
    find "$WALLPAPER_DIR" -type f -iname "*.mp4" | while read -r video; do
        filename=$(basename "$video")
        # Full-size thumbnail for matugen in ~/Pictures/Thumbnails
        full_thumbnail="$THUMBNAIL_DIR/${filename%.*}.jpg"
        # Small thumbnail for rofi preview in cache
        small_thumbnail="$CACHE_DIR/${filename%.*}.png"

        # Generate full-size thumbnail if it doesn't exist or is older than original
        if [ ! -f "$full_thumbnail" ] || [ "$video" -nt "$full_thumbnail" ]; then
            ffmpeg -i "$video" -vframes 1 -q:v 2 "$full_thumbnail" -y 2>/dev/null
        fi

        # Generate small thumbnail for rofi if full thumbnail exists
        if [ -f "$full_thumbnail" ]; then
            if [ ! -f "$small_thumbnail" ] || [ "$full_thumbnail" -nt "$small_thumbnail" ]; then
                convert "$full_thumbnail" -resize 200x200^ -gravity center -extent 200x200 "$small_thumbnail" 2>/dev/null
            fi
        fi
    done
}

# Check if ImageMagick is installed and generate thumbnails
if command -v convert &> /dev/null; then
    generate_thumbnails &
fi

# Check if ffmpeg is installed and generate video thumbnails
if command -v ffmpeg &> /dev/null; then
    generate_video_thumbnails &
fi

# Build rofi entries with image previews
build_menu() {
    # Include both static images and mp4 files
    find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.webp" -o -iname "*.mp4" \) -printf "%f\n" | sort | while read -r wallpaper; do
        thumbnail="$CACHE_DIR/${wallpaper%.*}.png"
        if [ -f "$thumbnail" ]; then
            printf "%s\0icon\x1f%s\n" "$wallpaper" "$thumbnail"
        else
            echo "$wallpaper"
        fi
    done
}

# Show rofi menu with image previews using grid theme
selected=$(build_menu | rofi -dmenu -i -p "Wallpaper" -show-icons -theme ~/.config/rofi/grid.rasi -theme-str 'element-icon { size: 3em; }' -me-select-entry '' -me-accept-entry MousePrimary)

# If user selected something, set it as wallpaper
if [ -n "$selected" ]; then
    # Clean up the selection (remove any null bytes or extra data)
    selected=$(echo "$selected" | tr -d '\0')
    wallpaper_path="$WALLPAPER_DIR/$selected"

    # Check if file exists
    if [ -f "$wallpaper_path" ]; then
        # Save the wallpaper path for restoration on next boot
        echo "$wallpaper_path" > "$HOME/.cache/last_wallpaper"

        # Get file extension
        extension="${selected##*.}"

        # Kill any existing gslapper processes
        killall gslapper 2>/dev/null

        if [ "${extension,,}" = "mp4" ]; then
            # Handle MP4 animated wallpaper
            filename=$(basename "$selected")
            thumbnail_path="$THUMBNAIL_DIR/${filename%.*}.jpg"

            # Copy thumbnail to cache for hyprlock/SDDM
            cp "$thumbnail_path" "$HOME/.cache/last_wallpaper_static.jpg"

            # Copy to SDDM theme directory (requires sudo)
            sudo cp "$HOME/.cache/last_wallpaper_static.jpg" /usr/share/sddm/themes/sugar-dark/Background.jpg

            # Apply theme using the thumbnail
            matugen image "$thumbnail_path" &

            # Wait a bit for matugen to finish
            sleep 0.5 
            
            # Reset notification style and send notification
            killall dunst; dunst &
            notify-send "Applying Animated Wallpaper & Theme" "$selected" -i "$thumbnail_path"

            # Set animated wallpaper using gslapper
            gslapper -o "loop" "*" "$wallpaper_path" &
        else
            # Handle static image wallpaper
            # Convert and save to cache for hyprlock/SDDM (always as JPG)
            convert "$wallpaper_path" "$HOME/.cache/last_wallpaper_static.jpg"

            # Copy to SDDM theme directory (requires sudo)
            sudo cp "$HOME/.cache/last_wallpaper_static.jpg" /usr/share/sddm/themes/sugar-dark/Background.jpg

            # Apply wallpaper and generate colors system-wide using matugen
            matugen image "$wallpaper_path" &

            # Reset notification style and send notification
            sleep 0.5
            killall dunst; dunst &
            notify-send "Applying Wallpaper & Theme" "$selected" -i "$wallpaper_path"
        fi
    else
        notify-send "Error" "Wallpaper file not found: $wallpaper_path"
    fi
fi
