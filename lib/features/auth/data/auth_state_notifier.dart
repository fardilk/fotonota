import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_repository.dart';
import '../models/auth_tokens.dart';

enum AuthStatus { unknown, unauthenticated, authenticated }

class AuthState {
  final AuthStatus status;
  final String? username;
  final bool loading;
  final String? error;
  AuthState({
    required this.status,
    this.username,
    this.loading = false,
    this.error,
  });
  AuthState copyWith({AuthStatus? status, String? username, bool? loading, String? error}) => AuthState(
        status: status ?? this.status,
        username: username ?? this.username,
        loading: loading ?? this.loading,
        error: error,
      );
  factory AuthState.initial() => AuthState(status: AuthStatus.unknown, loading: true);
}

class AuthStateNotifier extends StateNotifier<AuthState> {
  AuthStateNotifier(this._repo) : super(AuthState.initial()) {
    _init();
  }
  final AuthRepository _repo;
  AuthTokens? _tokens;

  Future<void> _init() async {
    try {
      await _repo.tryRefreshIfNeeded();
      final username = await _repo.currentUsername();
      if (username != null) {
        state = state.copyWith(status: AuthStatus.authenticated, username: username, loading: false);
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated, loading: false);
      }
    } catch (_) {
      state = state.copyWith(status: AuthStatus.unauthenticated, loading: false);
    }
  }

  Future<bool> login(String username, String password) async {
    state = state.copyWith(loading: true, error: null);
    try {
      _tokens = await _repo.login(username: username, password: password);
      String? me;
      try {
        me = await _repo.currentUsername();
      } catch (_) {
        // If /me fails (e.g., backend path mismatch or timing), still treat login as success.
        me = username;
      }
      state = state.copyWith(status: AuthStatus.authenticated, username: me, loading: false);
      return true;
    } catch (e) {
      // Surface a more specific error if available
      final msg = e.toString();
      state = state.copyWith(loading: false, error: msg.contains('ApiException') ? msg : 'Login failed');
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(loading: true);
    await _repo.logout();
    state = state.copyWith(status: AuthStatus.unauthenticated, username: null, loading: false);
  }
}
