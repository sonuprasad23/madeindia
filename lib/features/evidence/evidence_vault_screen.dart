import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/app_routes.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/rakshak_evidence_card.dart';
import '../../core/widgets/rakshak_states.dart';
import '../../data/models/evidence_item.dart';
import '../../data/repositories/evidence_repository.dart';
import 'add_evidence_sheet.dart';

class EvidenceVaultScreen extends ConsumerStatefulWidget {
  const EvidenceVaultScreen({super.key});

  @override
  ConsumerState<EvidenceVaultScreen> createState() =>
      _EvidenceVaultScreenState();
}

class _EvidenceVaultScreenState extends ConsumerState<EvidenceVaultScreen> {
  EvidenceCategory? _filter;

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(evidenceRepositoryProvider);
    final items = _filter == null
        ? all
        : all.where((e) => e.category == _filter).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Evidence Vault')),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: Spacing.sm),
                  child: ChoiceChip(
                    label: const Text('All'),
                    selected: _filter == null,
                    onSelected: (_) => setState(() => _filter = null),
                  ),
                ),
                ...EvidenceCategory.values.map(
                  (c) => Padding(
                    padding: const EdgeInsets.only(right: Spacing.sm),
                    child: ChoiceChip(
                      label: Text(c.label),
                      selected: _filter == c,
                      onSelected: (_) => setState(() => _filter = c),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: items.isEmpty
                ? RakshakEmptyState(
                    title: 'No evidence saved yet',
                    message:
                        'Add screenshots, documents, or notes related to an incident. The original file is never modified.',
                    icon: Icons.folder_open_outlined,
                    actionLabel: 'Add evidence',
                    onAction: () => showAddEvidenceSheet(context, ref),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(Spacing.lg),
                    itemCount: items.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: Spacing.md),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return RakshakEvidenceCard(
                        item: item,
                        onTap: () => context.push(
                          '${AppRoutes.evidenceDetail}/${item.id}',
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddEvidenceSheet(context, ref),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
