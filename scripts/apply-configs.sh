#!/bin/bash
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/src"
CONFIG_TARGET="$HOME/.config"
CONFIG_SOURCE="$REPO_DIR/.config"

# Files that should NOT be overwritten if they already exist at the destination.
# Format: "config_name:relative/path/to/file"
PRESERVE_FILES=(
    "hypr:monitors.conf"
    "hypr:workspace.conf"
)

RICE_CONFIGS=(
    # Main rice
    "hypr"
    "waybar"
    "swaync"
    "swayosd"
    "systemd"
    "elephant"
    "walker"

    # Theming
    "kdeglobals"
    "qt5ct"
    "qt6ct"
    "QtProject.conf"
    "matugen"
    "fontconfig"

    # Riced applications
    "GIMP/3.0/themes"
    "GIMP/3.0/theme.css"
    "fcitx5"
    "nvim"

    # File manager (Dolphin)
    "dolphinrc"
    "filetypesrc"
    "trashrc"
    "mimeapps.list"

    # Terminal
    "kitty"
    "fastfetch"
    "btop"
    
    # Media players
    "mpv"
    "imv"
)

for config in "${RICE_CONFIGS[@]}"; do
    SOURCE_PATH="$CONFIG_SOURCE/$config"
    TARGET_PATH="$CONFIG_TARGET/$config"
    if [ -d "$SOURCE_PATH" ]; then
        mkdir -p "$TARGET_PATH"
        EXCLUDES=()
        for entry in "${PRESERVE_FILES[@]}"; do
            prefix="${entry%%:*}"
            file="${entry#*:}"
            if [ "$prefix" = "$config" ]; then
                EXCLUDES+=(--exclude="/$file")
            fi
        done
        rsync -a --delete "${EXCLUDES[@]}" "$SOURCE_PATH/" "$TARGET_PATH/"
        echo "  ✓ Synced $config (Preserved files ignored)"
    elif [ -f "$SOURCE_PATH" ]; then
        cp "$SOURCE_PATH" "$TARGET_PATH"
    fi
done

echo "Part 2: Copying ~/.zshrc"
cp "$REPO_DIR/.zshrc" "$HOME/.zshrc"
cp -r "$REPO_DIR/Scripts" "$HOME"

echo "Part 3: Enabling execution for scripts"
find ~/.config/waybar -type f -name "*.sh" -exec chmod +x {} \;
find ~/.config/hypr -type f -name "*.sh" -exec chmod +x {} \;
find ~/Scripts -type f -name "*.sh" -exec chmod +x {} \;

echo "Part 4: Creating other files/directories"
LATITUDE="0.0"
LONGITUDE="0.0"
mkdir ~/Pictures
mkdir ~/Pictures/Wallpapers
mkdir ~/Pictures/Screenshots
cp -r "$REPO_DIR/Flags" ~/Pictures #flags for VPN
if [ ! -f "~/.weather_location" ]; then # location for weather tracking
    echo "$LATITUDE,$LONGITUDE" > ~/.weather_location
    chmod 600 ~/.weather_location
fi

# Copy figlet fonts
if [ -d "$REPO_DIR/figlet-fonts" ]; then
    sudo cp -r "$REPO_DIR/figlet-fonts/"* /usr/share/figlet/fonts/
    echo "  ✓ Copied figlet fonts to /usr/share/figlet/fonts/"
else
    echo "  ✗ figlet-fonts directory not found"
fi

# Copy BreezeX-Black icon theme
if [ -d "$REPO_DIR/BreezeX-Black" ]; then
    mkdir -p ~/.local/share/icons
    cp -r "$REPO_DIR/BreezeX-Black" ~/.local/share/icons/
    echo "  ✓ Copied BreezeX-Black to ~/.local/share/icons/"
else
    echo "  ✗ BreezeX-Black directory not found"
fi