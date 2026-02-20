#!/bin/bash

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
CACHE_DIR="$HOME/.cache/wallpaper-thumbnails"
THUMBNAIL_DIR="$HOME/Pictures/Thumbnails"
mkdir -p "$CACHE_DIR"
mkdir -p "$THUMBNAIL_DIR"

# generate thumbnails and cache them
generate_thumbnails() {
    find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.webp" -o -iname "*.webm" \) | while read -r img; do
        filename=$(basename "$img")
        thumbnail="$CACHE_DIR/${filename%.*}.png"
        if [ ! -f "$thumbnail" ] || [ "$img" -nt "$thumbnail" ]; then
            magick "$img[0]" -resize 200x200^ -gravity center -extent 200x200 +adjoin "$thumbnail" 2>/dev/null # [0] for gifs
        fi
    done
}

# generate thumbnails for mp4
generate_video_thumbnails() {
    find "$WALLPAPER_DIR" -type f -iname "*.mp4" | while read -r video; do
        filename=$(basename "$video")
        full_thumbnail="$THUMBNAIL_DIR/${filename%.*}.jpg"
        small_thumbnail="$CACHE_DIR/${filename%.*}.png"
        if [ ! -f "$full_thumbnail" ] || [ "$video" -nt "$full_thumbnail" ]; then
            ffmpeg -i "$video" -vframes 1 -q:v 2 "$full_thumbnail" -y 2>/dev/null
        fi
        if [ -f "$full_thumbnail" ]; then
            if [ ! -f "$small_thumbnail" ] || [ "$full_thumbnail" -nt "$small_thumbnail" ]; then
                magick "$full_thumbnail" -resize 200x200^ -gravity center -extent 200x200 "$small_thumbnail" 2>/dev/null
            fi
        fi
    done
}

# generate wallpaper theme using matugen
generate_wallpaper_theme() {
    local thumbnail_path="$1"
    local color_cache_dir="$HOME/.cache/hexcolors"

    mkdir -p "$color_cache_dir"
    rm -f "$color_cache_dir"/*.png

    local colors=$(matugen -d image "$thumbnail_path" 2>&1 | grep -oP '#[0-9a-fA-F]{6}' | tr -d '#' | sort -u)

    while read -r hex; do
        [ -z "$hex" ] && continue
        magick -size 128x128 xc:"#$hex" "$color_cache_dir/$hex.png"
    done <<< "$colors"

    local selected=$(find "$color_cache_dir" -name "*.png" | while read -r icon_path; do
        local name=$(basename "$icon_path" .png)
        echo -en "#$name\0icon\x1f$icon_path\n"
    done | rofi -dmenu -i -p "Select Accent" -theme ~/.config/rofi/grid-colors.rasi -show-icons -theme-str 'element-icon { size: 6em; }')

    [ -n "$selected" ] && matugen color hex "$selected"

    swww img "$thumbnail_path" \
        --transition-type grow \
        --transition-pos 0.5,0.5 \
        --transition-duration 1.5 \
        --transition-fps 60 \
        --transition-bezier "0.68,-0.55,0.27,1.55" \
        --transition-step 60
}

if command -v magick &> /dev/null || command -v convert &> /dev/null; then
    generate_thumbnails &
fi
if command -v ffmpeg &> /dev/null; then
    generate_video_thumbnails &
fi

# build rofi entries
build_menu() {
    find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.webp" -o -iname "*.mp4" \) -printf "%f\n" | sort | while read -r wallpaper; do
        thumbnail="$CACHE_DIR/${wallpaper%.*}.png"
        if [ -f "$thumbnail" ]; then
            printf "%s\0icon\x1f%s\n" "$wallpaper" "$thumbnail"
        else
            echo "$wallpaper"
        fi
    done
}

# get all wallpapers
get_wallpapers() {
    find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.webp" -o -iname "*.mp4" \) -printf "%f\n"
}

# random wallpaper selection
if [ "$1" = "random" ]; then
    # Select a random wallpaper from the list
    mapfile -t wallpapers < <(get_wallpapers)
    if [ ${#wallpapers[@]} -eq 0 ]; then
        notify-send "Error" "No wallpapers found in $WALLPAPER_DIR"
        exit 1
    fi
    selected="${wallpapers[$RANDOM % ${#wallpapers[@]}]}"
else
    selected=$(build_menu | rofi -dmenu -i -p "Wallpaper" -show-icons -theme ~/.config/rofi/grid.rasi -theme-str 'element-icon { size: 6em; }' -me-select-entry '' -me-accept-entry MousePrimary)
fi

# set wallpaper
if [ -n "$selected" ]; then
    selected=$(echo "$selected" | tr -d '\0')
    wallpaper_path="$WALLPAPER_DIR/$selected"
    if [ -f "$wallpaper_path" ]; then
        echo "$wallpaper_path" > "$HOME/.cache/last_wallpaper" # store last wallpaper for next boot
        extension="${selected##*.}"
        killall gslapper 2>/dev/null
        if [ "${extension,,}" = "mp4" ]; then
            # Generate thumbnail from mp4
            filename=$(basename "$selected")
            thumbnail_path="$THUMBNAIL_DIR/${filename%.*}.jpg"
            cp "$thumbnail_path" "$HOME/.cache/last_wallpaper_static.jpg"
            generate_wallpaper_theme "$thumbnail_path"
            gslapper -o "loop full" "*" "$wallpaper_path" & # animated wallpaper
        else
            # Static wallpaper, [0] for gifs
            magick "$wallpaper_path[0]" +adjoin "$HOME/.cache/last_wallpaper_static.jpg"
            generate_wallpaper_theme "$wallpaper_path"   
        fi
        notify-send -a "Wallpaper" "Applying Wallpaper & Theme" "$selected" -i "$wallpaper_path"
        magick "$HOME/.cache/last_wallpaper_static.jpg" \
        -gravity center \
        -extent "%[fx:min(w,h)]x%[fx:min(w,h)]" \
        "$HOME/.cache/last_wallpaper_static_square.jpg"
    else
        notify-send -a "Wallpaper" "Error" "Wallpaper file not found: $wallpaper_path"
    fi
fi
