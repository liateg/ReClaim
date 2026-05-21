import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum AppUserRole { user, admin }

class AppSession {
  static const _storage = FlutterSecureStorage();

  // Static properties your code expects
  static AppUserRole role = AppUserRole.user;
  static String email = '';
  static String displayName = '';
  static String institutionName = 'Addis Ababa University';
  static String institutionDepartment = 'Founders Guild & Assets Management';

  static bool get isAdmin => role == AppUserRole.admin;
  static bool get isLoggedIn => _token != null && _token!.isNotEmpty;

  static String? _token;

  // Initialize - load saved session
  static Future<void> init() async {
    final token = await _storage.read(key: 'token');
    final savedRole = await _storage.read(key: 'role');
    final savedEmail = await _storage.read(key: 'email');
    final savedName = await _storage.read(key: 'name');

    if (token != null) {
      _token = token;
      role = savedRole == 'admin' ? AppUserRole.admin : AppUserRole.user;
      email = savedEmail ?? '';
      displayName = savedName ?? '';
    }
  }

  // Sign in (keeps your existing API)
  static void signIn({
    required AppUserRole role,
    required String email,
    required String displayName,
  }) {
    AppSession.role = role;
    AppSession.email = email;
    AppSession.displayName = displayName;
  }

  // Sign out (keeps your existing API)
  static Future<void> signOut() async {
    role = AppUserRole.user;
    email = '';
    displayName = '';
    _token = null;

    await _storage.delete(key: 'token');
    await _storage.delete(key: 'role');
    await _storage.delete(key: 'email');
    await _storage.delete(key: 'name');
  }

  // Save token after login (for backend)
  static Future<void> saveToken(String token) async {
    _token = token;
    await _storage.write(key: 'token', token);
    await _storage.write(key: 'role', role.name);
    await _storage.write(key: 'email', email);
    await _storage.write(key: 'name', displayName);
  }

  // Get token (for API calls)
  static Future<String?> getToken() async {
    if (_token != null) return _token;
    return await _storage.read(key: 'token');
  }
}
