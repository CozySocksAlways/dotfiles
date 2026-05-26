#!/usr/bin/env bash

CONFIG_DIR="$HOME/.config/sway"
OUTPUT="$CONFIG_DIR/config"

cat > "$OUTPUT" <<EOF
# --------------------------------------------------
# AUTO-GENERATED FILE — DO NOT EDIT
# So autogen'ing this using build.sh
# --------------------------------------------------
EOF

# Merge the files (same order as i3 build.sh)
cat \
    "$CONFIG_DIR/base.conf" \
    "$CONFIG_DIR/workspace.conf" \
    "$CONFIG_DIR/keybind.conf" \
    "$CONFIG_DIR/input.conf" \
    "$CONFIG_DIR/appearance.conf" \
    >> "$OUTPUT"

swaymsg reload
