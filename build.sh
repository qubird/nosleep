#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
rm -rf NoSleep.app
mkdir -p NoSleep.app/Contents/MacOS
swiftc -O main.swift icons.swift -o NoSleep.app/Contents/MacOS/NoSleep -framework Cocoa -framework IOKit
mkdir -p NoSleep.app/Contents/Resources
cp AppIcon.icns NoSleep.app/Contents/Resources/AppIcon.icns
cp Info.plist NoSleep.app/Contents/Info.plist
codesign --force --sign - NoSleep.app
echo "Built $(pwd)/NoSleep.app"
