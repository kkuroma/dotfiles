#!/bin/bash
LAYOUT=$1
WS=$(hyprctl monitors -j | jq '.[] | select(.focused) | .activeWorkspace.id')
hyprctl keyword "workspace $WS, layout:$LAYOUT"