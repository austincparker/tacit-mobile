import 'package:flutter_app_base/model/api_error.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Tests ApiError class', () {
    test('fromJson creates ApiError from string error.', () {
      final errorJson = {'error': 'Something went wrong.'};
      final apiError = ApiError.fromJson(errorJson, statusCode: 500);

      expect(apiError.statusCode, 500);
      expect(apiError.message, 'Something went wrong.');
      expect(apiError.details, isNull);
    });

    test('fromJson creates ApiError with details from JSON.', () {
      final errorJson = {
        'errors': {'code': 404, 'message': 'Resource not found.'},
      };
      final apiError = ApiError.fromJson(errorJson, statusCode: 404);

      expect(apiError.statusCode, 404);
      expect(apiError.message, 'Error with Details');
      expect(apiError.details, errorJson['errors']);
    });

    test('fomJson creates ApiError with unknown API error.', () {
      final errorJson = {'invalid_field': 'This is an unknown error.'};
      final apiError = ApiError.fromJson(errorJson, statusCode: 500);

      expect(apiError.statusCode, 500);
      expect(apiError.message, 'Unknown API error');
      expect(apiError.details, isNull);
    });
  });
}
