import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
// ignore_for_file: avoid_print

/// Simple programmable adapter for Dio.
class MockAdapter implements HttpClientAdapter {
  final _handlers = <String, Future<ResponseBody> Function(RequestOptions)>{};

  void on(String method, String path, FutureOr<ResponseBody> Function(RequestOptions) handler) {
    _handlers['${method.toUpperCase()} $path'] = (opts) async => await handler(opts);
  }

  ResponseBody _jsonBody(Object data, {int status = 200, Map<String, List<String>>? headers}) {
    return ResponseBody.fromString(jsonEncode(data), status, headers: headers ?? {Headers.contentTypeHeader: ['application/json']});
  }

  ResponseBody json(Object data, {int status = 200}) => _jsonBody(data, status: status);

  @override
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<List<int>>? requestStream, Future? cancelFuture) async {
    final key = '${options.method.toUpperCase()} ${options.path}';
    final handler = _handlers[key];
    if (handler != null) {
      return await handler(options);
    }
    return _jsonBody({'message': 'Not Found'}, status: 404);
  }
}
