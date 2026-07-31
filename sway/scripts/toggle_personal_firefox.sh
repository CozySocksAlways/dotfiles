#!/usr/bin/env bash
# Toggle the personal Firefox scratchpad window.
# Not running -> launch it (floats into the scratchpad, for_window rule shows it).
# Running -> toggle its scratchpad visibility.

PROFILE_DIR="/home/jos/.config/mozilla/firefox/xx7RuNAU.Profile 1"

if swaymsg -t get_tree | jq -e '.. | objects | select(.app_id == "firefox-personal")' >/dev/null; then
    swaymsg '[app_id="firefox-personal"] scratchpad show'
else
    MOZ_APP_REMOTINGNAME=firefox-personal firefox --no-remote --profile "$PROFILE_DIR" &
fi
