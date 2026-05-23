import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/dio_client.dart';
import '../../../core/session/services/notification_service.dart';

final notificationServiceProvider = Provider((ref) {
  final dio = ref.watch(dioClientProvider);
  return NotificationService(dio);
});

final notificationsProvider = FutureProvider<List<NotificationModel>>((ref) async {
  final service = ref.read(notificationServiceProvider);
  
  // Refresh notifications every 30 seconds
  final timer = Stream.periodic(const Duration(seconds: 30)).listen((_) {
    ref.invalidateSelf();
  });
  
  ref.onDispose(() => timer.cancel());

  return await service.getNotifications();
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsProvider).value ?? [];
  return notifications.where((n) => !n.read).length;
});
