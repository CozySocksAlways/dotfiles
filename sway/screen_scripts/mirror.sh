#!/bin/bash

# Mirror mode: laptop screen + HDMI at the same position
# Note: sway has no true mirror mode like xrandr's --same-as.
# Setting both to position 0,0 achieves the same visual effect in most cases.
# For true cloning, look into wl-mirror.

swaymsg output eDP-1 position 0 0 enable
swaymsg output HDMI-A-1 resolution 1920x1080 position 0 0 enable
swaymsg output DP-7 disable
swaymsg output DP-6 disable

"${HOME}/.config/sway/screen_scripts/wsnormalize.sh"
