import 'package:flutter_app_base/constants/types.dart';

class ApiError {
  final int statusCode;
  final String message;
  final Map<String, dynamic>? details;

  /// Field-specific errors (e.g., {"email": ["is invalid"], "password": ["is too short"]})
  final Map<String, List<String>> fieldErrors;

  ApiError({
    required this.statusCode,
    required this.message,
    this.details,
    this.fieldErrors = const {},
  });

  /// Returns errors for a specific field, or empty list if none
  List<String> errorsFor(String field) => fieldErrors[field] ?? [];

  /// Returns true if there are errors for a specific field
  bool hasErrorsFor(String field) => fieldErrors.containsKey(field);

  factory ApiError.fromJson(Json json, {required int statusCode}) {
    final errors = json['errors'];
    final error = json['error'];

    // Handle field-based errors: { "errors": { "email": ["is invalid"] } }
    if (errors is Map<String, dynamic>) {
      // Check if it's field-based (values are lists of strings)
      final isFieldBased = errors.values.every((v) => v is List);

      if (isFieldBased) {
        final fieldErrors = errors.map((key, value) {
          final messages = (value as List).map((e) => e.toString()).toList();
          return MapEntry(key, messages);
        });

        // Flatten to a single message for simple display
        final allMessages =
            fieldErrors.entries.expand((e) => e.value).toList();

        return ApiError(
          statusCode: statusCode,
          message: allMessages.join('. '),
          fieldErrors: fieldErrors,
        );
      } else if (errors['code'] != null) {
        // Handle: { "errors": { "code": 123, ... } }
        return ApiError(
          statusCode: errors['code'] as int? ?? statusCode,
          message: 'Error with Details',
          details: errors,
        );
      }
    }

    // Handle list of errors: { "errors": ["error message"] }
    if (errors is List && errors.isNotEmpty) {
      return ApiError(
        statusCode: statusCode,
        message: errors.first.toString(),
      );
    }

    // Handle single error: { "error": "error message" }
    if (error is String) {
      return ApiError(statusCode: statusCode, message: error);
    } else if (error is Json) {
      return ApiError(
        statusCode: error['code'] as int? ?? statusCode,
        message: 'Error with Details',
        details: error,
      );
    }

    return ApiError(statusCode: statusCode, message: 'Unknown API error');
  }

  @override
  String toString() {
    return 'ApiError(statusCode: $statusCode, message: $message, fieldErrors: $fieldErrors, details: $details)';
  }
}
