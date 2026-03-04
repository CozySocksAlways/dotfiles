#!/bin/bash

PRIMARY_OUTPUT="DP-1-3"
SECONDARY_OUTPUT="DP-1-2"

# sleep is to avoid race conditions
for ws in 1 2 3 4 5; do
    i3-msg workspace $ws > /dev/null
    i3-msg move workspace to output $PRIMARY_OUTPUT > /dev/null
	sleep 0.03
done

for ws in 6 7 8 9 10; do
    i3-msg workspace $ws > /dev/null
    i3-msg move workspace to output $SECONDARY_OUTPUT > /dev/null
	sleep 0.03
done
