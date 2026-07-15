#!/usr/bin/env bash
# Toggle the tasks/diary kitty window.
# Closed -> open it. Open -> save+quit nvim over its socket, then close the window.

SOCK=/tmp/tasks-nvim.sock

if swaymsg -t get_tree | jq -e '.. | objects | select(.app_id == "kitty-tasks")' >/dev/null; then
    if [ -S "$SOCK" ]; then
        nvim --server "$SOCK" --remote-send '<Esc>:xa<CR>' 2>/dev/null
        sleep 0.3
    fi
    swaymsg '[app_id="kitty-tasks"] kill'
else
    kitty --class kitty-tasks -o confirm_os_window_close=0 -e bash -ic "tasks; exec bash" &
fi
