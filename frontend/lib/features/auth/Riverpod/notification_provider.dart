import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/dio_client.dart';
import '../../../core/session/services/notification_service.dart';

final notificationServiceProvider = Provider((ref) {
  final dio = ref.watch(dioClientProvider);
  return NotificationService(dio);
});

final notificationsProvider = FutureProvider<List<NotificationModel>>((ref) async {
  final service = ref.read(notificationServiceProvider);
  return await service.getNotifications();
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsProvider).value ?? [];
  return notifications.where((n) => !n.read).length;
});
