# Backend Integration Testing Checklist

## ✅ Completed Tasks

### 1. Base URL Configuration
- [x] Updated base URL to `http://103.172.204.34:8081`
- [x] Centralized in `lib/core/config/constants.dart`
- [x] Supports override via `--dart-define=API_BASE_URL=...`

### 2. Auth Endpoints Verification
All endpoints match backend specification:
- [x] `POST /login` - correct path and request/response format
- [x] `GET /me` - correct path and Bearer auth header
- [x] `POST /refresh` - correct path and refresh token handling
- [x] `POST /revoke` - correct path for logout

### 3. Token Management
- [x] Access and refresh tokens stored in SharedPreferences
- [x] Automatic Bearer token injection via Dio interceptor
- [x] Automatic token refresh on 401 responses
- [x] Token expiry tracking with 5-second buffer
- [x] Secure logout with token revocation

### 4. Backend API Testing (via curl)
- [x] Login as `fardil` - SUCCESS ✓
- [x] Login as `arif` - SUCCESS ✓
- [x] GET /me with Bearer token - SUCCESS ✓
- [x] Backend returns valid JWT tokens

### 5. Build Verification
- [x] Code analysis passes (no errors)
- [x] Debug APK builds successfully
- [x] APK location: `build/app/outputs/flutter-apk/app-debug.apk`

## 📱 Manual Testing Required

To complete the acceptance criteria, install the APK on a physical device or emulator:

### Installation Steps
```bash
# Install on connected device
adb install -r build/app/outputs/flutter-apk/app-debug.apk

# Or copy to device and install manually
cp build/app/outputs/flutter-apk/app-debug.apk ~/fotonota-backend-test.apk
```

### Test Scenarios

#### Scenario 1: Login with fardil
1. Launch the app
2. Navigate to login screen
3. Enter:
   - Username: `fardil`
   - Password: `admin123`
4. Tap "Login"
5. **Expected Results**:
   - Login request hits `http://103.172.204.34:8081/login`
   - App receives access_token and refresh_token
   - Redirects to dashboard
   - App bar shows "Hi, fardil"
   - No error messages

#### Scenario 2: Verify /me Endpoint
1. After successful login (Scenario 1)
2. Dashboard loads
3. **Expected Results**:
   - GET request to `http://103.172.204.34:8081/me`
   - Request includes `Authorization: Bearer <token>` header
   - Dashboard displays correct username
   - Profile section shows user info

#### Scenario 3: Login with arif
1. If already logged in, logout first
2. Navigate to login screen
3. Enter:
   - Username: `arif`
   - Password: `admin123`
4. Tap "Login"
5. **Expected Results**:
   - Same behavior as Scenario 1
   - App bar shows "Hi, arif"

#### Scenario 4: Token Persistence
1. Log in with any user
2. Close the app (force stop)
3. Reopen the app
4. **Expected Results**:
   - App opens directly to dashboard (no login required)
   - Username still displayed
   - Can make authenticated requests

#### Scenario 5: Logout Flow
1. While logged in, tap logout button
2. **Expected Results**:
   - POST request to `http://103.172.204.34:8081/revoke`
   - Tokens cleared from storage
   - Redirects to login screen
   - Cannot access dashboard without login

#### Scenario 6: Token Refresh (Advanced)
1. Log in
2. Wait 15+ minutes (token expiry)
3. Make any authenticated request (e.g., refresh dashboard)
4. **Expected Results**:
   - Initial request returns 401
   - App automatically calls `/refresh`
   - Receives new access_token
   - Original request retries and succeeds
   - User sees no interruption

### Debugging Tips

If login fails, check logs:
```bash
adb logcat | grep -E "ApiClient|DioException|AuthService"
```

Look for:
- `[ApiClient] Base URL: http://103.172.204.34:8081`
- Network request/response logs
- Token refresh attempts
- Any error messages

## 🎯 Acceptance Criteria Status

### Requirement: All auth API calls use correct base URL
✅ **VERIFIED**
- Base URL set to `http://103.172.204.34:8081`
- No hard-coded old URLs found in auth code
- Centralized configuration in place

### Requirement: Auth endpoints match backend spec
✅ **VERIFIED**
- `/login` - matches spec
- `/me` - matches spec
- `/refresh` - matches spec
- `/revoke` - matches spec

### Requirement: Login with fardil succeeds
✅ **BACKEND VERIFIED** (via curl)
📱 **REQUIRES APK TESTING** on device

### Requirement: Login with arif succeeds
✅ **BACKEND VERIFIED** (via curl)
📱 **REQUIRES APK TESTING** on device

### Requirement: /me returns correct user info
✅ **BACKEND VERIFIED** (via curl)
📱 **REQUIRES APK TESTING** on device

### Requirement: Code structure is clean
✅ **VERIFIED**
- Base URL centralized in `constants.dart`
- Auth logic in `lib/features/auth/`
- API client with interceptor in `lib/core/services/`
- Clear separation of concerns

## 📚 Documentation Created

- [x] `docs/backend_integration_guide.md` - Complete integration guide
- [x] `docs/backend_testing_checklist.md` - This testing checklist

## 🚀 Next Steps

1. **Install APK on device**: Transfer and install the debug APK
2. **Run manual tests**: Complete all 6 test scenarios above
3. **Monitor logs**: Use adb logcat to verify API calls
4. **Test edge cases**: 
   - Poor network conditions
   - Invalid credentials
   - Expired tokens
5. **Production readiness**:
   - Consider using HTTPS in production
   - Add error analytics/monitoring
   - Implement flutter_secure_storage for sensitive data
   - Add user-friendly error messages

## 📊 Test Results Log

Fill in after manual testing:

| Scenario | Status | Notes |
|----------|--------|-------|
| Login as fardil | ⬜ | |
| Verify /me endpoint | ⬜ | |
| Login as arif | ⬜ | |
| Token persistence | ⬜ | |
| Logout flow | ⬜ | |
| Token refresh | ⬜ | |

Legend: ✅ Pass | ❌ Fail | ⬜ Not tested
