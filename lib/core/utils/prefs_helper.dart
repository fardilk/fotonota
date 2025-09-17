import 'package:shared_preferences/shared_preferences.dart';

class PrefsKeys {
  static const onboardingSeen = 'onboarding_seen';
  static const authToken = 'auth_token';
  static const refreshToken = 'refresh_token';
  static const tokenExpiry = 'token_expiry_epoch';
}

class PrefsHelper {
  PrefsHelper._();
  static Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  static Future<bool> isOnboardingSeen() async {
    final p = await _prefs;
    return p.getBool(PrefsKeys.onboardingSeen) ?? false;
  }

  static Future<void> setOnboardingSeen() async {
    final p = await _prefs;
    await p.setBool(PrefsKeys.onboardingSeen, true);
  }

  static Future<void> saveToken(String token) async {
    final p = await _prefs;
    await p.setString(PrefsKeys.authToken, token);
  }

  static Future<String?> getToken() async {
    final p = await _prefs;
    return p.getString(PrefsKeys.authToken);
  }

  static Future<void> clear() async {
    final p = await _prefs;
    await p.clear();
  }

  static Future<void> saveAuthTokens({required String access, required String refresh, required int expiresInSeconds}) async {
    final p = await _prefs;
    final expiryEpoch = DateTime.now().add(Duration(seconds: expiresInSeconds - 5)).millisecondsSinceEpoch; // small buffer
    await p.setString(PrefsKeys.authToken, access);
    await p.setString(PrefsKeys.refreshToken, refresh);
    await p.setInt(PrefsKeys.tokenExpiry, expiryEpoch);
  }

  static Future<String?> getRefreshToken() async {
    final p = await _prefs; return p.getString(PrefsKeys.refreshToken);
  }

  static Future<DateTime?> getTokenExpiry() async {
    final p = await _prefs; final ms = p.getInt(PrefsKeys.tokenExpiry); return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }
}
