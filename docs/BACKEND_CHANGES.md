# Backend Integration - Quick Reference

## What Changed

### 1. Base URL Updated
**File**: `lib/core/config/constants.dart`

**Before**:
```dart
defaultValue: 'https://snapcash-api.fardil.com'
```

**After**:
```dart
defaultValue: 'http://103.172.204.34:8081'
```

## Test Credentials

```
User 1:
  Username: fardil
  Password: admin123

User 2:
  Username: arif
  Password: admin123
```

## API Endpoints

All endpoints work correctly:
- ✅ `POST /login` - Returns JWT tokens
- ✅ `GET /me` - Returns user info
- ✅ `POST /refresh` - Refreshes access token
- ✅ `POST /revoke` - Revokes refresh token

## Quick Test Commands

### Test Backend with curl

```bash
# Test login (fardil)
curl -X POST http://103.172.204.34:8081/login \
  -H "Content-Type: application/json" \
  -d '{"username":"fardil","password":"admin123"}'

# Test login (arif)
curl -X POST http://103.172.204.34:8081/login \
  -H "Content-Type: application/json" \
  -d '{"username":"arif","password":"admin123"}'

# Test /me endpoint (replace TOKEN with actual token from login response)
curl http://103.172.204.34:8081/me \
  -H "Authorization: Bearer TOKEN"
```

### Build and Install APK

```bash
# Build debug APK
flutter build apk --debug

# Install on device
adb install -r build/app/outputs/flutter-apk/app-debug.apk

# Monitor logs
adb logcat | grep -E "ApiClient|AuthService"
```

## Architecture Overview

```
lib/
├── core/
│   ├── config/
│   │   └── constants.dart              ← Base URL here
│   ├── services/
│   │   └── api_client.dart             ← Dio + Bearer auth
│   └── utils/
│       └── prefs_helper.dart           ← Token storage
└── features/
    └── auth/
        └── data/
            ├── auth_service.dart        ← API calls
            └── auth_repository.dart     ← Business logic
```

## Token Flow

```
1. User enters credentials
   ↓
2. POST /login → receives tokens
   ↓
3. Store in SharedPreferences
   ↓
4. All requests include: Authorization: Bearer <token>
   ↓
5. On 401 → auto refresh → retry
   ↓
6. Logout → revoke → clear storage
```

## Verified Working

✅ Backend API is accessible from development machine  
✅ Login endpoint returns valid JWT tokens  
✅ /me endpoint returns correct user data  
✅ Both test users (fardil, arif) work correctly  
✅ Flutter code uses correct endpoints  
✅ Token management is properly implemented  
✅ Debug APK builds successfully  

## Next: Manual Testing

Install the APK and verify:
1. Login with fardil works
2. Dashboard shows "Hi, fardil"
3. Login with arif works
4. Dashboard shows "Hi, arif"
5. Logout clears session
6. Token persists across app restarts

See `docs/backend_testing_checklist.md` for detailed test scenarios.
