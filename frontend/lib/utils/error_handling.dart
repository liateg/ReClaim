import 'package:dio/dio.dart';

/// Centralized helpers that turn raw errors into user friendly messages.
class ErrorHandling {
  ErrorHandling._();

  /// Strips the leading `Exception: ` prefix that `Exception.toString()` adds.
  static String stripExceptionPrefix(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  /// Extracts a `message` field from a Dio error response, falling back to a
  /// connection hint or [fallback].
  static String fromDio(DioException error, {String fallback = 'Request failed'}) {
    final data = error.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Cannot reach the server. Please check your connection.';
    }
    final code = error.response?.statusCode;
    if (code != null) {
      return '$fallback ($code)';
    }
    return fallback;
  }

  /// Produces a friendly message for any error type.
  static String friendly(Object error, {String fallback = 'Something went wrong'}) {
    if (error is DioException) {
      return fromDio(error, fallback: fallback);
    }
    final message = stripExceptionPrefix(error);
    return message.isEmpty ? fallback : message;
  }
}
