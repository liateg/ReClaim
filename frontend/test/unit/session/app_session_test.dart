import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/session/app_session.dart';

import '../../helpers/test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Map<String, String> store;

  setUp(() {
    store = mockSecureStorage();
    resetAppSession();
  });

  tearDown(() {
    clearSecureStorageMock();
  });

  group('AppSession.signIn', () {
    test('updates static fields and persists to storage', () async {
      await AppSession.signIn(
        role: AppUserRole.admin,
        email: 'admin@x.com',
        displayName: 'Admin',
        userId: 11,
      );

      expect(AppSession.role, AppUserRole.admin);
      expect(AppSession.email, 'admin@x.com');
      expect(AppSession.displayName, 'Admin');
      expect(AppSession.userId, 11);
      expect(AppSession.isAdmin, isTrue);

      expect(store['role'], 'admin');
      expect(store['email'], 'admin@x.com');
      expect(store['name'], 'Admin');
      expect(store['userId'], '11');
    });

    test('deletes userId key when null', () async {
      store['userId'] = '99';
      await AppSession.signIn(
        role: AppUserRole.user,
        email: 'u@x.com',
        displayName: 'U',
        userId: null,
      );
      expect(store.containsKey('userId'), isFalse);
    });
  });

  group('AppSession.load', () {
    test('restores fields from storage', () async {
      store.addAll({
        'role': 'admin',
        'email': 'me@x.com',
        'name': 'Me',
        'userId': '5',
      });

      await AppSession.load();

      expect(AppSession.role, AppUserRole.admin);
      expect(AppSession.email, 'me@x.com');
      expect(AppSession.displayName, 'Me');
      expect(AppSession.userId, 5);
    });

    test('leaves defaults when nothing is stored', () async {
      await AppSession.load();
      expect(AppSession.role, AppUserRole.user);
      expect(AppSession.email, '');
    });
  });

  group('AppSession.signOut', () {
    test('clears fields and storage', () async {
      await AppSession.signIn(
        role: AppUserRole.admin,
        email: 'a@x.com',
        displayName: 'A',
        userId: 1,
      );
      await AppSession.saveToken('tok');

      await AppSession.signOut();

      expect(AppSession.role, AppUserRole.user);
      expect(AppSession.email, '');
      expect(AppSession.userId, isNull);
      expect(store.containsKey('role'), isFalse);
      expect(store.containsKey('token'), isFalse);
    });
  });

  group('AppSession token helpers', () {
    test('saveToken / getToken / clearToken', () async {
      await AppSession.saveToken('abc123');
      expect(await AppSession.getToken(), 'abc123');
      await AppSession.clearToken();
      expect(await AppSession.getToken(), isNull);
    });
  });

  group('AppSession.isLoggedIn', () {
    test('true when a token exists', () async {
      await AppSession.saveToken('t');
      expect(await AppSession.isLoggedIn(), isTrue);
    });

    test('true when a role is stored even without token', () async {
      store['role'] = 'user';
      expect(await AppSession.isLoggedIn(), isTrue);
    });

    test('false when nothing stored', () async {
      expect(await AppSession.isLoggedIn(), isFalse);
    });
  });
}
