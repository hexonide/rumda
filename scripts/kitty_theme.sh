#!/bin/bash

set -e

THEME="$1"
RUMDA_DIR="$HOME/.config/rumda"
COMMON_FILE="$HOME/.config/kitty/kitty.conf"

case "$THEME" in
  light)
    SRC="$RUMDA_DIR/light-config/kitty/kitty.conf"
    ;;
  dark)
    SRC="$RUMDA_DIR/dark-config/kitty/kitty.conf"
    ;;
  *)
    echo "Usage: $0 [light|dark]"
    exit 1
    ;;
esac

if [[ ! -f "$SRC" ]]; then
  echo "Theme config not found at: $SRC"
  exit 1
fi

ln -fs "$SRC" "$COMMON_FILE" 2>/dev/null
pkill -USR1 kitty 2>/dev/null || true
