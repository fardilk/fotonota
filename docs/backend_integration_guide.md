# Backend Integration Guide

## Backend Configuration

### Base URL
```
http://103.172.204.34:8081
```

The base URL is configured in `lib/core/config/constants.dart` and can be overridden using:
```bash
flutter run --dart-define=API_BASE_URL=http://your-custom-url
```

### Authentication Endpoints

All auth endpoints are implemented in `lib/features/auth/data/auth_service.dart`:

#### 1. Login
- **Endpoint**: `POST /login`
- **Request Body**:
  ```json
  {
    "username": "fardil",
    "password": "admin123"
  }
  ```
- **Response**:
  ```json
  {
    "access_token": "<jwt>",
    "refresh_token": "<refresh>",
    "token_type": "bearer",
    "expires_in": 900
  }
  ```

#### 2. Get Current User
- **Endpoint**: `GET /me`
- **Headers**: `Authorization: Bearer <access_token>`
- **Response**:
  ```json
  {
    "username": "fardil"
  }
  ```

#### 3. Refresh Token
- **Endpoint**: `POST /refresh`
- **Request Body**:
  ```json
  {
    "refresh_token": "<refresh_token>"
  }
  ```
- **Response**:
  ```json
  {
    "access_token": "<new_jwt>",
    "token_type": "bearer",
    "expires_in": 900
  }
  ```

#### 4. Revoke Token (Logout)
- **Endpoint**: `POST /revoke`
- **Request Body**:
  ```json
  {
    "refresh_token": "<refresh_token>"
  }
  ```

## Test Users

### User 1: fardil
- **Username**: `fardil`
- **Password**: `admin123`

### User 2: arif
- **Username**: `arif`
- **Password**: `admin123`

## Token Management

### Storage
Tokens are stored using `SharedPreferences` in `lib/core/utils/prefs_helper.dart`:
- `access_token` - JWT access token
- `refresh_token` - JWT refresh token
- `token_expiry_epoch` - Expiry timestamp (with 5-second buffer)

### Automatic Token Refresh
The `ApiClient` (in `lib/core/services/api_client.dart`) includes a Dio interceptor that:
1. Automatically adds `Authorization: Bearer <token>` to all requests
2. On 401 response, attempts to refresh the token using `/refresh`
3. Retries the original request with the new token
4. Falls back to original error if refresh fails

### Token Flow
```
1. User logs in → receives access + refresh tokens
2. Tokens stored in SharedPreferences
3. All API requests include: Authorization: Bearer <access_token>
4. On 401 error → auto-refresh → retry request
5. On logout → revoke refresh token → clear storage
```

## Testing the Integration

### Manual Testing Steps

1. **Build the app**:
   ```bash
   # For Android
   flutter build apk --debug
   
   # For release
   flutter build apk --release
   ```

2. **Install on device**:
   ```bash
   # Debug APK location
   build/app/outputs/flutter-apk/app-debug.apk
   
   # Or use adb
   adb install -r build/app/outputs/flutter-apk/app-debug.apk
   ```

3. **Test Login Flow**:
   - Launch the app
   - Navigate to login screen
   - Enter credentials: `fardil` / `admin123`
   - Verify:
     - Login request goes to `http://103.172.204.34:8081/login`
     - App receives and stores tokens
     - User is redirected to dashboard
     - Dashboard shows "Hi, fardil"

4. **Test /me Endpoint**:
   - After login, the dashboard automatically calls `/me`
   - Verify the username is displayed in the app bar
   - Check console logs for API call details

5. **Test Token Refresh**:
   - Wait for token to expire (15 minutes)
   - Make any authenticated request
   - Verify automatic token refresh happens
   - Request succeeds without user intervention

6. **Test Logout**:
   - Tap logout button in dashboard
   - Verify:
     - `/revoke` is called with refresh token
     - Tokens are cleared from storage
     - User is redirected to login screen

### Using adb logcat to Monitor API Calls

```bash
# Filter for API client logs
adb logcat | grep "ApiClient"

# Filter for Dio network logs
adb logcat | grep "DioException"
```

### Testing with Different Users

Test the same flow with user `arif`:
```
Username: arif
Password: admin123
```

Both users should:
- Successfully log in
- Receive valid tokens
- Access dashboard
- See their username in app bar

## Troubleshooting

### Common Issues

1. **Connection Refused**
   - Verify backend is running: `curl http://103.172.204.34:8081/`
   - Check firewall rules on VPS
   - Ensure Android device can reach the IP

2. **401 Unauthorized**
   - Check token is being sent: look for `Authorization` header
   - Verify token hasn't expired
   - Check token format: `Bearer <token>`

3. **Token Refresh Loop**
   - Check refresh token is valid
   - Verify `/refresh` endpoint is working
   - Look for `retried` flag in error handler

4. **CORS Issues (Web only)**
   - Backend must allow CORS for web builds
   - Not an issue for mobile builds

### Debug Mode

Enable detailed logging by checking console output:
- `[ApiClient] Base URL:` - confirms base URL
- Network errors show full request/response details
- Token refresh attempts are logged

## Code Structure

```
lib/
├── core/
│   ├── config/
│   │   └── constants.dart          # API base URL config
│   ├── services/
│   │   └── api_client.dart         # Dio client with auth interceptor
│   └── utils/
│       └── prefs_helper.dart       # Token storage
└── features/
    └── auth/
        ├── data/
        │   ├── auth_service.dart      # API calls (login, /me, refresh, revoke)
        │   ├── auth_repository.dart   # Business logic + token management
        │   └── auth_state_notifier.dart  # Riverpod state management
        ├── models/
        │   └── auth_tokens.dart       # Token model
        └── presentation/
            └── login_page.dart        # Login UI
```

## Next Steps

1. Test with real devices on same network as VPS
2. Verify token expiry and refresh behavior
3. Test logout and login again
4. Monitor backend logs for any errors
5. Consider adding analytics/logging for production

## Security Notes

- Tokens stored in SharedPreferences (not encrypted on device)
- For production, consider using `flutter_secure_storage`
- Always use HTTPS in production
- Current setup uses HTTP for dev/testing
