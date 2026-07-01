import 'package:dio/dio.dart';

/// Friendly error wrapper around Dio/Laravel failures.
///
/// Laravel returns:
///   - 422 → `{ "message": "...", "errors": { "field": ["msg", ...] } }`
///   - others → `{ "message": "..." }`
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, List<String>> errors;

  ApiException(this.message, {this.statusCode, this.errors = const {}});

  bool get isUnauthorized => statusCode == 401;

  /// First field-level validation message, if any (handy under form fields).
  String? get firstError =>
      errors.isNotEmpty ? errors.values.first.first : null;

  factory ApiException.fromDio(DioException e) {
    final res = e.response;
    final data = res?.data;
    String message = 'Something went wrong. Please try again.';
    final parsed = <String, List<String>>{};

    if (data is Map) {
      if (data['message'] is String && (data['message'] as String).isNotEmpty) {
        message = data['message'] as String;
      }
      if (data['errors'] is Map) {
        (data['errors'] as Map).forEach((k, v) {
          if (v is List) parsed['$k'] = v.map((e) => '$e').toList();
        });
      }
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError) {
      message = 'Cannot reach the server. Check your connection.';
    }

    return ApiException(message, statusCode: res?.statusCode, errors: parsed);
  }

  @override
  String toString() => message;
}
