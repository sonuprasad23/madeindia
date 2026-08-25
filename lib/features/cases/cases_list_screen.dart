import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/app_routes.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/rakshak_case_card.dart';
import '../../core/widgets/rakshak_states.dart';
import '../../data/repositories/case_repository.dart';

class CasesListScreen extends ConsumerWidget {
  const CasesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cases = ref.watch(caseRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Cases')),
      body: cases.isEmpty
          ? RakshakEmptyState(
              title: 'No cases yet',
              message:
                  'Cases you create by submitting a complaint will appear here.',
              icon: Icons.folder_open_outlined,
              actionLabel: 'Report an incident',
              onAction: () => context.go(AppRoutes.report),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(Spacing.lg),
              itemCount: cases.length,
              separatorBuilder: (_, _) => const SizedBox(height: Spacing.md),
              itemBuilder: (context, index) {
                final c = cases[index];
                return RakshakCaseCard(
                  caseRecord: c,
                  onTap: () => context.push('${AppRoutes.caseDetail}/${c.id}'),
                );
              },
            ),
    );
  }
}
