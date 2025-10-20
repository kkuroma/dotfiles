#!/bin/bash

direction=$1
current=$(hyprctl activeworkspace -j | grep -oP '"id":\s*\K\d+')

if [ "$direction" = "up" ]; then
    if [ "$current" -eq 1 ]; then
        next=10
    else
        next=$((current - 1))
    fi
else
    if [ "$current" -eq 10 ]; then
        next=1
    else
        next=$((current + 1))
    fi
fi

hyprctl dispatch workspace $next
