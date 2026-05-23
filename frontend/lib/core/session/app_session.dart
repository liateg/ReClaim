import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum AppUserRole { user, admin }

class AppSession {
  static const _storage = FlutterSecureStorage();

  // Current session data
  static AppUserRole role = AppUserRole.user;
  static String email = '';
  static String displayName = '';
  static String institutionName = 'Addis Ababa University';
  static String institutionDepartment = 'Founders Guild & Assets Management';

  static bool get isAdmin => role == AppUserRole.admin;

  // Load saved session from phone storage
  static Future<void> load() async {
    final savedRole = await _storage.read(key: 'role');
    final savedEmail = await _storage.read(key: 'email');
    final savedName = await _storage.read(key: 'name');

    if (savedRole != null) {
      role = savedRole == 'admin' ? AppUserRole.admin : AppUserRole.user;
      email = savedEmail ?? '';
      displayName = savedName ?? '';
    }
  }

  // Sign in (saves to memory AND phone)
  static Future<void> signIn({
    required AppUserRole role,
    required String email,
    required String displayName,
  }) async {
    AppSession.role = role;
    AppSession.email = email;
    AppSession.displayName = displayName;

    // Save to phone
    await _storage.write(key: 'role', value: role.name);
    await _storage.write(key: 'email', value: email);
    await _storage.write(key: 'name', value: displayName);
  }

  // Sign out (clears everything)
  static Future<void> signOut() async {
    role = AppUserRole.user;
    email = '';
    displayName = '';

    // Clear from phone
    await _storage.delete(key: 'role');
    await _storage.delete(key: 'email');
    await _storage.delete(key: 'name');
    await clearToken();
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'role');
    return token != null;
  }

  // For JWT token (for API calls)
  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'token', value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  static Future<void> clearToken() async {
    await _storage.delete(key: 'token');
  }
}
