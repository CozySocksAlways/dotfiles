#!/bin/bash

BASE="$HOME/.config/sway/screen_scripts"
STATE_FILE="$BASE/.current_state"

# Initialize state if missing
if [ ! -f "$STATE_FILE" ]; then
    echo "laptop" > "$STATE_FILE"
fi

CURRENT=$(cat "$STATE_FILE")

case "$CURRENT" in
    laptop)
        "$BASE/dock.sh"
        echo "dock" > "$STATE_FILE"
        ;;

    dock)
        "$BASE/project.sh"
        echo "project" > "$STATE_FILE"
        ;;

    project)
        "$BASE/laptop.sh"
        echo "laptop" > "$STATE_FILE"
        ;;
esac
