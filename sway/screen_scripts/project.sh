#!/bin/bash

# Projector mode: HDMI above laptop screen
# HDMI-A-1 sits at y=0; eDP-1 sits below it at y=1080 (HDMI's height)
# Replaces xrandr's --above with explicit absolute positions

swaymsg output HDMI-A-1 resolution 1920x1080 position 0 0 enable
swaymsg output eDP-1 position 0 1080 enable
swaymsg output DP-7 disable
swaymsg output DP-6 disable

"${HOME}/.config/sway/screen_scripts/wsnormalize.sh"
