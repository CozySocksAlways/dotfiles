#!/bin/bash
# pytags - Generate Python ctags with recommended exclusions
# The tags file is created in the folder where this script resides

# Usage: ./pytags <folder_to_search> <tags_file_name>
# Example: ./pytags . tags

# Check arguments
if [ $# -ne 2 ]; then
    echo "Usage: $0 <folder_to_search> <tags_file_name>"
    exit 1
fi

SEARCH_DIR="$1"
TAGS_FILE_NAME="$2"

# Default to current directory if '.' is passed
if [ "$SEARCH_DIR" = "." ]; then
    SEARCH_DIR=$(pwd)
fi

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Full path to the tags file in the script directory
TAGS_FILE="$SCRIPT_DIR/$TAGS_FILE_NAME"

# Generate ctags
ctags -R \
    --languages=Python \
    --exclude=venv \
    --exclude=env \
    --exclude=.git \
    --exclude=__pycache__ \
    --exclude=*.pyc \
    -f "$TAGS_FILE" \
    "$SEARCH_DIR"

echo "Tags generated in '$TAGS_FILE' for folder '$SEARCH_DIR'"
