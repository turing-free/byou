#!/bin/bash

BUILD_CONFIG="${1:-debug}"

if [[ "$BUILD_CONFIG" != "debug" && "$BUILD_CONFIG" != "release" ]]; then
    echo "Error: Invalid build configuration '$BUILD_CONFIG'"
    echo "Usage: $0 [debug|release]"
    exit 1
fi

echo "Creating DMG for byou ($BUILD_CONFIG)..."

./build.sh "$BUILD_CONFIG"

if [ $? -ne 0 ]; then
    echo "Build failed, aborting DMG creation"
    exit 1
fi

DMG_OUTPUT="byou-${BUILD_CONFIG}.dmg"

if [ -f "$DMG_OUTPUT" ]; then
    echo "Removing existing DMG..."
    rm "$DMG_OUTPUT"
fi

# Create temporary directory for DMG contents
DMG_DIR="dmg_temp"
rm -rf "$DMG_DIR"
mkdir -p "$DMG_DIR"

# Copy app to temp directory
cp -R "byou.app" "$DMG_DIR/"

# Create symlink to Applications folder (common practice for DMG)
ln -s /Applications "$DMG_DIR/Applications"

echo "Creating DMG image..."
hdiutil create -srcfolder "$DMG_DIR" -volname "byou" -format UDZO -o "$DMG_OUTPUT"

# Clean up temp directory
rm -rf "$DMG_DIR"

echo "DMG created successfully: $DMG_OUTPUT"
