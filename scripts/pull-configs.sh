#!/bin/bash
# Script to pull current system configurations into dotfiles repository

set -e

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

# 2. Create symlink in repo pointing to .config
echo -e "\n${YELLOW}[2/4] Setting up .config symlink in repository...${NC}"

CONFIG_SOURCE="$HOME/.config"
CONFIG_TARGET="$REPO_DIR/.config"

if [ ! -d "$CONFIG_SOURCE" ]; then
    echo -e "${RED}✗ .config directory not found at $CONFIG_SOURCE${NC}"
elif [ -L "$CONFIG_TARGET" ]; then
    LINK_TARGET=$(readlink -f "$CONFIG_TARGET")
    if [ "$LINK_TARGET" = "$CONFIG_SOURCE" ]; then
        echo -e "${GREEN}✓ Symlink already exists and points to ~/.config${NC}"
    else
        echo -e "${YELLOW}⚠ Symlink exists but points to: $LINK_TARGET${NC}"
        echo "  Expected: $CONFIG_SOURCE"
    fi
elif [ -e "$CONFIG_TARGET" ]; then
    echo -e "${YELLOW}⚠ Backing up existing .config in repo${NC}"
    mv "$CONFIG_TARGET" "$CONFIG_TARGET.backup.$(date +%Y%m%d_%H%M%S)"
    ln -s "$CONFIG_SOURCE" "$CONFIG_TARGET"
    echo -e "${GREEN}✓ Created symlink: repo/.config → ~/.config${NC}"
else
    ln -s "$CONFIG_SOURCE" "$CONFIG_TARGET"
    echo -e "${GREEN}✓ Created symlink: repo/.config → ~/.config${NC}"
fi

echo "  Note: Changes in ~/.config will automatically reflect in the repo"

# 3. Create symlink for .zshrc
echo -e "\n${YELLOW}[3/4] Setting up .zshrc symlink in repository...${NC}"

ZSHRC_SOURCE="$HOME/.zshrc"
ZSHRC_TARGET="$REPO_DIR/.zshrc"

if [ ! -f "$ZSHRC_SOURCE" ]; then
    echo -e "${RED}✗ .zshrc file not found at $ZSHRC_SOURCE${NC}"
elif [ -L "$ZSHRC_TARGET" ]; then
    LINK_TARGET=$(readlink -f "$ZSHRC_TARGET")
    if [ "$LINK_TARGET" = "$ZSHRC_SOURCE" ]; then
        echo -e "${GREEN}✓ Symlink already exists and points to ~/.zshrc${NC}"
    else
        echo -e "${YELLOW}⚠ Symlink exists but points to: $LINK_TARGET${NC}"
        echo "  Expected: $ZSHRC_SOURCE"
    fi
elif [ -e "$ZSHRC_TARGET" ]; then
    echo -e "${YELLOW}⚠ Backing up existing .zshrc in repo${NC}"
    mv "$ZSHRC_TARGET" "$ZSHRC_TARGET.backup.$(date +%Y%m%d_%H%M%S)"
    ln -s "$ZSHRC_SOURCE" "$ZSHRC_TARGET"
    echo -e "${GREEN}✓ Created symlink: repo/.zshrc → ~/.zshrc${NC}"
else
    ln -s "$ZSHRC_SOURCE" "$ZSHRC_TARGET"
    echo -e "${GREEN}✓ Created symlink: repo/.zshrc → ~/.zshrc${NC}"
fi

echo "  Note: Changes in ~/.zshrc will automatically reflect in the repo"

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
