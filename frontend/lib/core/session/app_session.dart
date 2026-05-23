import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum AppUserRole { user, admin }

class AppSession {
  static const _storage = FlutterSecureStorage(
    webOptions: WebOptions(
      dbName: 'reclaim_secure',
      publicKey: 'reclaim_auth',
    ),
  );

  static AppUserRole role = AppUserRole.user;
  static String email = '';
  static String displayName = '';
  static int? userId;
  static String institutionName = 'Addis Ababa University';
  static String institutionDepartment = 'Founders Guild & Assets Management';

  static bool get isAdmin => role == AppUserRole.admin;

  static Future<void> load() async {
    final savedRole = await _storage.read(key: 'role');
    final savedEmail = await _storage.read(key: 'email');
    final savedName = await _storage.read(key: 'name');
    final savedUserId = await _storage.read(key: 'userId');

    if (savedRole != null) {
      role = savedRole == 'admin' ? AppUserRole.admin : AppUserRole.user;
      email = savedEmail ?? '';
      displayName = savedName ?? '';
      userId = int.tryParse(savedUserId ?? '');
    }
  }

  static Future<void> signIn({
    required AppUserRole role,
    required String email,
    required String displayName,
    int? userId,
  }) async {
    AppSession.role = role;
    AppSession.email = email;
    AppSession.displayName = displayName;
    AppSession.userId = userId;

    await _storage.write(key: 'role', value: role.name);
    await _storage.write(key: 'email', value: email);
    await _storage.write(key: 'name', value: displayName);
    if (userId != null) {
      await _storage.write(key: 'userId', value: userId.toString());
    } else {
      await _storage.delete(key: 'userId');
    }
  }

  static Future<void> signOut() async {
    role = AppUserRole.user;
    email = '';
    displayName = '';
    userId = null;

    await _storage.delete(key: 'role');
    await _storage.delete(key: 'email');
    await _storage.delete(key: 'name');
    await _storage.delete(key: 'userId');
    await clearToken();
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    if (token != null && token.isNotEmpty) return true;
    final savedRole = await _storage.read(key: 'role');
    return savedRole != null;
  }

  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'token', value: token);
  }

  static Future<String?> getToken() async {
    return _storage.read(key: 'token');
  }

  static Future<void> clearToken() async {
    await _storage.delete(key: 'token');
  }

  /// Helpful when running Flutter web against a local API.
  static String get apiHint {
    if (kIsWeb) {
      return 'Backend should be at $institutionHintHost (same machine as browser).';
    }
    return '';
  }

  static const String institutionHintHost = 'http://localhost:3000';
}
