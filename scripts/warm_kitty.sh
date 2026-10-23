#!/bin/bash

COMMON_FILE="$HOME/.config/kitty/kitty.conf"
SRC="$HOME/.config/rumda/flavours/warm-rumda/kitty.conf"

ln -fs "$SRC" "$COMMON_FILE" 2>/dev/null
pkill -USR1 kitty 2>/dev/null || true
