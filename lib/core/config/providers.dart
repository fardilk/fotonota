import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/data/auth_service.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/data/auth_state_notifier.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository(ref.read(authServiceProvider)));
final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) => AuthStateNotifier(ref.read(authRepositoryProvider)));
