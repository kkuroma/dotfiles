#!/usr/bin/env python3
import json

SETTINGS_FILE = "/home/kuroma/.config/Code - OSS/User/settings.json"
COLORS_FILE = "/home/kuroma/.config/Code - OSS/User/vscode-colors.json"

try:
    # Read color customizations
    with open(COLORS_FILE, 'r') as f:
        colors = json.load(f)

    # Read current settings
    with open(SETTINGS_FILE, 'r') as f:
        settings = json.load(f)

    # Merge both workbench colors AND token colors
    settings['workbench.colorCustomizations'] = colors['workbench.colorCustomizations']
    settings['editor.tokenColorCustomizations'] = colors['editor.tokenColorCustomizations']

    # Use native (KDE/Dolphin) file picker instead of GTK
    settings['window.dialogStyle'] = 'native'
    settings['window.titleBarStyle'] = 'custom'

    # Write back
    with open(SETTINGS_FILE, 'w') as f:
        json.dump(settings, f, indent=4)

except Exception as e:
    print(f"Error: {e}")
    exit(1)
