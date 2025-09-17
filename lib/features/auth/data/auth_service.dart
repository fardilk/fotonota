import '../../../core/services/api_client.dart';
import '../../../core/errors/api_exception.dart';
import '../models/auth_tokens.dart';
import 'package:dio/dio.dart';

class AuthService {
  final _dio = ApiClient.instance.dio;

  Future<int> register({required String username, required String password}) async {
    try {
      final res = await _dio.post('/register', data: {
        'username': username,
        'password': password,
      });
      return (res.data as Map<String, dynamic>)['id'] as int; // 200 else throws
    } on DioException catch (e) {
      throw _asApiException(e);
    }
  }

  Future<AuthTokens> login({required String username, required String password}) async {
    try {
      final res = await _dio.post('/login', data: {
        'username': username,
        'password': password,
      });
      return AuthTokens.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _asApiException(e);
    }
  }

  Future<AuthTokens> refresh(String refreshToken) async {
    try {
      final res = await _dio.post('/refresh', data: {
        'refresh_token': refreshToken,
      });
      // refresh does not return new refresh token (per spec) so reuse existing
      final json = res.data as Map<String, dynamic>;
      return AuthTokens(
        accessToken: json['access_token'] as String,
        refreshToken: refreshToken,
        tokenType: json['token_type'] as String,
        expiresIn: (json['expires_in'] as num).toInt(),
      );
    } on DioException catch (e) {
      throw _asApiException(e);
    }
  }

  Future<void> revoke(String refreshToken) async {
    try {
      await _dio.post('/revoke', data: {
        'refresh_token': refreshToken,
      });
    } on DioException catch (e) {
      throw _asApiException(e);
    }
  }

  Future<String> me(String accessToken) async {
    try {
      final res = await _dio.get('/me', options: Options(headers: {
        'Authorization': 'Bearer $accessToken',
      }));
      return (res.data as Map<String, dynamic>)['username'] as String;
    } on DioException catch (e) {
      throw _asApiException(e);
    }
  }
}

ApiException _asApiException(DioException e) {
  final status = e.response?.statusCode;
  final data = e.response?.data;
  // Try to extract a server-provided message field if present
  String message;
  if (data is Map && data['message'] is String) {
    message = data['message'] as String;
  } else if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout || e.type == DioExceptionType.sendTimeout) {
    message = 'Request timeout';
  } else if (e.type == DioExceptionType.connectionError) {
    message = 'Connection error';
  } else if (e.type == DioExceptionType.cancel) {
    message = 'Request cancelled';
  } else {
    message = mapStatusToMessage(status);
  }
  return ApiException(statusCode: status, message: message, data: data);
}
