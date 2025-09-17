import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';

/// Simple backend smoke test that logs in and fetches /catatan/total.
/// Usage:
///   dart run tool/smoke_auth.dart
///   dart -DAPI_BASE_URL=http://103.172.204.34:8081 run tool/smoke_auth.dart user pass
Future<int> main(List<String> args) async {
  final apiBase = const String.fromEnvironment('API_BASE_URL', defaultValue: 'https://snapcash-api.fardil.com');
  final username = args.isNotEmpty ? args[0] : 'usertest02';
  final password = args.length > 1 ? args[1] : 'test1234';
  final doRegister = args.length > 2 && args[2].toLowerCase().contains('reg');

  final dio = Dio(BaseOptions(
    baseUrl: apiBase,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 20),
    contentType: Headers.jsonContentType,
    headers: {'Accept': 'application/json'},
    responseType: ResponseType.json,
  ));

  stdout.writeln('[SMOKE] Using API_BASE_URL=$apiBase');
  try {
    String loginUser = username;
    if (doRegister) {
      // Use provided username when available, otherwise generate an autotest name
      final newUser = (username.isNotEmpty && username != 'usertest02') ? username : 'autotest_${DateTime.now().millisecondsSinceEpoch}';
      stdout.writeln('[SMOKE] Registering new user: $newUser');
      final reg = await dio.post('/register', data: {
        'username': newUser,
        'password': password,
      });
      stdout.writeln('[SMOKE] Register result: ${reg.statusCode} ${reg.data}');
      loginUser = newUser;
    }
    // Login
    Response loginRes;
    try {
      loginRes = await dio.post('/login', data: {
        'username': loginUser,
        'password': password,
      });
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 || e.response?.statusCode == 415) {
        stdout.writeln('[SMOKE] JSON login failed (${e.response?.statusCode}). Trying form-urlencoded...');
        loginRes = await dio.post('/login', data: {
          'username': loginUser,
          'password': password,
        }, options: Options(contentType: Headers.formUrlEncodedContentType));
      } else {
        rethrow;
      }
    }
    if (loginRes.statusCode != 200 || loginRes.data is! Map) {
      stderr.writeln('[SMOKE] Login unexpected response: ${loginRes.statusCode} ${loginRes.data}');
      return 2;
    }
  final data = (loginRes.data as Map).cast<String, dynamic>();
  final access = (data['access_token'] ?? '') as String;
  final refresh = (data['refresh_token'] ?? '') as String;
  final tokenType = (data['token_type'] ?? '') as String;
  final expiresIn = (data['expires_in'] ?? 0) as int;

    if (access.isEmpty) {
      stderr.writeln('[SMOKE] Login succeeded but access_token is empty: $data');
      return 3;
    }
  // Print tokens and credentials for debugging (use carefully)
  stdout.writeln('[SMOKE] Credentials: username=$loginUser password=$password');
  stdout.writeln('[SMOKE] Got access_token (len=${access.length}), token_type=$tokenType, expires_in=$expiresIn, refresh_present=${refresh.isNotEmpty}');
  stdout.writeln('[SMOKE] access_token=$access');
  stdout.writeln('[SMOKE] refresh_token=$refresh');

    // Call /catatan/total
    final totalRes = await dio.get('/catatan/total', options: Options(headers: {
      'Authorization': 'Bearer $access',
    }));
    if (totalRes.statusCode != 200 || totalRes.data is! Map) {
      stderr.writeln('[SMOKE] /catatan/total unexpected response: ${totalRes.statusCode} ${totalRes.data}');
      return 4;
    }
    final total = (totalRes.data as Map)['total'];
    stdout.writeln('[SMOKE] /catatan/total => total=$total');

    return 0;
  } on DioException catch (e) {
    final code = e.response?.statusCode;
    final body = () {
      final d = e.response?.data;
      try {
        return d is String ? d : jsonEncode(d);
      } catch (_) {
        return d.toString();
      }
    }();
    stderr.writeln('[SMOKE] Dio error: ${e.type} status=$code body=$body');
    return 10;
  } catch (e, st) {
    stderr.writeln('[SMOKE] Error: $e\n$st');
    return 11;
  }
}
