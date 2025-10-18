import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/route_names.dart';
import 'core/config/app_theme.dart';
import 'routes.dart';
import 'core/config/env.dart';
import 'core/config/providers.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/data/auth_service.dart';
import 'features/auth/models/auth_tokens.dart';
import 'features/dashboard/data/dashboard_providers.dart';
import 'features/dashboard/data/dashboard_mocks.dart';
// import 'features/dashboard/data/dashboard_providers.dart';

// Mock implementations
class MockAuthService extends AuthService {
  @override
  Future<int> register({required String username, required String password}) async => 123;
  @override
  Future<AuthTokens> login({required String username, required String password}) async => AuthTokens(
    accessToken: 'mock',
    refreshToken: 'mock',
    tokenType: 'bearer',
    expiresIn: 3600,
  );
}

class MockAuthRepository extends AuthRepository {
  MockAuthRepository(): super(MockAuthService());
}

void main() {
  // Force mock flags for this entrypoint
  const appTitle = 'Fotonota (Demo)';
  runApp(ProviderScope(
    overrides: [
      authServiceProvider.overrideWithValue(MockAuthService()),
      authRepositoryProvider.overrideWithValue(MockAuthRepository()),
      profileRepoProvider.overrideWithValue(MockProfileRepository()),
      catatanRepoProvider.overrideWithValue(MockCatatanRepository()),
      uploadRepoProvider.overrideWithValue(MockUploadRepository()),
    ],
    child: const _DemoApp(title: appTitle),
  ));
}

class _DemoApp extends StatelessWidget {
  const _DemoApp({required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      initialRoute: RouteNames.splash,
      onGenerateRoute: onGenerateRoute,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        if (Env.showDebugMenu) {
          return Stack(children: [
            if (child != null) child,
            Positioned(
              left: 8, top: 8,
              child: Opacity(
                opacity: 0.6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(6)),
                  child: const Text('DEMO BUILD', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ]);
        }
        return child!;
      },
    );
  }
}
