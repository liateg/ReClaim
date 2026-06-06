import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/session/app_session.dart';

import '../helpers/test_helpers.dart';

/// End-to-end session flow exercised entirely offline against the mocked
/// secure storage: sign in, persist a token, reload, then sign out.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Map<String, String> store;

  setUp(() {
    store = mockSecureStorage();
    resetAppSession();
  });

  tearDown(clearSecureStorageMock);

  test('a fresh session is not logged in', () async {
    expect(await AppSession.isLoggedIn(), isFalse);
  });

  test('signing in persists the user and reports as logged in', () async {
    await AppSession.signIn(
      role: AppUserRole.user,
      email: 'abebe@aau.edu.et',
      displayName: 'Abebe Kebede',
      userId: 7,
    );
    await AppSession.saveToken('jwt-token-value');

    expect(AppSession.email, 'abebe@aau.edu.et');
    expect(AppSession.displayName, 'Abebe Kebede');
    expect(AppSession.userId, 7);
    expect(AppSession.isAdmin, isFalse);

    expect(store['role'], 'user');
    expect(store['token'], 'jwt-token-value');
    expect(await AppSession.getToken(), 'jwt-token-value');
    expect(await AppSession.isLoggedIn(), isTrue);
  });

  test('load() rehydrates static fields from storage', () async {
    store
      ..['role'] = 'admin'
      ..['email'] = 'admin@aau.edu.et'
      ..['name'] = 'Site Admin'
      ..['userId'] = '42';

    await AppSession.load();

    expect(AppSession.role, AppUserRole.admin);
    expect(AppSession.isAdmin, isTrue);
    expect(AppSession.email, 'admin@aau.edu.et');
    expect(AppSession.displayName, 'Site Admin');
    expect(AppSession.userId, 42);
  });

  test('signing out clears persisted state and the token', () async {
    await AppSession.signIn(
      role: AppUserRole.admin,
      email: 'admin@aau.edu.et',
      displayName: 'Site Admin',
      userId: 1,
    );
    await AppSession.saveToken('to-be-cleared');
    expect(await AppSession.isLoggedIn(), isTrue);

    await AppSession.signOut();

    expect(AppSession.role, AppUserRole.user);
    expect(AppSession.email, isEmpty);
    expect(AppSession.displayName, isEmpty);
    expect(AppSession.userId, isNull);
    expect(await AppSession.getToken(), isNull);
    expect(await AppSession.isLoggedIn(), isFalse);
  });
}
