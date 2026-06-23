#!/bin/bash

# Dock mode: disable laptop screen, enable two external monitors side by side
# DP-1-3 on the left at 0,0 ; DP-1-2 to the right at 2560,0
# swaymsg output replaces xrandr --output --mode --right-of in Wayland
# Note: sway uses absolute pixel positions instead of xrandr's --right-of

swaymsg output eDP-1 disable
swaymsg output DP-9 resolution 2560x1440 position 0 0 enable
swaymsg output DP-8 resolution 2560x1440 position 2560 0 enable

# Normalize workspaces back to their configured outputs
"/home/jos/.config/sway/screen_scripts/wsnormalize.sh"
