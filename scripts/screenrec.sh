#!/usr/bin/env bash

dir="$HOME/Video/recordings"
mkdir -p "$dir"

if pgrep -x wf-recorder >/dev/null; then
    pkill -SIGINT -x wf-recorder
    exit 0
fi

file="$dir/screenrec-$(date +%Y%m%d-%H%M%S).mp4"
audio="$(pactl get-default-sink).monitor"

if [ "$1" = "region" ]; then
    geometry="$(slurp)" || exit 1
    wf-recorder --audio="$audio" -g "$geometry" -f "$file"
else
    wf-recorder --audio="$audio" -f "$file"
fi
