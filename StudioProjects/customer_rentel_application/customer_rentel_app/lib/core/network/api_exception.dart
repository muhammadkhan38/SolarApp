import 'package:dio/dio.dart';

/// Friendly wrapper around Dio and Laravel validation failures.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, List<String>> errors;

  ApiException(this.message, {this.statusCode, this.errors = const {}});

  bool get isUnauthorized => statusCode == 401;

  String? errorFor(String field) => errors[field]?.first;

  String? get firstError => errors.isNotEmpty && errors.values.first.isNotEmpty
      ? errors.values.first.first
      : null;

  factory ApiException.fromDio(DioException e) {
    final res = e.response;
    final data = res?.data;
    var message = 'Something went wrong. Please try again.';
    final parsed = <String, List<String>>{};

    if (data is Map) {
      final map = data.map((key, value) => MapEntry('$key', value));
      final serverMessage = map['message'];
      if (serverMessage is String && serverMessage.trim().isNotEmpty) {
        message = serverMessage;
      }
      final serverErrors = map['errors'];
      if (serverErrors is Map) {
        serverErrors.forEach((key, value) {
          if (value is List) {
            parsed['$key'] = value.map((item) => '$item').toList();
          } else if (value != null) {
            parsed['$key'] = ['$value'];
          }
        });
      }
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.receiveTimeout) {
      message = 'Cannot reach Prince Limousine. Check your connection.';
    }

    return ApiException(message, statusCode: res?.statusCode, errors: parsed);
  }

  @override
  String toString() => message;
}
