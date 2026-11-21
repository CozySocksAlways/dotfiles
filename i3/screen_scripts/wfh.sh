#!/bin/bash

if ! xrandr | grep -q " connected"; then
    xrandr --output eDP-1 --auto --primary
    exit 0
fi

# M room: 2560x1440
# Near aquarium big one: 3840x2160
xrandr \
  --output eDP-1 --off \
  --output DP-2 --mode 1920x1080  --primary

i3-msg reload >/dev/null 2>&1
