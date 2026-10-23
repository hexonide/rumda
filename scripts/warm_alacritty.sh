#!/bin/bash

COMMON_FILE="$HOME/.config/alacritty/alacritty.toml"
SRC="$HOME/.config/rumda/flavours/warm-rumda/alacritty.toml"

$HOME/.config/rumda/scripts/warm_kitty.sh $1 &

ln -fs "$SRC" "$COMMON_FILE"

