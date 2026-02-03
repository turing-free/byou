#!/bin/bash

echo "Building byou..."

swift build

if [ $? -eq 0 ]; then
    echo "Build successful!"

    # Copy resources to .app bundle
    APP_PATH="byou.app"
    APP_CONTENTS="$APP_PATH/Contents"
    APP_RESOURCES="$APP_CONTENTS/Resources"

    # Create directories in app bundle
    mkdir -p "$APP_RESOURCES"
    mkdir -p "$APP_CONTENTS/MacOS"

    # Copy icon to app bundle
    cp "AppIcon.icns" "$APP_RESOURCES/"

    # Copy Info.plist to app bundle
    cp "Sources/byou/Info.plist" "$APP_CONTENTS/"

    # Copy executable to app bundle
    cp ".build/debug/byou" "$APP_CONTENTS/MacOS/"

    # Set executable permissions
    chmod +x "$APP_CONTENTS/MacOS/byou"

    # Code sign the app bundle with consistent identifier
    # This ensures permissions persist across restarts
    codesign --force --sign - --identifier com.turing.byou "$APP_PATH"

    echo "App bundle created: $APP_PATH"
    echo ""
    echo "To run the app: ./run.sh"
else
    echo "Build failed!"
    exit 1
fi
