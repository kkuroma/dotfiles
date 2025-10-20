#!/bin/bash

# Cycle through input methods: EN → TH → JP → ZH → EN
current_ime=$(fcitx5-remote -n 2>/dev/null)

case "$current_ime" in
    "keyboard-us")
        fcitx5-remote -s keyboard-th
        ;;
    "keyboard-th")
        fcitx5-remote -s mozc
        ;;
    "mozc")
        fcitx5-remote -s pinyin
        ;;
    "pinyin")
        fcitx5-remote -s keyboard-us
        ;;
    *)
        # Default to English if unknown
        fcitx5-remote -s keyboard-us
        ;;
esac
