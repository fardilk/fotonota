# Fotonota (Demo) UI-Only Build

This document describes how to build and run the UI-only demo build of Fotonota using `--dart-define` flags and a dedicated `main_mock.dart` entrypoint.

## Purpose
- Visual/UI validation only
- No real backend or Firebase connections
- Mocked services and data to exercise screens and states

## Build flags
- USE_MOCK: Enable mock data paths (default false)
- INIT_FIREBASE: Initialize Firebase (default true). For demo, set to false
- SHOW_DEBUG_MENU: Show small 'DEMO BUILD' watermark (default false)
- APP_NAME: Override app title (default 'Fotonota')

## Entrypoints
- Production: lib/main.dart (default)
- Demo: lib/main_mock.dart (uses Provider overrides)

## How to run (local)

```bash
# Run demo with mock entrypoint
flutter run -t lib/main_mock.dart --dart-define=INIT_FIREBASE=false --dart-define=SHOW_DEBUG_MENU=true --dart-define=APP_NAME="Fotonota (Demo)"

# Alternatively run prod entrypoint with flags (not required for demo)
flutter run --dart-define=USE_MOCK=true --dart-define=INIT_FIREBASE=false --dart-define=SHOW_DEBUG_MENU=true --dart-define=APP_NAME="Fotonota (Demo)"
```

## How to build APK/IPA

```bash
# Android debug APK (demo)
flutter build apk --debug -t lib/main_mock.dart \
  --dart-define=INIT_FIREBASE=false \
  --dart-define=SHOW_DEBUG_MENU=true \
  --dart-define=APP_NAME="Fotonota (Demo)"

# Android release APK (demo)
flutter build apk --release -t lib/main_mock.dart \
  --dart-define=INIT_FIREBASE=false \
  --dart-define=SHOW_DEBUG_MENU=true \
  --dart-define=APP_NAME="Fotonota (Demo)"
```

## Mock coverage
- Auth: Login/Register happy-paths
- Dashboard: Profile prompt, totals, recent catatan, revenue chart (fake data)
- Camera: Preview & overlay UI
- Onboarding/Splash: Normal flow via SharedPreferences

## Known limitations
- No real authentication or uploads
- Network calls are not executed
- Analytics & Crashlytics are disabled when INIT_FIREBASE=false

## Definition of Done
- APK titled "Fotonota (Demo)"
- Visual QA checklist completed (light/dark, text scale, small/big screens)
- Stakeholder review feedback collected
