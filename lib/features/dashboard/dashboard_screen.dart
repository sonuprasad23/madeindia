import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/app_routes.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/rakshak_case_card.dart';
import '../../core/widgets/rakshak_empty_dashboard.dart';
import '../../core/widgets/rakshak_surfaces.dart';
import '../../data/models/case_record.dart';
import '../../data/models/notification_item.dart';
import '../../data/repositories/case_repository.dart';
import '../../data/repositories/citizen_profile_repository.dart';
import '../../data/repositories/notification_repository.dart';
import '../location/location_card.dart';
import '../prevention/protection_settings_controller.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  IconData _iconFor(NotificationKind kind) => switch (kind) {
    NotificationKind.linkChecked => Icons.link_rounded,
    NotificationKind.evidenceSaved => Icons.folder_copy_outlined,
    NotificationKind.complaintUpdated => Icons.description_outlined,
    NotificationKind.caseStatusChanged => Icons.timeline_rounded,
    NotificationKind.general => Icons.notifications_outlined,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profile = ref.watch(citizenProfileProvider);
    final cases = ref.watch(caseRepositoryProvider);
    final notifications = ref.watch(notificationRepositoryProvider);
    final protection = ref.watch(protectionSettingsProvider);
    final firstName = profile.name.split(' ').first;

    final activeCases = cases
        .where(
          (c) =>
              c.status != CaseStatus.closed && c.status != CaseStatus.resolved,
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rakshak'),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => context.push(AppRoutes.notifications),
            icon: Badge(
              isLabelVisible:
                  ref
                      .read(notificationRepositoryProvider.notifier)
                      .unreadCount >
                  0,
              label: Text(
                '${ref.read(notificationRepositoryProvider.notifier).unreadCount}',
              ),
              child: const Icon(Icons.notifications_outlined),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: ListView(
          padding: const EdgeInsets.all(Spacing.lg),
          children: [
            Text(
              _greeting(),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              firstName,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Your cyber safety dashboard',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Spacing.xl),

            RakshakCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.verified_user_rounded,
                        color: theme.colorScheme.tertiary,
                      ),
                      const SizedBox(width: Spacing.sm),
                      Text(
                        'Cyber Safety',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.sm,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.tertiaryContainer,
                          borderRadius: BorderRadius.circular(Radii.pill),
                        ),
                        child: Text(
                          '🟢 Protection active',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onTertiaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: Spacing.xl),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Link protection'),
                    subtitle: const Text('Analyze links before you open them'),
                    value: protection.linkProtectionEnabled,
                    onChanged: (v) => ref
                        .read(protectionSettingsProvider.notifier)
                        .setLinkProtection(v),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Safe Link Viewer'),
                    subtitle: const Text(
                      'Open suspicious links in an isolated in-app viewer by default',
                    ),
                    value: protection.safeViewerDefaultOn,
                    onChanged: (v) => ref
                        .read(protectionSettingsProvider.notifier)
                        .setSafeViewerDefault(v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Spacing.xl),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: Spacing.md,
              crossAxisSpacing: Spacing.md,
              childAspectRatio: 2.4,
              children: [
                _QuickAction(
                  icon: Icons.link_rounded,
                  label: 'Check Link',
                  onTap: () => context.push(AppRoutes.linkChecker),
                ),
                _QuickAction(
                  icon: Icons.qr_code_scanner_rounded,
                  label: 'Scan QR',
                  onTap: () => context.push(AppRoutes.qrScanner),
                ),
                _QuickAction(
                  icon: Icons.report_problem_outlined,
                  label: 'Report Incident',
                  onTap: () => context.go(AppRoutes.report),
                ),
                _QuickAction(
                  icon: Icons.folder_copy_outlined,
                  label: 'Save Evidence',
                  onTap: () => context.push(AppRoutes.evidenceVault),
                ),
              ],
            ),
            const SizedBox(height: Spacing.xl),

            const LocationCard(),
            const SizedBox(height: Spacing.xl),

            RakshakSectionHeader(
              title: 'My Cases',
              action: TextButton(
                onPressed: () => context.go(AppRoutes.cases),
                child: const Text('View all'),
              ),
            ),
            if (activeCases.isEmpty)
              const RakshakEmptyDashboardHint(
                text:
                    'No active cases yet. A submitted complaint will appear here.',
              )
            else
              ...activeCases
                  .take(2)
                  .map(
                    (c) => Padding(
                      padding: const EdgeInsets.only(bottom: Spacing.md),
                      child: RakshakCaseCard(
                        caseRecord: c,
                        onTap: () =>
                            context.push('${AppRoutes.caseDetail}/${c.id}'),
                      ),
                    ),
                  ),
            const SizedBox(height: Spacing.xl),

            const RakshakSectionHeader(title: 'Recent activity'),
            if (notifications.isEmpty)
              const RakshakEmptyDashboardHint(
                text: 'Your activity will show up here.',
              )
            else
              RakshakCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: notifications.take(4).map((n) {
                    return ListTile(
                      leading: Icon(
                        _iconFor(n.kind),
                        color: theme.colorScheme.primary,
                      ),
                      title: Text(n.title),
                      subtitle: Text(
                        n.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text(
                        AppFormatters.relativeShort(n.createdAt),
                        style: theme.textTheme.labelSmall,
                      ),
                    );
                  }).toList(),
                ),
              ),
            const SizedBox(height: Spacing.xxxl),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RakshakCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.lg,
        vertical: Spacing.sm,
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: theme.colorScheme.primaryContainer,
            foregroundColor: theme.colorScheme.onPrimaryContainer,
            child: Icon(icon),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
