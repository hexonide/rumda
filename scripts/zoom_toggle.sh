#!/usr/bin/env bash

for pid in $(pgrep -x quickshell); do
  qs ipc --pid "$pid" call zoom toggle >/dev/null 2>&1 && exit 0
done
exit 1
