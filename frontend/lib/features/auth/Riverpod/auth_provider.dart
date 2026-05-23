import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/session/services/auth_service.dart';
import '../../../core/session/app_session.dart';
<<<<<<< HEAD
import '../../profile/data/profile_service.dart';
=======
>>>>>>> main

final authServiceProvider = Provider((ref) => AuthService());

final authProvider = FutureProvider<bool>((ref) async {
  return await AppSession.isLoggedIn();
});

final loginProvider =
    FutureProvider.family<void, Map<String, String>>((ref, data) async {
  final service = ref.read(authServiceProvider);
  final response = await service.login(data['email']!, data['password']!);

  print('Login response: $response');
  print('User role from backend: ${response['user']['role']}');

  await AppSession.signIn(
    role: response['user']['role'] == 'admin'
        ? AppUserRole.admin
        : AppUserRole.user,
    email: response['user']['email'],
    displayName: response['user']['full_name'],
  );

  await AppSession.saveToken(response['accessToken']);
<<<<<<< HEAD
  // Seed profile cache with user data
  try {
    await ProfileService().setProfile(
        response['user']['email'], Map<String, dynamic>.from(response['user']));
  } catch (_) {}
=======
>>>>>>> main
  ref.invalidate(authProvider);
  ref.invalidate(isAdminProvider);
  ref.invalidate(currentUserRoleProvider);
  ref.invalidate(userNameProvider);
  ref.invalidate(userEmailProvider);
  print('After sign in - AppSession.isAdmin: ${AppSession.isAdmin}');
});

final registerProvider =
    FutureProvider.family<void, Map<String, String>>((ref, data) async {
  final service = ref.read(authServiceProvider);

  final fullName = data['fullName']!;
  final email = data['email']!;
  final password = data['password']!;

  final response = await service.register(fullName, email, password);

  AppSession.signIn(
    role: AppUserRole.user,
    email: response['user']['email'],
    displayName: response['user']['full_name'],
  );

  await AppSession.saveToken(response['accessToken']);
<<<<<<< HEAD
  try {
    await ProfileService().setProfile(
        response['user']['email'], Map<String, dynamic>.from(response['user']));
  } catch (_) {}
=======
>>>>>>> main
  ref.invalidate(authProvider);
});

final logoutProvider = FutureProvider<void>((ref) async {
  print('Logging out...');
  final service = ref.read(authServiceProvider);

<<<<<<< HEAD
  // capture current email to invalidate profile cache after sign out
  final currentEmail = AppSession.email;

=======
>>>>>>> main
  // Call backend logout
  await service.logout();

  // Clear local session
  await AppSession.signOut();

<<<<<<< HEAD
  // Invalidate cached profile for the signed-out user
  try {
    await ProfileService().invalidateProfile(email: currentEmail);
  } catch (_) {}

=======
>>>>>>> main
  // Invalidate all auth providers
  ref.invalidate(authProvider);
  ref.invalidate(isAdminProvider);
  ref.invalidate(currentUserRoleProvider);
  ref.invalidate(userNameProvider);
  ref.invalidate(userEmailProvider);

  print('Logout complete');
});

final isAdminProvider = Provider<bool>((ref) {
  final result = AppSession.isAdmin;
  print('isAdminProvider returning: $result');
  return result;
});
final currentUserRoleProvider = Provider<AppUserRole?>((ref) {
  print('Current role from AppSession: ${AppSession.role}'); // Debug
  return AppSession.role;
});
final userNameProvider = Provider<String>((ref) => AppSession.displayName);
final userEmailProvider = Provider<String>((ref) => AppSession.email);
