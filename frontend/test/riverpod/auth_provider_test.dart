import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/session/app_session.dart';
import 'package:frontend/core/session/services/auth_service.dart';
import 'package:frontend/features/auth/Riverpod/auth_provider.dart';

import '../helpers/test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initInMemoryCache();
  });

  setUp(() {
    mockSecureStorage();
    resetAppSession();
  });

  tearDown(() {
    clearSecureStorageMock();
  });

  ProviderContainer makeContainer() {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    return container;
  }

  group('session-derived providers', () {
    test('isAdminProvider reflects the session role', () {
      AppSession.role = AppUserRole.admin;
      final container = makeContainer();
      expect(container.read(isAdminProvider), isTrue);
    });

    test('isAdminProvider is false for a normal user', () {
      AppSession.role = AppUserRole.user;
      final container = makeContainer();
      expect(container.read(isAdminProvider), isFalse);
    });

    test('currentUserRoleProvider exposes the role', () {
      AppSession.role = AppUserRole.admin;
      final container = makeContainer();
      expect(container.read(currentUserRoleProvider), AppUserRole.admin);
    });

    test('userNameProvider and userEmailProvider read the session', () {
      AppSession.displayName = 'Jane';
      AppSession.email = 'jane@x.com';
      final container = makeContainer();
      expect(container.read(userNameProvider), 'Jane');
      expect(container.read(userEmailProvider), 'jane@x.com');
    });
  });

  group('authServiceProvider', () {
    test('provides an AuthService instance', () {
      final container = makeContainer();
      expect(container.read(authServiceProvider), isA<AuthService>());
    });
  });

  group('authProvider', () {
    test('is false when no token or role is stored', () async {
      final container = makeContainer();
      expect(await container.read(authProvider.future), isFalse);
    });

    test('is true once a token is saved', () async {
      await AppSession.saveToken('a-token');
      final container = makeContainer();
      expect(await container.read(authProvider.future), isTrue);
    });
  });
}
