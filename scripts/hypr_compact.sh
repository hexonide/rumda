#!/bin/bash
STATE_FILE="/tmp/hypr_gaps_lolz"
if [ -f "$STATE_FILE" ]; then
    hyprctl keyword general:gaps_out "45,40,45,40" 2>/dev/null
    hyprctl keyword general:gaps_in "9" 2>/dev/null
    hyprctl keyword decoration:shadow:enabled true 2>/dev/null
    hyprctl eval 'hl.config({ general = { gaps_out = { top = 45, right = 40, bottom = 45, left = 40 }, gaps_in = 9 }, decoration = { shadow = { enabled = true } } })' >/dev/null 2>&1
    rm "$STATE_FILE"
else
    hyprctl keyword general:gaps_out "5,5,5,13" 2>/dev/null
    hyprctl keyword general:gaps_in "1" 2>/dev/null
    hyprctl keyword decoration:shadow:enabled false 2>/dev/null
    hyprctl eval 'hl.config({ general = { gaps_out = { top = 5, right = 5, bottom = 5, left = 13 }, gaps_in = 1 }, decoration = { shadow = { enabled = false } } })' >/dev/null 2>&1
    touch "$STATE_FILE"
fi
