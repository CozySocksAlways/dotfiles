#!/bin/bash

if ! xrandr | grep -q " connected"; then
    xrandr --output eDP-1 --auto --primary
    exit 0
fi

# M room: 2560x1440
# Near aquarium big one: 3840x2160
xrandr \
  --output eDP-1 --auto --primary \
  --output HDMI-1 --mode 3840x2160 --above eDP-1 \
  --output DP-1-3 --off \
  --output DP-1-2 --off

i3-msg reload >/dev/null 2>&1

polybar-msg cmd quit
sleep 0.1
MONITOR=eDP-1  polybar -c ~/.config/i3/polyconf.ini 2>&1 | tee -a /tmp/polybar1.log & disown
sleep 0.1
MONITOR=HDMI-1  polybar -c ~/.config/i3/polyconf.ini 2>&1 | tee -a /tmp/polybar1.log & disown
