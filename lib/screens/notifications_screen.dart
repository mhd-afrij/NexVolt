import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/account_provider.dart';
import '../widgets/account_widgets.dart';
import '../widgets/shared_widgets.dart';

/// Shows all in-app notifications with unread highlighting.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountProvider>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AccountProvider>();
    final notifications = provider.notifications;
    final hasUnread = provider.unreadNotificationCount > 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (hasUnread)
            TextButton(
              onPressed: () =>
                  context.read<AccountProvider>().markAllNotificationsAsRead(),
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () =>
                  context.read<AccountProvider>().loadNotifications(),
              child: notifications.isEmpty
                  ? const AccountEmptyState(
                      icon: Icons.notifications_off_outlined,
                      title: 'No Notifications',
                      subtitle: "You're all caught up! Check back later.",
                    )
                  : ListView.separated(
                      itemCount: notifications.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, indent: 16, endIndent: 16),
                      itemBuilder: (_, i) {
                        final n = notifications[i];
                        return NotificationTile(
                          notification: n,
                          onTap: () {
                            if (!n.isRead) {
                              context
                                  .read<AccountProvider>()
                                  .markNotificationAsRead(n.notificationId);
                            }
                          },
                        );
                      },
                    ),
            ),
    );
  }
}
