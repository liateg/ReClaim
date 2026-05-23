import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/session/services/auth_service.dart';
import '../../../core/session/app_session.dart';
import '../../profile/data/profile_service.dart';

final authServiceProvider = Provider((ref) => AuthService());

final authProvider = FutureProvider<bool>((ref) async {
  return AppSession.isLoggedIn();
});

final loginProvider =
    FutureProvider.family<AsyncValue<void>, Map<String, String>>(
        (ref, data) async {
  final service = ref.read(authServiceProvider);

  try {
    final response = await service.login(data['email']!, data['password']!);

    await AppSession.signIn(
      role: response['user']['role'] == 'admin'
          ? AppUserRole.admin
          : AppUserRole.user,
      email: response['user']['email'],
      displayName: response['user']['full_name'],
    );

    await AppSession.saveToken(response['accessToken']);

    ref.invalidate(authProvider);
    ref.invalidate(isAdminProvider);
    ref.invalidate(currentUserRoleProvider);
    ref.invalidate(userNameProvider);
    ref.invalidate(userEmailProvider);

    return const AsyncValue.data(null);
  } catch (e) {
    print('Login provider error: $e');
    return AsyncValue.error(e, StackTrace.current);
  }
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