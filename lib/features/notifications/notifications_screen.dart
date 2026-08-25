import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/rakshak_states.dart';
import '../../data/models/notification_item.dart';
import '../../data/repositories/notification_repository.dart';

IconData _iconFor(NotificationKind kind) => switch (kind) {
  NotificationKind.linkChecked => Icons.link_rounded,
  NotificationKind.evidenceSaved => Icons.folder_copy_outlined,
  NotificationKind.complaintUpdated => Icons.description_outlined,
  NotificationKind.caseStatusChanged => Icons.timeline_rounded,
  NotificationKind.general => Icons.notifications_outlined,
};

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (notifications.any((n) => !n.read))
            TextButton(
              onPressed: () => ref
                  .read(notificationRepositoryProvider.notifier)
                  .markAllRead(),
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? const RakshakEmptyState(
              title: 'No notifications',
              icon: Icons.notifications_none_rounded,
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
              itemCount: notifications.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final n = notifications[index];
                return ListTile(
                  leading: CircleAvatar(child: Icon(_iconFor(n.kind))),
                  title: Text(
                    n.title,
                    style: TextStyle(
                      fontWeight: n.read ? FontWeight.normal : FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(n.body),
                  trailing: Text(
                    AppFormatters.relativeShort(n.createdAt),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  onTap: () => ref
                      .read(notificationRepositoryProvider.notifier)
                      .markRead(n.id),
                );
              },
            ),
    );
  }
}
