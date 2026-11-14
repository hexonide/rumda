#!/usr/bin/env bash

dir="$HOME/.local/share/reminders"

python3 "$dir/ptimes.py" >/dev/null 2>&1 &
python3 "$dir/reminders.py" >/dev/null 2>&1 &

disown -a
