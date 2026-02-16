#!/bin/bash

# Get current input method from fcitx5
current_ime=$(fcitx5-remote -n 2>/dev/null)

# Map IME names to display format
case "$current_ime" in
    "keyboard-us")
        echo '{"text": "EN", "tooltip": "<b><span color='"'"'#fab387'"'"'><big>󰇧 Input Method</big></span></b>\n<span color='"'"'#89dceb'"'"'>Current:</span> <span color='"'"'#cdd6f4'"'"'>English (US)</span>", "class": "en"}'
        ;;
    "keyboard-th")
        echo '{"text": "TH", "tooltip": "<b><span color='"'"'#fab387'"'"'><big>󰇧 Input Method</big></span></b>\n<span color='"'"'#89dceb'"'"'>Current:</span> <span color='"'"'#cdd6f4'"'"'>ไทย (Thai)</span>", "class": "th"}'
        ;;
    "mozc")
        echo '{"text": "JP", "tooltip": "<b><span color='"'"'#fab387'"'"'><big>󰇧 Input Method</big></span></b>\n<span color='"'"'#89dceb'"'"'>Current:</span> <span color='"'"'#cdd6f4'"'"'>日本語 (Japanese)</span>", "class": "jp"}'
        ;;
    "pinyin")
        echo '{"text": "ZH", "tooltip": "<b><span color='"'"'#fab387'"'"'><big>󰇧 Input Method</big></span></b>\n<span color='"'"'#89dceb'"'"'>Current:</span> <span color='"'"'#cdd6f4'"'"'>中文 (Mandarin)</span>", "class": "zh"}'
        ;;
    *)
        echo '{"text": "??", "tooltip": "<b><span color='"'"'#fab387'"'"'><big>󰇧 Input Method</big></span></b>\n<span color='"'"'#f38ba8'"'"'>Unknown IME</span>", "class": "unknown"}'
        ;;
esac
