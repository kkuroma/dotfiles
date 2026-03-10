REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/src"
CONFIG_SOURCE="$HOME/.config"
CONFIG_TARGET="$REPO_DIR/.config"

mkdir "$REPO_DIR/.config"
mkdir "$REPO_DIR/.mozilla"
mkdir "$REPO_DIR/Scripts"

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

echo "Part 2: Copying ~/.zshrc"
cp "$HOME/.zshrc" "$REPO_DIR/.zshrc"
cp -r "$HOME/Scripts" "$REPO_DIR"