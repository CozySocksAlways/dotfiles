#!/bin/bash

# Reassign workspaces to their intended outputs after a screen layout change.
# Mirrors the i3 version but uses swaymsg instead of i3-msg.

PRIMARY_OUTPUT="DP-7"
SECONDARY_OUTPUT="DP-6"

# sleep is to avoid race conditions with sway processing output changes
for ws in 1 2 3 4 5; do
    swaymsg workspace $ws > /dev/null
    swaymsg move workspace to output $PRIMARY_OUTPUT > /dev/null
    sleep 0.03
done

for ws in 6 7 8 9 10; do
    swaymsg workspace $ws > /dev/null
    swaymsg move workspace to output $SECONDARY_OUTPUT > /dev/null
    sleep 0.03
done
