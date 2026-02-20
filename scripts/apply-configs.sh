#!/bin/bash
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/src"
CONFIG_TARGET="$HOME/.config"
CONFIG_SOURCE="$REPO_DIR/.config"

RICE_CONFIGS=(
    # Main rice
    #"hypr"
    "waybar"
    "swaync"
    #"rofi"
    "wlogout"
    "nwg-dock-hyprland"

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
    if [ -e "$CONFIG_SOURCE/$config" ]; then
        if [ -d "$CONFIG_SOURCE/$config" ]; then
            mkdir -p "$CONFIG_TARGET/$config"
            rsync -a --delete "$CONFIG_SOURCE/$config/" "$CONFIG_TARGET/$config/" || {
                echo "  ✗ Failed to sync $config"
                continue
            }
        else
            cp "$CONFIG_SOURCE/$config" "$CONFIG_TARGET/$config" || {
                echo "  ✗ Failed to copy $config"
                continue
            }
        fi
        echo "  ✓ Copied $config"
        ((SYNCED_COUNT++))
    fi
done

echo "Part 2: Copying ~/.mozilla"
MOZILLA_TARGET="$HOME/.mozilla"
MOZILLA_SOURCE="$REPO_DIR/.mozilla"
RICE_CONFIGS=(
    "firefox/xvm2110c.default-release/chrome"
    "firefox/xvm2110c.default-release/user.js"
)
for config in "${RICE_CONFIGS[@]}"; do
    if [ -e "$MOZILLA_SOURCE/$config" ]; then
        if [ -d "$MOZILLA_SOURCE/$config" ]; then
            mkdir -p "$MOZILLA_TARGET/$config"
            rsync -a --delete "$MOZILLA_SOURCE/$config/" "$MOZILLA_TARGET/$config/" || {
                echo "  ✗ Failed to sync $config"
                continue
            }
        else
            cp "$MOZILLA_SOURCE/$config" "$MOZILLA_TARGET/$config" || {
                echo "  ✗ Failed to copy $config"
                continue
            }
        fi
        echo "  ✓ Copied $config"
        ((SYNCED_COUNT++))
    fi
done

echo "Part 3: Copying ~/.zshrc"
cp "$REPO_DIR/.zshrc" "$HOME/.zshrc"
cp -r "$REPO_DIR/Scripts" "$HOME"

echo "Part 4: Enabling execution for scripts"
find ~/.config/waybar -type f -name "*.sh" -exec chmod +x {} \;
find ~/.config/hypr -type f -name "*.sh" -exec chmod +x {} \;
find ~/Scripts -type f -name "*.sh" -exec chmod +x {} \;

echo "Part 5: Creating other files/directories"
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