#!/bin/bash

case "$1" in
  i)
    FONT='font_family=family="Greybeard 16px" style="Italic"'
    ;;
  t)
    FONT='font_family=family="Terminess Nerd Font" style="Bold"'
    ;;
  g)
    FONT='font_family=family="Greybeard 16px"'
    ;;
  *)
    echo "Usage: kfont [i|t|g]"
    exit 1
    ;;
esac

for sock in /tmp/kitty-*; do
  [ -S "$sock" ] && kitten @ --to "unix:$sock" load-config --override "$FONT"
done
