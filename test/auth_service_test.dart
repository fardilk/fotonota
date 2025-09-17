import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snapcash_mobile/features/auth/data/auth_service.dart';
import 'package:snapcash_mobile/features/auth/models/auth_tokens.dart';
import 'package:snapcash_mobile/core/services/api_client.dart';
import 'helpers/mock_adapter.dart';
import 'package:snapcash_mobile/core/errors/api_exception.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('AuthService', () {
    late MockAdapter adapter;
    late AuthService service;

    setUp(() {
      adapter = MockAdapter();
      // Inject into singleton (ugly but for test). Replace internal dio.
      ApiClient.instance.dio.options.baseUrl = 'http://test/';
      ApiClient.instance.dio.httpClientAdapter = adapter;
      service = AuthService();
    });

    test('login success returns tokens', () async {
      adapter.on('POST', '/login', (_) async => adapter.json({
            'access_token': 'a1',
            'refresh_token': 'r1',
            'token_type': 'bearer',
            'expires_in': 60,
          }));
      final tokens = await service.login(username: 'u', password: 'p');
      expect(tokens, isA<AuthTokens>());
      expect(tokens.accessToken, 'a1');
      expect(tokens.refreshToken, 'r1');
    });

    test('login failure maps to ApiException unauthorized', () async {
      adapter.on('POST', '/login', (_) async => adapter.json({'message': 'Invalid'}, status: 401));
      expect(
        () => service.login(username: 'bad', password: 'pwd'),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'status', 401)),
      );
    });
  });
}
