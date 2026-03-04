#!/bin/bash

if ! xrandr | grep -q " connected"; then
    xrandr --output eDP-1 --auto --primary
    exit 0
fi

xrandr \
  --output eDP-1 --auto --primary \
  --output DP-1-3 --off \
  --output DP-1-2 --off \
  --output HDMI-1 --off

i3-msg reload >/dev/null 2>&1
