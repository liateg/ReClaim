import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/session/services/auth_service.dart';
import '../../../core/session/app_session.dart';

final authServiceProvider = Provider((ref) => AuthService());

final authProvider = FutureProvider<bool>((ref) async {
  return await AppSession.isLoggedIn();
});

final loginProvider =
    FutureProvider.family<void, Map<String, String>>((ref, data) async {
  final service = ref.read(authServiceProvider);
  final response = await service.login(data['email']!, data['password']!);

  AppSession.signIn(
    role: response['user']['role'] == 'admin'
        ? AppUserRole.admin
        : AppUserRole.user,
    email: response['user']['email'],
    displayName: response['user']['full_name'],
  );

  await AppSession.saveToken(response['accessToken']);
  ref.invalidate(authProvider);
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
  ref.invalidate(authProvider);
});

final logoutProvider = FutureProvider<void>((ref) async {
  final service = ref.read(authServiceProvider);
  await service.logout();
  await AppSession.signOut();
  ref.invalidate(authProvider);
  print('Provider logout successful ');
});

final isAdminProvider = Provider<bool>((ref) => AppSession.isAdmin);
final userNameProvider = Provider<String>((ref) => AppSession.displayName);
final userEmailProvider = Provider<String>((ref) => AppSession.email);
