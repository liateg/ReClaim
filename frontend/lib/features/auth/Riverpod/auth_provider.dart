import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/session/services/auth_service.dart';
import '../../../core/session/app_session.dart';
import '../../profile/data/profile_service.dart';

final authServiceProvider = Provider((ref) => AuthService());

final authProvider = FutureProvider<bool>((ref) async {
  return AppSession.isLoggedIn();
});

Map<String, dynamic> _parseUserMap(dynamic raw) {
  if (raw is! Map) {
    throw Exception('Invalid user data from server.');
  }
  return Map<String, dynamic>.from(raw);
}

String _userField(Map<String, dynamic> user, String snake, String camel) {
  final value = user[snake] ?? user[camel];
  return value?.toString() ?? '';
}

int? _userIdFromMap(Map<String, dynamic> user) {
  final id = user['id'];
  if (id is int) return id;
  return int.tryParse(id?.toString() ?? '');
}

AppUserRole _roleFromUser(Map<String, dynamic> user) {
  final role = _userField(user, 'role', 'role');
  return role == 'admin' ? AppUserRole.admin : AppUserRole.user;
}

Future<void> persistAuthSession(Map<String, dynamic> response) async {
  final user = _parseUserMap(response['user']);
  final accessToken = response['accessToken']?.toString() ??
      response['token']?.toString() ??
      '';

  if (accessToken.isEmpty) {
    throw Exception('Server did not return an access token.');
  }

  await AppSession.signIn(
    role: _roleFromUser(user),
    email: _userField(user, 'email', 'email'),
    displayName: _userField(user, 'full_name', 'fullName'),
    userId: _userIdFromMap(user),
  );
  await AppSession.saveToken(accessToken);

  try {
    await ProfileService().setProfile(
      _userField(user, 'email', 'email'),
      user,
    );
  } catch (_) {}
}

/// Call from UI after login/register/logout — not from autoDispose providers.
void invalidateAuthState(WidgetRef ref) {
  ref.invalidate(authProvider);
  ref.invalidate(isAdminProvider);
  ref.invalidate(currentUserRoleProvider);
  ref.invalidate(userNameProvider);
  ref.invalidate(userEmailProvider);
}

final loginProvider = FutureProvider.autoDispose
    .family<void, Map<String, String>>((ref, data) async {
  final service = ref.read(authServiceProvider);
  final response = await service.login(data['email']!, data['password']!);
  await persistAuthSession(response);
});

final registerProvider = FutureProvider.autoDispose
    .family<void, Map<String, String>>((ref, data) async {
  final service = ref.read(authServiceProvider);
  final response = await service.register(
    data['fullName']!,
    data['email']!,
    data['password']!,
  );
  await persistAuthSession(response);
});

final logoutProvider = FutureProvider.autoDispose<void>((ref) async {
  final service = ref.read(authServiceProvider);
  final currentEmail = AppSession.email;

  await service.logout();
  await AppSession.signOut();

  try {
    await ProfileService().invalidateProfile(email: currentEmail);
  } catch (_) {}
});

final isAdminProvider = Provider<bool>((ref) => AppSession.isAdmin);
final currentUserRoleProvider = Provider<AppUserRole?>((ref) => AppSession.role);
final userNameProvider = Provider<String>((ref) => AppSession.displayName);
final userEmailProvider = Provider<String>((ref) => AppSession.email);
