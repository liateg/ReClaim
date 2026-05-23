import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/session/services/auth_service.dart';
import '../../../core/session/app_session.dart';
import '../../profile/data/profile_service.dart';

final authServiceProvider = Provider((ref) => AuthService());

Future<void> persistAuthSession(Map<String, dynamic> response) async {
  final user = Map<String, dynamic>.from(response['user'] as Map);
  await AppSession.signIn(
    role: user['role'] == 'admin' ? AppUserRole.admin : AppUserRole.user,
    email: user['email']?.toString() ?? '',
    displayName: user['full_name']?.toString() ?? '',
    userId: int.tryParse(user['id']?.toString() ?? ''),
  );
  final accessToken = response['accessToken'] ?? response['token'];
  if (accessToken != null) {
    await AppSession.saveToken(accessToken.toString());
  }
}

void invalidateAuthState(dynamic ref) {
  ref.invalidate(authProvider);
  ref.invalidate(isAdminProvider);
  ref.invalidate(currentUserRoleProvider);
  ref.invalidate(userNameProvider);
  ref.invalidate(userEmailProvider);
}

final authProvider = FutureProvider<bool>((ref) async {
  return AppSession.isLoggedIn();
});

final loginProvider =
    FutureProvider.family<void, Map<String, String>>((ref, data) async {
  final service = ref.read(authServiceProvider);

  final response = await service.login(data['email']!, data['password']!);
  await persistAuthSession(response);
  invalidateAuthState(ref);
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
  invalidateAuthState(ref);
});

final logoutProvider = FutureProvider.autoDispose<void>((ref) async {
  final service = ref.read(authServiceProvider);
  final currentEmail = AppSession.email;

  await service.logout();
  await AppSession.signOut();

  try {
    await ProfileService().invalidateProfile(email: currentEmail);
  } catch (_) {}

  invalidateAuthState(ref);
});

final isAdminProvider = Provider<bool>((ref) => AppSession.isAdmin);
final currentUserRoleProvider =
    Provider<AppUserRole?>((ref) => AppSession.role);
final userNameProvider = Provider<String>((ref) => AppSession.displayName);
final userEmailProvider = Provider<String>((ref) => AppSession.email);
