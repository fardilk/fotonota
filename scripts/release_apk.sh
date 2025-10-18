#!/usr/bin/env bash
set -euo pipefail

# Build and release APK script
# Usage: ./scripts/release_apk.sh

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd -P)"
BUILD_OUTPUT="$PROJECT_ROOT/build/app/outputs/flutter-apk/app-release.apk"
DEST_DIR="/home/tw-fardil/Documents/Fardil/Project/fotonota"
DEST_APK="$DEST_DIR/fotonota-app-release.apk"

echo "Project root: $PROJECT_ROOT"

# Ensure destination exists
mkdir -p "$DEST_DIR"

# Run flutter pub get and build
echo "Running flutter pub get..."
flutter pub get

echo "Building release APK..."
# Allow override of API base via env; default to prod
# Support both API_BASE_URL and DAPI_BASE_URL (the latter requested by user)
: "${API_BASE_URL:=${DAPI_BASE_URL:-https://fotonota-api.fardil.com}}"
echo "Using API_BASE_URL=$API_BASE_URL"
# Pass the value into the Dart compiler so runtime picks it up from String.fromEnvironment
flutter build apk --release --dart-define=API_BASE_URL="$API_BASE_URL"

if [ ! -f "$BUILD_OUTPUT" ]; then
  echo "Build output not found: $BUILD_OUTPUT"
  exit 1
fi

# Copy and rename
echo "Copying APK to $DEST_APK"
cp -f "$BUILD_OUTPUT" "$DEST_APK"

echo "Setting permissions"
chmod 644 "$DEST_APK"

echo "Done. APK available at: $DEST_APK"
