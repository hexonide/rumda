#!/bin/bash
# usage: alacrittytheme [light|dark]

set -e

THEME="$1"
RUMDA_DIR="$HOME/.config/rumda"
COMMON_FILE="$HOME/.config/alacritty/alacritty.toml"

case "$THEME" in
  light)
    SRC="$RUMDA_DIR/light-config/alacritty/alacritty.toml"
    ;;
  dark)
    SRC="$RUMDA_DIR/dark-config/alacritty/alacritty.toml"
    ;;
  *)
    echo "Usage: $0 [light|dark]"
    exit 1
    ;;
esac

if [[ ! -f "$SRC" ]]; then
  echo "[X] Theme config not found at: $SRC"
  exit 1
fi

$HOME/.config/rumda/scripts/kitty_theme.sh $1 &

ln -fs "$SRC" "$COMMON_FILE"

