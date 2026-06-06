import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/utils/error_handling.dart';

void main() {
  RequestOptions options() => RequestOptions(path: '/x');

  group('ErrorHandling.stripExceptionPrefix', () {
    test('removes the Exception: prefix', () {
      expect(ErrorHandling.stripExceptionPrefix(Exception('boom')), 'boom');
    });
    test('leaves plain strings unchanged', () {
      expect(ErrorHandling.stripExceptionPrefix('plain'), 'plain');
    });
  });

  group('ErrorHandling.fromDio', () {
    test('extracts message from response body', () {
      final e = DioException(
        requestOptions: options(),
        response: Response(
          requestOptions: options(),
          data: {'message': 'Invalid credentials'},
          statusCode: 401,
        ),
      );
      expect(ErrorHandling.fromDio(e), 'Invalid credentials');
    });

    test('returns connection hint for timeouts', () {
      final e = DioException(
        requestOptions: options(),
        type: DioExceptionType.connectionTimeout,
      );
      expect(ErrorHandling.fromDio(e), contains('Cannot reach the server'));
    });

    test('appends status code to fallback when no message', () {
      final e = DioException(
        requestOptions: options(),
        response: Response(requestOptions: options(), statusCode: 500),
      );
      expect(ErrorHandling.fromDio(e, fallback: 'Failed'), 'Failed (500)');
    });

    test('uses fallback when nothing else available', () {
      final e = DioException(
        requestOptions: options(),
        type: DioExceptionType.unknown,
      );
      expect(ErrorHandling.fromDio(e, fallback: 'Oops'), 'Oops');
    });
  });

  group('ErrorHandling.friendly', () {
    test('delegates to fromDio for DioException', () {
      final e = DioException(
        requestOptions: options(),
        response: Response(
          requestOptions: options(),
          data: {'message': 'Server says no'},
        ),
      );
      expect(ErrorHandling.friendly(e), 'Server says no');
    });

    test('strips exception prefix for generic errors', () {
      expect(ErrorHandling.friendly(Exception('bad thing')), 'bad thing');
    });

    test('uses fallback for empty messages', () {
      expect(ErrorHandling.friendly(Exception(''), fallback: 'Default'),
          'Default');
    });
  });
}
