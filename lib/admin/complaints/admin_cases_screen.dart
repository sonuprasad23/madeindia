import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/rakshak_status.dart';
import '../../core/widgets/rakshak_surfaces.dart';
import '../../data/models/case_record.dart';
import '../../data/models/incident.dart';
import '../../data/repositories/case_repository.dart';

/// Lets an admin advance a case's status — the "mock backend" that
/// citizen-side "My Cases" reflects in real time via shared app state.
/// There is no real government system behind this; see the demo
/// disclaimer shown throughout the citizen app.
class AdminCasesScreen extends ConsumerWidget {
  const AdminCasesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cases = ref.watch(caseRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cases'),
        automaticallyImplyLeading: false,
      ),
      body: cases.isEmpty
          ? const Center(child: Text('No cases submitted yet.'))
          : ListView.separated(
              padding: const EdgeInsets.all(Spacing.lg),
              itemCount: cases.length,
              separatorBuilder: (_, _) => const SizedBox(height: Spacing.md),
              itemBuilder: (context, index) {
                final c = cases[index];
                return RakshakCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '#${c.id} — ${c.category.label}',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          RakshakStatusChip(status: c.status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Created ${AppFormatters.date(c.createdAt)} • ${c.jurisdictionPoliceStation ?? 'Jurisdiction not set'}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: Spacing.md),
                      Wrap(
                        spacing: Spacing.sm,
                        children: CaseStatus.values
                            .map(
                              (s) => ChoiceChip(
                                label: Text(s.label),
                                selected: c.status == s,
                                onSelected: (_) => ref
                                    .read(caseRepositoryProvider.notifier)
                                    .advanceStatus(
                                      c.id,
                                      s,
                                      note: 'Updated by admin (demo).',
                                    ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
