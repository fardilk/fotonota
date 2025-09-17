class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final dynamic data;
  ApiException({this.statusCode, required this.message, this.data});
  @override
  String toString() => 'ApiException($statusCode, $message)';
}

String mapStatusToMessage(int? code) {
  if (code == null) return 'Network error';
  switch (code) {
    case 400: return 'Bad request';
    case 401: return 'Unauthorized';
    case 403: return 'Forbidden';
    case 404: return 'Not found';
    case 409: return 'Conflict';
    case 500: return 'Server error';
    default: return 'Error ($code)';
  }
}
