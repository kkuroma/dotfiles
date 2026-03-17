#!/bin/bash
notify-send test
DESKTOP=$(xdg-mime query default x-scheme-handler/https)
CLASS=$(basename "$DESKTOP" .desktop)
xdg-open "$1"
hyprctl dispatch focuswindow "class:^($CLASS)$"