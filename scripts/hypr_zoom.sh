#!/usr/bin/env bash
factor="$1"
hyprctl keyword cursor:zoom_factor "$factor" >/dev/null 2>&1
hyprctl eval "hl.config({ cursor = { zoom_factor = $factor } })" >/dev/null 2>&1
