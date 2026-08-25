import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/rakshak_states.dart';
import '../../../core/widgets/rakshak_status.dart';
import '../../../core/widgets/rakshak_surfaces.dart';
import '../../../data/repositories/link_repository.dart';

class LinkHistoryScreen extends ConsumerWidget {
  const LinkHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(linkRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Link History'),
        actions: [
          if (history.isNotEmpty)
            IconButton(
              tooltip: 'Clear history',
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: () =>
                  ref.read(linkRepositoryProvider.notifier).clear(),
            ),
        ],
      ),
      body: history.isEmpty
          ? const RakshakEmptyState(
              title: 'No links checked yet',
              message:
                  'Links you check will show up here so you can revisit the result.',
              icon: Icons.history_rounded,
            )
          : ListView.separated(
              padding: const EdgeInsets.all(Spacing.lg),
              itemCount: history.length,
              separatorBuilder: (_, _) => const SizedBox(height: Spacing.md),
              itemBuilder: (context, index) {
                final item = history[index];
                return RakshakCard(
                  onTap: () =>
                      context.push(AppRoutes.linkCheckerResult, extra: item),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.domain,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              AppFormatters.dateTime(item.checkedAt),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      RakshakRiskBadge(level: item.riskLevel, dense: true),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
