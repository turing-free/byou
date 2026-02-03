#!/bin/bash

echo "Creating DMG for byou..."

# Build the app first
./build.sh

if [ $? -ne 0 ]; then
    echo "Build failed, aborting DMG creation"
    exit 1
fi

# Clean up any existing DMG
if [ -f "byou.dmg" ]; then
    echo "Removing existing DMG..."
    rm byou.dmg
fi

# Create temporary directory for DMG contents
DMG_DIR="dmg_temp"
rm -rf "$DMG_DIR"
mkdir -p "$DMG_DIR"

# Copy app to temp directory
cp -R "byou.app" "$DMG_DIR/"

# Create symlink to Applications folder (common practice for DMG)
ln -s /Applications "$DMG_DIR/Applications"

# Create DMG
echo "Creating DMG image..."
hdiutil create -srcfolder "$DMG_DIR" -volname "byou" -format UDZO -o "byou.dmg"

# Clean up temp directory
rm -rf "$DMG_DIR"

echo "DMG created successfully: byou.dmg"
