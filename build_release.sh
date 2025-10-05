#!/bin/bash

# GraphTodo Release Builder
echo "🚀 Building GraphTodo release packages..."

# Get version from git tag
VERSION=$(git describe --tags --abbrev=0)
echo "📦 Building version: $VERSION"

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean
flutter pub get

# Build Android APK
echo "🤖 Building Android APK..."
flutter build apk --release
if [ $? -eq 0 ]; then
    echo "✅ Android APK built successfully"
    cp build/app/outputs/flutter-apk/app-release.apk "GraphTodo-$VERSION.apk"
    echo "📱 APK location: $(pwd)/GraphTodo-$VERSION.apk"
else
    echo "❌ Android APK build failed"
    exit 1
fi

# Build macOS app
echo "🍎 Building macOS app..."
flutter build macos --release
if [ $? -eq 0 ]; then
    echo "✅ macOS app built successfully"
else
    echo "❌ macOS build failed"
    exit 1
fi

# Create DMG
echo "📀 Creating DMG..."
create-dmg \
  --volname "GraphTodo" \
  --window-pos 200 120 \
  --window-size 600 300 \
  --icon-size 100 \
  --icon "GraphTodo.app" 175 120 \
  --hide-extension "GraphTodo.app" \
  --app-drop-link 425 120 \
  "GraphTodo-$VERSION.dmg" \
  "build/macos/Build/Products/Release/"

if [ $? -eq 0 ]; then
    echo "✅ DMG created successfully"
    echo "💿 DMG location: $(pwd)/GraphTodo-$VERSION.dmg"
else
    echo "❌ DMG creation failed"
    exit 1
fi

echo ""
echo "🎉 Release build complete!"
echo "📁 Files ready for release:"
echo "   • GraphTodo-$VERSION.apk ($(du -h GraphTodo-$VERSION.apk | cut -f1))"
echo "   • GraphTodo-$VERSION.dmg ($(du -h GraphTodo-$VERSION.dmg | cut -f1))"
echo ""
echo "🚀 Ready to upload to GitHub releases!"