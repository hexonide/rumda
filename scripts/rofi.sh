#!/bin/bash

if [[ "$USER" == "hexogen" || "$USER" == "nazhim" ]]; then
    "/home/$USER/.config/rumda/scripts/calligraphy.sh"
else
    rofi -show drun -config "$HOME/.config/rumda/light-config/rofi/config.rasi"
fi
