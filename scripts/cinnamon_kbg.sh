#!/bin/bash

for sock in /tmp/kitty-*; do
  [ -S "$sock" ] && kitten @ --to "unix:$sock" set-colors --all background="#f5c7a2"
done
