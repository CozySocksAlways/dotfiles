#!/usr/bin/env bash

CONFIG_DIR="$HOME/.config/i3"
OUTPUT="$CONFIG_DIR/config"

cat > "$OUTPUT" <<EOF
# --------------------------------------------------
# AUTO-GENERATED FILE — DO NOT EDIT
# So autogen'ing this using build.sh
# --------------------------------------------------
EOF

# Merge the files
cat \
	"$CONFIG_DIR/base.conf" \
	"$CONFIG_DIR/keybind.conf" \
	>> "$OUTPUT"

i3-msg reload
