#!/bin/bash
kitty --class kitty-main &
sleep 0.1
kitty --class kitty-btop -e sh -c "while true; do btop; sleep 0.1; done" &
kitty --class kitty-yazi -e sh -c "while true; do yazi; sleep 0.1; done" &