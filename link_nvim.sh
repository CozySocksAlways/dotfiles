#!/bin/bash

# Set variables
SOURCE_DIR="$(pwd)/nvim"
TARGET_DIR="$HOME/.config/nvim"

# Ensure ~/.config exists
mkdir -p "$HOME/.config"

# Remove existing nvim folder or symlink if it exists
if [ -e "$TARGET_DIR" ] || [ -L "$TARGET_DIR" ]; then
    echo "Removing existing $TARGET_DIR..."
    rm -rf "$TARGET_DIR"
fi

# Create the symlink
ln -s "$SOURCE_DIR" "$TARGET_DIR"
echo "Symlink created: $TARGET_DIR -> $SOURCE_DIR"
