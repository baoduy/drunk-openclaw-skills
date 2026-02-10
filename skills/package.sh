#!/bin/bash
# Package any skill folder for publishing

# Check if folder name is provided
if [ -z "$1" ]; then
    echo "Usage: sh package.sh <folder-name>"
    echo "Example: sh package.sh trading-analyzer"
    exit 1
fi

FOLDER_NAME="$1"
SCRIPT_DIR="$(dirname "$0")"

# Check if folder exists
if [ ! -d "$SCRIPT_DIR/$FOLDER_NAME" ]; then
    echo "✗ Folder not found: $FOLDER_NAME"
    exit 1
fi

# Check if .clawhub.ignore exists
if [ ! -f "$SCRIPT_DIR/.clawhub.ignore" ]; then
    echo "✗ .clawhub.ignore file not found in parent directory"
    exit 1
fi

# Navigate to the target folder
cd "$SCRIPT_DIR/$FOLDER_NAME"

# Define output filename with timestamp
OUTPUT_FILE="../${FOLDER_NAME}-$(date +%Y%m%d-%H%M%S).zip"

# Create zip file excluding patterns from .clawhub.ignore
echo "Packaging $FOLDER_NAME (excluding patterns from .clawhub.ignore)..."
zip -r "$OUTPUT_FILE" . -x@../.clawhub.ignore

# Check if zip was successful
if [ $? -eq 0 ]; then
    echo "✓ Package created successfully: $(basename "$OUTPUT_FILE")"
    echo "Location: $SCRIPT_DIR/$(basename "$OUTPUT_FILE")"
    echo "$(wc -c < "$OUTPUT_FILE" | numfmt --to=iec-i --suffix=B) compressed"
    echo ""
    echo "Contents:"
    unzip -l "$OUTPUT_FILE"
else
    echo "✗ Failed to create package"
    exit 1
fi

exit 0
