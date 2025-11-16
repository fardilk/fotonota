import 'package:shared_preferences/shared_preferences.dart';

class PrefsKeys {
  static const onboardingSeen = 'onboarding_seen';
  static const authToken = 'auth_token';
  static const refreshToken = 'refresh_token';
  static const tokenExpiry = 'token_expiry_epoch';
  static const overlayLeft = 'camera_overlay_left';
  static const overlayTop = 'camera_overlay_top';
  static const overlayWidth = 'camera_overlay_width';
  static const overlayHeight = 'camera_overlay_height';
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

  // Camera overlay preset persistence
  static Future<void> saveOverlayPreset({required double left, required double top, required double width, required double height}) async {
    final p = await _prefs;
    await p.setDouble(PrefsKeys.overlayLeft, left);
    await p.setDouble(PrefsKeys.overlayTop, top);
    await p.setDouble(PrefsKeys.overlayWidth, width);
    await p.setDouble(PrefsKeys.overlayHeight, height);
  }

  static Future<({double? left, double? top, double? width, double? height})> getOverlayPreset() async {
    final p = await _prefs;
    return (
      left: p.getDouble(PrefsKeys.overlayLeft),
      top: p.getDouble(PrefsKeys.overlayTop),
      width: p.getDouble(PrefsKeys.overlayWidth),
      height: p.getDouble(PrefsKeys.overlayHeight),
    );
  }
}
