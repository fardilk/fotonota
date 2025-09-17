import 'package:flutter_test/flutter_test.dart';
import 'package:snapcash_mobile/core/errors/api_exception.dart';

void main() {
  group('ApiException', () {
    test('toString contains status and message', () {
      final ex = ApiException(statusCode: 400, message: 'Bad request');
      expect(ex.toString(), contains('400'));
      expect(ex.toString(), contains('Bad request'));
    });

    test('mapStatusToMessage known codes', () {
      expect(mapStatusToMessage(400), 'Bad request');
      expect(mapStatusToMessage(401), 'Unauthorized');
      expect(mapStatusToMessage(404), 'Not found');
      expect(mapStatusToMessage(500), 'Server error');
    });

    test('mapStatusToMessage unknown code', () {
      expect(mapStatusToMessage(418), contains('418'));
    });

    test('null code becomes network error', () {
      expect(mapStatusToMessage(null), 'Network error');
    });
  });
}
