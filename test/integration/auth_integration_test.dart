import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snapcash_mobile/features/auth/data/auth_service.dart';
import 'package:snapcash_mobile/core/config/constants.dart';
import 'package:snapcash_mobile/core/services/api_client.dart';
import 'package:dio/dio.dart';
import 'dart:math';

void main() {
  final apiBase = AppConstants.apiBaseUrl;
  final shouldRun = !apiBase.contains('localhost') && !apiBase.contains('10.0.2.2');

  setUp(() async {
    // Ensure Flutter binding and in-memory shared preferences are ready.
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  group('Auth integration (real backend)', () {
    test('register succeeds and can login', () async {
      final svc = AuthService();
      final rnd = Random().nextInt(1 << 32);
      final username = 'autotest_${DateTime.now().millisecondsSinceEpoch}_$rnd';
      final id = await svc.register(username: username, password: 'test1234');
      expect(id, isNonZero);
      // Immediately login with the new user to confirm credentials work
      final tokens = await svc.login(username: username, password: 'test1234');
      expect(tokens.accessToken.isNotEmpty, true);
    }, skip: shouldRun ? false : 'Skipping: API_BASE_URL points to localhost/emulator.');

    test('login succeeds against backend', () async {
      final svc = AuthService();
      final tokens = await svc.login(username: 'usertest02', password: 'test1234');
      expect(tokens.accessToken.isNotEmpty, true);
      expect(tokens.tokenType.toLowerCase(), 'bearer');
      // Verify token works by calling /catatan/total
      final dio = ApiClient.instance.dio;
      final res = await dio.get('/catatan/total', options: Options(headers: {
        'Authorization': 'Bearer ${tokens.accessToken}',
      }));
      expect(res.statusCode, anyOf(200, 204));
      final data = res.data as Map<String, dynamic>;
      expect(data.containsKey('total'), true);
      expect(data['total'], isA<int>());
    }, skip: shouldRun ? false : 'Skipping: API_BASE_URL points to localhost/emulator.');
  });
}
