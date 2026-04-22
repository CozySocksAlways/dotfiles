#!/bin/bash

if ! xrandr | grep -q " connected"; then
    xrandr --output eDP-1 --auto --primary
    exit 0
fi

xrandr \
  --output eDP-1 --off \
  --output DP-1-3 --mode 2560x1440 --primary --right-of eDP-1 \
  --output DP-1-2 --mode 2560x1440 --right-of DP-1-3

ln -sf ~/.config/i3/images/dockimage.jpg ~/.config/i3/images/current_image.jpg

i3-msg reload >/dev/null 2>&1
"${HOME}/.config/i3/screen_scripts/wsnormalize.sh"

polybar-msg cmd quit
MONITOR=DP-1-3  polybar -c ~/.config/i3/polyconf.ini 2>&1 | tee -a /tmp/polybar2.log & disown
sleep 0.2
MONITOR=DP-1-2  polybar -c ~/.config/i3/polyconf.ini 2>&1 | tee -a /tmp/polybar1.log & disown
