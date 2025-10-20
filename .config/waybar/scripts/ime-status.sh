#!/bin/bash

# Get current input method from fcitx5
current_ime=$(fcitx5-remote -n 2>/dev/null)

# Map IME names to display format
case "$current_ime" in
    "keyboard-us")
        echo '{"text": "EN", "tooltip": "English (US)", "class": "en"}'
        ;;
    "keyboard-th")
        echo '{"text": "TH", "tooltip": "ไทย (Thai)", "class": "th"}'
        ;;
    "mozc")
        echo '{"text": "JP", "tooltip": "日本語 (Japanese)", "class": "jp"}'
        ;;
    "pinyin")
        echo '{"text": "ZH", "tooltip": "中文 (Mandarin)", "class": "zh"}'
        ;;
    *)
        echo '{"text": "??", "tooltip": "Unknown IME", "class": "unknown"}'
        ;;
esac
