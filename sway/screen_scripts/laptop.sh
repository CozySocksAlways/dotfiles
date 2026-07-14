#!/bin/bash

# Laptop-only mode: enable built-in display, disable all external outputs
# swaymsg output replaces xrandr --output in Wayland

swaymsg output eDP-1 enable
# Note: xrandr's "HDMI-1" is often "HDMI-A-1" in Wayland/DRM naming.
# Run: swaymsg -t get_outputs | grep name   to verify your output names.

# Normalize workspaces back to their configured outputs
"${HOME}/.config/sway/screen_scripts/wsnormalize.sh"
