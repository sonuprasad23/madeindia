import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/app_routes.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/rakshak_button.dart';
import '../../core/widgets/rakshak_status.dart';
import '../../core/widgets/rakshak_surfaces.dart';
import '../../core/widgets/rakshak_timeline.dart';
import '../../data/models/case_record.dart';
import '../../data/models/incident.dart';
import '../../data/repositories/case_repository.dart';

CaseStatus? _canonicalNext(CaseStatus status) => switch (status) {
  CaseStatus.draft => CaseStatus.submitted,
  CaseStatus.submitted => CaseStatus.forwarded,
  CaseStatus.forwarded => CaseStatus.underReview,
  CaseStatus.underReview => CaseStatus.underInvestigation,
  CaseStatus.additionalInfoRequired => CaseStatus.underInvestigation,
  CaseStatus.underInvestigation => CaseStatus.resolved,
  CaseStatus.resolved => CaseStatus.closed,
  CaseStatus.closed => null,
};

class CaseDetailScreen extends ConsumerWidget {
  const CaseDetailScreen({super.key, required this.caseId});

  final String caseId;

  void _explainStatus(BuildContext context, CaseStatus status) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(status.label),
        content: Text(status.explanation),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cases = ref.watch(caseRepositoryProvider);
    final matches = cases.where((c) => c.id == caseId);
    if (matches.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Case')),
        body: const Center(child: Text('This case could not be found.')),
      );
    }
    final caseRecord = matches.first;
    final theme = Theme.of(context);

    final entries = <RakshakTimelineEntry>[];
    final history = [...caseRecord.timeline]
      ..sort((a, b) => a.occurredAt.compareTo(b.occurredAt));
    for (var i = 0; i < history.length; i++) {
      final step = history[i];
      final isLast = i == history.length - 1;
      entries.add(
        RakshakTimelineEntry(
          title: step.status.label,
          subtitle:
              '${AppFormatters.dateTime(step.occurredAt)}${step.note != null ? '\n${step.note}' : ''}',
          state: isLast
              ? RakshakTimelineState.current
              : RakshakTimelineState.done,
          onExplain: () => _explainStatus(context, step.status),
        ),
      );
    }

    var next = _canonicalNext(caseRecord.status);
    final seen = history.map((h) => h.status).toSet();
    while (next != null) {
      if (!seen.contains(next)) {
        entries.add(
          RakshakTimelineEntry(
            title: next.label,
            state: RakshakTimelineState.upcoming,
            onExplain: () => _explainStatus(context, next!),
          ),
        );
      }
      next = _canonicalNext(next);
    }

    return Scaffold(
      appBar: AppBar(title: Text('#${caseRecord.id}')),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.lg),
        children: [
          RakshakCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        caseRecord.category.label,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    RakshakStatusChip(status: caseRecord.status),
                  ],
                ),
                const SizedBox(height: Spacing.sm),
                if (caseRecord.complaintId != null)
                  _row(context, 'Reference ID', caseRecord.complaintId!),
                if (caseRecord.amountInPaise != null)
                  _row(
                    context,
                    'Amount',
                    AppFormatters.rupeesFromPaise(caseRecord.amountInPaise!),
                  ),
                if (caseRecord.jurisdictionPoliceStation != null)
                  _row(
                    context,
                    'Jurisdiction',
                    caseRecord.jurisdictionPoliceStation!,
                  ),
                _row(
                  context,
                  'Created',
                  AppFormatters.date(caseRecord.createdAt),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.xl),
          const RakshakSectionHeader(title: 'Status timeline'),
          RakshakCard(child: RakshakTimeline(entries: entries)),
          const SizedBox(height: Spacing.xl),
          RakshakButton(
            label: 'Ask Rakshak about this case',
            icon: Icons.chat_bubble_outline_rounded,
            variant: RakshakButtonVariant.secondary,
            onPressed: () => context.push(
              AppRoutes.assistant,
              extra: {
                'seedQuestion':
                    'What does the current status of case #${caseRecord.id} mean, and what should I do now?',
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
