#!/bin/bash

BASE="$HOME/.config/i3/screen_scripts"
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
esac

# Reload i3 workspace-output mapping
i3-msg reload >/dev/null 2>&1
