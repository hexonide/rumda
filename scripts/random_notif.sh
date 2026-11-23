#!/usr/bin/env bash

image_dir="$HOME/.config/rumda/pictures/notifications"

images=()
for image in "$image_dir"/*; do
    [[ -f "$image" ]] && images+=("$image")
done

if ((${#images[@]} == 0)); then
    echo "No notification images found in $image_dir" >&2
    exit 1
fi

image="${images[RANDOM % ${#images[@]}]}"

exec notify-send -i "$image" "$@"
