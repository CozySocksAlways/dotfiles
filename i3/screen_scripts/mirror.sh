#!/bin/bash

if ! xrandr | grep -q " connected"; then
    xrandr --output eDP-1 --auto --primary
    exit 0
fi

xrandr \
  --output eDP-1 --auto --primary \
  --output HDMI-1 --auto --same-as eDP-1 \
  --output DP-1-2 --off \
  --output DP-1-3 --off
