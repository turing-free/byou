#!/bin/bash

echo "Starting but-you..."
echo "Press Ctrl+C to stop"
echo ""

swift build

if [ $? -eq 0 ]; then
    EXECUTABLE=$(swift build --show-bin-path)/but-you
    "$EXECUTABLE"
else
    echo "Build failed!"
    exit 1
fi
