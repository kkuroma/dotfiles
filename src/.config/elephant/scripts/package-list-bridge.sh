#!/bin/bash
# Generates package list JSON and opens package-list menu
# Usage: package-list-bridge.sh <mode>
# Modes: all, explicit, aur

MODE="$1"
STATE_DIR="$HOME/.cache/walker-packages"
mkdir -p "$STATE_DIR"

case "$MODE" in
    all)
        # Get explicit and foreign sets
        declare -A explicit foreign
        while read -r name _; do explicit["$name"]=1; done < <(pacman -Qen 2>/dev/null)
        while read -r name _; do foreign["$name"]=1; done < <(pacman -Qm 2>/dev/null)

        # Build list with tags
        pacman -Q 2>/dev/null | while read -r name version; do
            if [[ -n "${foreign[$name]}" ]]; then
                echo "aur $name $version"
            elif [[ -n "${explicit[$name]}" ]]; then
                echo "explicit $name $version"
            else
                echo "dep $name $version"
            fi
        done > "$STATE_DIR/packages.txt"
        ;;
    explicit)
        pacman -Qen 2>/dev/null | awk '{print "explicit " $1 " " $2}' > "$STATE_DIR/packages.txt"
        ;;
    aur)
        pacman -Qm 2>/dev/null | awk '{print "aur " $1 " " $2}' > "$STATE_DIR/packages.txt"
        ;;
esac

walker -m menus:package-list
