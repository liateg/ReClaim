import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/router/route_paths.dart';
import '../../features/auth/Riverpod/notification_provider.dart';

class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onProfileTap;
  final bool back;
  final bool showProfileAction;
  final Widget? leading;

  const CustomAppBar({
    super.key,
    required this.title,
    this.onProfileTap,
    this.back = true,
    this.showProfileAction = true,
    this.leading,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    // Listen for new notifications to show a SnackBar
    ref.listen(notificationsProvider, (previous, next) {
      if (next.hasValue && previous?.hasValue == true) {
        final prevList = previous!.value!;
        final nextList = next.value!;
        if (nextList.length > prevList.length) {
          final newNotif = nextList.first; // Newest is first due to backend sort
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFF1B5E3E),
              behavior: SnackBarBehavior.floating,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(newNotif.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(newNotif.message, style: const TextStyle(fontSize: 12)),
                ],
              ),
              action: SnackBarAction(
                label: 'VIEW',
                textColor: Colors.white,
                onPressed: () => _showNotifications(context, ref),
              ),
            ),
          );
        }
      }
    });

    return AppBar(
      title: Text(title),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      leading: leading,
      actions: showProfileAction
          ? [
              Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none_rounded),
                    onPressed: () {
                      _showNotifications(context, ref);
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onProfileTap ??
                        () => context.push(RoutePaths.profile),
                    child: const CircleAvatar(
                      backgroundColor: Color(0xFFD6D6D6),
                      child: Icon(Icons.person, color: Colors.black),
                    ),
                  ),
                ),
              ),
            ]
          : null,
      automaticallyImplyLeading: leading == null && back,
    );
  }

  void _showNotifications(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _NotificationsSheet(ref: ref);
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _NotificationsSheet extends ConsumerWidget {
  final WidgetRef ref;
  const _NotificationsSheet({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return notificationsAsync.when(
      data: (notifications) {
        if (notifications.isEmpty) {
          return const Center(child: Text('No notifications yet.'));
        }
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Notifications',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final n = notifications[index];
                  return ListTile(
                    leading: Icon(
                      n.title.contains('Approved') 
                        ? Icons.check_circle_outline 
                        : Icons.info_outline,
                      color: n.title.contains('Approved') ? Colors.green : Colors.blue,
                    ),
                    title: Text(n.title),
                    subtitle: Text(n.message),
                    trailing: n.read ? null : const Icon(Icons.fiber_manual_record, color: Colors.red, size: 10),
                    onTap: () {
                      ref.read(notificationServiceProvider).markAsRead(n.id);
                      ref.invalidate(notificationsProvider);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, __) => Center(child: Text('Error: $e')),
    );
  }
}
