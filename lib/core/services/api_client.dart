import 'package:dio/dio.dart';
import '../config/constants.dart';
import '../utils/prefs_helper.dart';
import '../../features/auth/data/auth_service.dart';

class ApiClient {
  ApiClient._internal() {
  // Debug: print effective base URL once
  // ignore: avoid_print
  print('[ApiClient] Base URL: ${AppConstants.apiBaseUrl}');
  _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        responseType: ResponseType.json,
        contentType: Headers.jsonContentType,
        headers: {
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await PrefsHelper.getToken();
        if (token != null && !options.headers.containsKey('Authorization')) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (e, handler) async {
        // Attempt refresh on 401 once
    if (e.response?.statusCode == 401) {
          final reqOptions = e.requestOptions;
            // Avoid infinite loop by flag
            if (reqOptions.extra['retried'] == true) {
              return handler.next(e);
            }
            try {
      final refresh = await PrefsHelper.getRefreshToken();
      if (refresh != null && refresh.isNotEmpty) {
                final authService = AuthService();
                final newTokens = await authService.refresh(refresh);
                await PrefsHelper.saveAuthTokens(
                  access: newTokens.accessToken,
                  refresh: newTokens.refreshToken,
                  expiresInSeconds: newTokens.expiresIn,
                );
                final newRequest = await _dio.fetch(reqOptions
                  ..headers['Authorization'] = 'Bearer ${newTokens.accessToken}'
                  ..extra['retried'] = true);
                return handler.resolve(newRequest);
              }
            } catch (_) {
              // swallow and fall through to original error
            }
        }
        return handler.next(e);
      },
    ));
  }

  late final Dio _dio;
  static final ApiClient instance = ApiClient._internal();

  Dio get dio => _dio;
}
