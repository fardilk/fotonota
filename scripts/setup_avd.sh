#!/usr/bin/env bash
set -euo pipefail

# setup_avd.sh
# Creates Android SDK cmdline-tools, installs platform-tools/emulator/system-image,
# creates an AVD called 'fotonota_avd' and launches it.
# Run this script locally; it will prompt to accept licenses.

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd -P)"
SDK_ROOT="${ANDROID_SDK_ROOT:-$HOME/Android/Sdk}"
CMDLINE_ZIP_URL="https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip"
CMDLINE_DIR="$SDK_ROOT/cmdline-tools/latest"
AVD_NAME="fotonota_avd"
SYS_IMG="system-images;android-33;google_apis;x86_64"

echo "Using SDK root: $SDK_ROOT"

mkdir -p "$SDK_ROOT"

if [ -x "$(command -v sdkmanager 2>/dev/null || true)" ]; then
  echo "sdkmanager already available"
else
  echo "Downloading Android command-line tools..."
  tmp="$(mktemp -d)"
  pushd "$tmp" >/dev/null
  wget -q "$CMDLINE_ZIP_URL" -O cmdline-tools.zip
  unzip -q cmdline-tools.zip
  mkdir -p "$CMDLINE_DIR"
  # If destination already has files, skip moving to avoid overwrite errors
  if [ -d "$CMDLINE_DIR/bin" ] && [ -d "cmdline-tools/bin" ]; then
    echo "cmdline-tools already installed at $CMDLINE_DIR; skipping move"
  else
    mv cmdline-tools/* "$CMDLINE_DIR/"
    echo "Installed cmdline-tools to $CMDLINE_DIR"
  fi
  popd >/dev/null
  rm -rf "$tmp"
fi

export ANDROID_SDK_ROOT="$SDK_ROOT"
export PATH="$CMDLINE_DIR/bin:$SDK_ROOT/platform-tools:$SDK_ROOT/emulator:$PATH"

echo "Installing platform-tools, emulator, platforms;android-33 and system image $SYS_IMG"
yes | sdkmanager --install "platform-tools" "emulator" "platforms;android-33" "$SYS_IMG"

echo "Accepting licenses..."
yes | sdkmanager --licenses >/dev/null || true

echo "Creating AVD named $AVD_NAME (force overwrite if exists)"
# choose a device (pixel recommended)
echo no | avdmanager create avd -n "$AVD_NAME" -k "$SYS_IMG" --device "pixel" --force || true

echo "Starting emulator $AVD_NAME"
emulator -avd "$AVD_NAME" -netdelay none -netspeed full &

echo "Done. Verify with: adb devices -l"
echo "To run the app:"
echo "  flutter run --dart-define=API_BASE_URL=http://103.172.204.34:8081"
