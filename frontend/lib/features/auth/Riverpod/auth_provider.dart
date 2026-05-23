import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/dio_client.dart';
import '../../../core/session/services/auth_service.dart';
import '../../../core/session/app_session.dart';

final authServiceProvider = Provider((ref) {
  final dio = ref.watch(dioClientProvider);
  return AuthService(dio);
});

final authProvider = FutureProvider<bool>((ref) async {
  return await AppSession.isLoggedIn();
});

final loginProvider =
    FutureProvider.family<void, Map<String, String>>((ref, data) async {
  try {
    final service = ref.read(authServiceProvider);
    final response = await service.login(data['email']!, data['password']!);

    print('DEBUG: Login response received: $response');
    
    if (response['user'] == null) {
      throw Exception('User data missing in response');
    }

    await AppSession.signIn(
      role: response['user']['role'] == 'admin'
          ? AppUserRole.admin
          : AppUserRole.user,
      email: response['user']['email'] ?? '',
      displayName: response['user']['full_name'] ?? 'User',
      id: response['user']['id']?.toString() ?? '0',
    );

    print('DEBUG: AppSession.signIn completed');
    await AppSession.saveToken(response['accessToken'] ?? '');
    
    ref.invalidate(authProvider);
    ref.invalidate(userProvider);
    ref.invalidate(isAdminProvider);
    print('DEBUG: All providers invalidated');
  } catch (e, stack) {
    print('DEBUG: Login Error in Provider: $e');
    print('DEBUG: Stack trace: $stack');
    rethrow;
  }
});

final registerProvider =
    FutureProvider.family<void, Map<String, String>>((ref, data) async {
  final service = ref.read(authServiceProvider);

  final fullName = data['fullName']!;
  final email = data['email']!;
  final password = data['password']!;

  final response = await service.register(fullName, email, password);

  await AppSession.signIn(
    role: AppUserRole.user,
    email: response['user']['email'],
    displayName: response['user']['full_name'],
    id: response['user']['id'].toString(),
  );

  await AppSession.saveToken(response['accessToken']);
  ref.invalidate(authProvider);
  ref.invalidate(userProvider);
  ref.invalidate(isAdminProvider);
  ref.invalidate(currentUserRoleProvider);
  ref.invalidate(userNameProvider);
  ref.invalidate(userEmailProvider);
});

final logoutProvider = FutureProvider<void>((ref) async {
  print('Logging out...');
  final service = ref.read(authServiceProvider);

  // Call backend logout
  await service.logout();

  // Clear local session
  await AppSession.signOut();

  // Invalidate all auth providers
  ref.invalidate(authProvider);
  ref.invalidate(userProvider);
  ref.invalidate(isAdminProvider);
  ref.invalidate(currentUserRoleProvider);
  ref.invalidate(userNameProvider);
  ref.invalidate(userEmailProvider);

  print('Logout complete');
});

final userProvider = Provider<Map<String, dynamic>>((ref) {
  return {
    'id': AppSession.id,
    'email': AppSession.email,
    'full_name': AppSession.displayName,
    'role': AppSession.role.name,
  };
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
