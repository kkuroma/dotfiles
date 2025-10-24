#!/bin/bash
# Script to pull current system configurations into dotfiles repository

# Don't exit on error - we want to continue even if some configs fail
set +e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo -e "${GREEN}=== Pulling configurations to dotfiles repository ===${NC}"
echo "Repository directory: $REPO_DIR"

# 1. Export package lists
echo -e "\n${YELLOW}[1/4] Exporting package lists...${NC}"

# Export pacman packages (official repos)
echo "Exporting pacman packages..."
pacman -Qqe | grep -v "$(pacman -Qqm)" > "$REPO_DIR/pacman.txt" || true
echo -e "${GREEN}✓ Saved $(wc -l < "$REPO_DIR/pacman.txt") pacman packages to pacman.txt${NC}"

# Export AUR packages
echo "Exporting AUR packages..."
pacman -Qqm > "$REPO_DIR/pacman-aur.txt" || touch "$REPO_DIR/pacman-aur.txt"
echo -e "${GREEN}✓ Saved $(wc -l < "$REPO_DIR/pacman-aur.txt") AUR packages to pacman-aur.txt${NC}"

# 2. Copy rice-related .config directories to repo
echo -e "\n${YELLOW}[2/4] Copying rice-related .config directories to repository...${NC}"

CONFIG_SOURCE="$HOME/.config"
CONFIG_TARGET="$REPO_DIR/.config"

# List of rice-related config directories/files to include
RICE_CONFIGS=(
    # Hyprland rice
    "hypr"
    "waybar"
    "dunst"
    "rofi"
    "wlogout"
    "nwg-dock-hyprland"

    # Theming
    "gtk-3.0"
    "gtk-4.0"
    "kdeglobals"
    "qt5ct"
    "qt6ct"
    "QtProject.conf"
    "matugen"
    "fontconfig"

    # Riced applications
    "Code - OSS"
    "GIMP"
    "fcitx5"
    "mozc"

    # File manager (Dolphin)
    "dolphinrc"
    "filetypesrc"
    "trashrc"
    "mimeapps.list"

    # Terminal & utilities
    "kitty"
    "fastfetch"
    "neofetch"
    "btop"
    "clipse"
    "imv"
    "mpv"
    "zsh"
)

if [ ! -d "$CONFIG_SOURCE" ]; then
    echo -e "${RED}✗ .config directory not found at $CONFIG_SOURCE${NC}"
else
    # If target is a symlink, remove it first
    if [ -L "$CONFIG_TARGET" ]; then
        echo -e "${YELLOW}⚠ Removing existing symlink${NC}"
        rm "$CONFIG_TARGET"
    fi

    # Create .config directory if it doesn't exist
    mkdir -p "$CONFIG_TARGET"

    # Sync each rice-related config
    echo "Syncing rice-related configs..."
    SYNCED_COUNT=0
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
            echo "  ✓ $config"
            ((SYNCED_COUNT++))
        fi
    done

    echo -e "${GREEN}✓ Synced $SYNCED_COUNT rice-related configs${NC}"
fi

echo "  Note: Run this script again to sync future changes from ~/.config"

# 3. Copy .zshrc to repo
echo -e "\n${YELLOW}[3/4] Copying .zshrc to repository...${NC}"

ZSHRC_SOURCE="$HOME/.zshrc"
ZSHRC_TARGET="$REPO_DIR/.zshrc"

if [ ! -f "$ZSHRC_SOURCE" ]; then
    echo -e "${RED}✗ .zshrc file not found at $ZSHRC_SOURCE${NC}"
else
    # If target is a symlink, remove it first
    if [ -L "$ZSHRC_TARGET" ]; then
        echo -e "${YELLOW}⚠ Removing existing symlink${NC}"
        rm "$ZSHRC_TARGET"
    # If target exists, back it up
    elif [ -e "$ZSHRC_TARGET" ]; then
        echo -e "${YELLOW}⚠ Backing up existing .zshrc in repo${NC}"
        mv "$ZSHRC_TARGET" "$ZSHRC_TARGET.backup.$(date +%Y%m%d_%H%M%S)"
    fi

    cp "$ZSHRC_SOURCE" "$ZSHRC_TARGET"
    echo -e "${GREEN}✓ Copied .zshrc to repo${NC}"
fi

echo "  Note: Run this script again to sync future changes from ~/.zshrc"

# 4. Document system configuration
echo -e "\n${YELLOW}[4/4] Documenting system configuration...${NC}"

SYSTEM_INFO="$REPO_DIR/SYSTEM_SETUP.md"

cat > "$SYSTEM_INFO" << 'EOF'
# System Setup Guide

Generated: $(date)

## Enabled Services

### User Services
```bash
EOF

# List enabled user services
systemctl --user list-unit-files --state=enabled --no-pager 2>/dev/null | grep -v "^$" >> "$SYSTEM_INFO" || echo "None" >> "$SYSTEM_INFO"

cat >> "$SYSTEM_INFO" << 'EOF'
```

### System Services
```bash
EOF

# List enabled system services
systemctl list-unit-files --state=enabled --no-pager 2>/dev/null | grep -v "^UNIT" | grep -v "^$" | head -50 >> "$SYSTEM_INFO" || echo "None" >> "$SYSTEM_INFO"

cat >> "$SYSTEM_INFO" << 'EOF'
```

## Network Configuration

EOF

# Document network setup
if systemctl is-enabled NetworkManager >/dev/null 2>&1; then
    echo "- Using **NetworkManager**" >> "$SYSTEM_INFO"
elif systemctl is-enabled systemd-networkd >/dev/null 2>&1; then
    echo "- Using **systemd-networkd**" >> "$SYSTEM_INFO"
    echo "  - Check /etc/systemd/network/ for config files" >> "$SYSTEM_INFO"
fi

cat >> "$SYSTEM_INFO" << 'EOF'

## Custom systemd Units

EOF

# List custom systemd units
echo "### System units:" >> "$SYSTEM_INFO"
shopt -s nullglob
custom_units=(/etc/systemd/system/*.service /etc/systemd/system/*.timer /etc/systemd/system/*.target)
shopt -u nullglob

if [ ${#custom_units[@]} -eq 0 ]; then
    echo "None" >> "$SYSTEM_INFO"
else
    for unit in "${custom_units[@]}"; do
        echo "- \`$(basename "$unit")\`" >> "$SYSTEM_INFO"
    done
fi

cat >> "$SYSTEM_INFO" << 'EOF'

## Important Config Files to Review

- **Display**: /etc/X11/xorg.conf.d/
- **Boot**: /etc/mkinitcpio.conf
- **Pacman**: /etc/pacman.conf
- **Locale**: /etc/locale.conf, /etc/locale.gen
- **Kernel modules**: /etc/modprobe.d/

## Setup Instructions for New Machine

1. Install packages from pacman.txt and pacman-aur.txt
2. Enable services listed above using `systemctl enable <service>`
3. Review and adapt network configuration
4. Copy relevant config files from /etc based on your hardware
5. Symlink .config directory
EOF

echo -e "${GREEN}✓ Created system setup documentation${NC}"
echo "  See SYSTEM_SETUP.md for service/config info"

echo -e "\n${GREEN}=== Done! ===${NC}"
echo "Next steps:"
echo "1. Review changes: cd $REPO_DIR && git status"
echo "2. Commit changes: git add -A && git commit -m 'Update dotfiles'"
echo "3. Push to GitHub: git push"
