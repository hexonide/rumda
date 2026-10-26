#!/usr/bin/env bash

dir="$HOME/.local/share/reminders"

for file in "$dir"/*.py "$dir"/*.sh; do
    [[ -f "$file" ]] || continue

    case "$file" in
        *.py) python3 "$file" >/dev/null 2>&1 & ;;
        *.sh) bash "$file" >/dev/null 2>&1 & ;;
    esac
done

disown
