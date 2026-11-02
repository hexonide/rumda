#!/bin/bash

dir="$HOME/Pictures/screenshots"
mkdir -p "$dir"
file="$dir/$(date +%Y%m%d-%H%M%S).png"

region=$(slurp) || exit 1
grim -g "$region" "$file"
wl-copy < "$file"
inkscape "$file"
