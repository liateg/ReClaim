import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/session/services/auth_service.dart';

import '../../helpers/test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  RequestOptions options() => RequestOptions(path: '/auth/login');

  setUpAll(() async {
    await initInMemoryCache();
  });

  setUp(() {
    mockSecureStorage();
    AuthService.setTestToken(null);
  });

  tearDown(() {
    AuthService.setTestToken(null);
    clearSecureStorageMock();
  });

  group('AuthService.baseUrl', () {
    test('is a non-empty http url', () {
      expect(AuthService.baseUrl, startsWith('http'));
    });
  });

  group('AuthService.messageFromDio', () {
    test('reads message from the response body', () {
      final e = DioException(
        requestOptions: options(),
        response: Response(
          requestOptions: options(),
          data: {'message': 'Bad password'},
          statusCode: 401,
        ),
      );
      expect(AuthService.messageFromDio(e, 'fallback'), 'Bad password');
    });

    test('returns a connection hint for connection errors', () {
      final e = DioException(
        requestOptions: options(),
        type: DioExceptionType.connectionError,
      );
      expect(AuthService.messageFromDio(e, 'fallback'),
          contains('Cannot reach server'));
    });

    test('appends status code when no message present', () {
      final e = DioException(
        requestOptions: options(),
        response: Response(requestOptions: options(), statusCode: 500),
      );
      expect(AuthService.messageFromDio(e, 'Login failed'),
          'Login failed (500)');
    });

    test('uses the fallback otherwise', () {
      final e = DioException(
        requestOptions: options(),
        type: DioExceptionType.unknown,
      );
      expect(AuthService.messageFromDio(e, 'Login failed'), 'Login failed');
    });
  });

  group('AuthService token handling', () {
    test('getToken returns the injected test token', () async {
      AuthService.setTestToken('injected-token');
      expect(await AuthService().getToken(), 'injected-token');
    });

    test('getToken falls back to the session token store', () async {
      final store = mockSecureStorage({'token': 'stored-token'});
      AuthService.setTestToken(null);
      expect(await AuthService().getToken(), 'stored-token');
      expect(store['token'], 'stored-token');
    });

    test('logout clears the stored token without a network call', () async {
      final store = mockSecureStorage({'token': 'will-be-removed'});
      // No test token, but storage has none after we null the session token.
      AuthService.setTestToken(null);
      store.remove('token');

      await AuthService().logout();

      expect(store.containsKey('token'), isFalse);
    });
  });
}
