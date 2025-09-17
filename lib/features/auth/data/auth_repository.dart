import 'auth_service.dart';
import '../../../core/utils/prefs_helper.dart';
import '../models/auth_tokens.dart';

class AuthRepository {
  AuthRepository(this._service);
  final AuthService _service;

  Future<AuthTokens> login({required String username, required String password}) async {
    final tokens = await _service.login(username: username, password: password);
    await PrefsHelper.saveAuthTokens(
      access: tokens.accessToken,
      refresh: tokens.refreshToken,
      expiresInSeconds: tokens.expiresIn,
    );
    return tokens;
  }

  Future<int> register({required String username, required String password}) {
    return _service.register(username: username, password: password);
  }

  Future<AuthTokens?> tryRefreshIfNeeded() async {
    final expiry = await PrefsHelper.getTokenExpiry();
    final refresh = await PrefsHelper.getRefreshToken();
  if (refresh == null || refresh.isEmpty) return null;
    if (expiry != null && DateTime.now().isBefore(expiry)) return null; // still valid
    final tokens = await _service.refresh(refresh);
    await PrefsHelper.saveAuthTokens(
      access: tokens.accessToken,
      refresh: tokens.refreshToken,
      expiresInSeconds: tokens.expiresIn,
    );
    return tokens;
  }

  Future<String?> currentUsername() async {
    final token = await PrefsHelper.getToken();
    if (token == null) return null;
    return _service.me(token);
  }

  Future<void> logout() async {
    final refresh = await PrefsHelper.getRefreshToken();
    if (refresh != null) {
      try { await _service.revoke(refresh); } catch (_) {}
    }
    await PrefsHelper.clear();
  }
}
