#!/bin/bash

# Script to generate app icons from SVG
# Requires rsvg-convert (install with: brew install librsvg)

SOURCE_SVG="Resources/logo-icon.svg"
DEST_DIR="Manounou/Assets.xcassets/AppIcon.appiconset"

# Check if rsvg-convert is available
if ! command -v rsvg-convert &> /dev/null; then
    echo "rsvg-convert not found. Installing librsvg..."
    brew install librsvg
fi

# Create destination directory if it doesn't exist
mkdir -p "$DEST_DIR"

# Generate icons for all required sizes
echo "Generating app icons..."

# iPhone sizes
rsvg-convert -w 40 -h 40 "$SOURCE_SVG" > "$DEST_DIR/AppIcon-20x20@2x.png"
rsvg-convert -w 60 -h 60 "$SOURCE_SVG" > "$DEST_DIR/AppIcon-20x20@3x.png"
rsvg-convert -w 58 -h 58 "$SOURCE_SVG" > "$DEST_DIR/AppIcon-29x29@2x.png"
rsvg-convert -w 87 -h 87 "$SOURCE_SVG" > "$DEST_DIR/AppIcon-29x29@3x.png"
rsvg-convert -w 80 -h 80 "$SOURCE_SVG" > "$DEST_DIR/AppIcon-40x40@2x.png"
rsvg-convert -w 120 -h 120 "$SOURCE_SVG" > "$DEST_DIR/AppIcon-40x40@3x.png"
rsvg-convert -w 120 -h 120 "$SOURCE_SVG" > "$DEST_DIR/AppIcon-60x60@2x.png"
rsvg-convert -w 180 -h 180 "$SOURCE_SVG" > "$DEST_DIR/AppIcon-60x60@3x.png"
rsvg-convert -w 1024 -h 1024 "$SOURCE_SVG" > "$DEST_DIR/AppIcon-1024x1024.png"

echo "App icons generated successfully!"
echo "Icons saved to: $DEST_DIR"

# Verify generated files
echo "Generated files:"
ls -la "$DEST_DIR"/*.png