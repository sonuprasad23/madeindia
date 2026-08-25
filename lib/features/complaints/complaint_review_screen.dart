import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/routing/app_routes.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/utils/id_generator.dart';
import '../../core/widgets/rakshak_button.dart';
import '../../core/widgets/rakshak_surfaces.dart';
import '../../data/models/case_record.dart';
import '../../data/models/incident.dart';
import '../../data/models/notification_item.dart';
import '../../data/repositories/case_repository.dart';
import '../../data/repositories/citizen_profile_repository.dart';
import '../../data/repositories/evidence_repository.dart';
import '../../data/repositories/incident_repository.dart';
import '../../data/repositories/notification_repository.dart';
import 'complaint_generator.dart';

class ComplaintReviewScreen extends ConsumerStatefulWidget {
  const ComplaintReviewScreen({super.key, required this.incidentId});

  final String incidentId;

  @override
  ConsumerState<ComplaintReviewScreen> createState() =>
      _ComplaintReviewScreenState();
}

class _ComplaintReviewScreenState extends ConsumerState<ComplaintReviewScreen> {
  bool _submitting = false;

  int? _extractAmountPaise(Map<String, String> formData) {
    for (final key in ['fraudAmount', 'amountPaid', 'amountInvested']) {
      final raw = formData[key];
      if (raw != null && raw.trim().isNotEmpty) {
        final cleaned = raw.replaceAll(RegExp(r'[^0-9.]'), '');
        final value = double.tryParse(cleaned);
        if (value != null) return (value * 100).round();
      }
    }
    return null;
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));

    final incident = ref
        .read(incidentRepositoryProvider)
        .firstWhere((i) => i.id == widget.incidentId);
    final profile = ref.read(citizenProfileProvider);
    final now = DateTime.now();

    final caseRecord = CaseRecord(
      id: IdGenerator.caseId(),
      category: incident.category,
      createdAt: now,
      status: CaseStatus.submitted,
      state: profile.state,
      jurisdictionPoliceStation: profile.jurisdiction?.suggestedPoliceStation,
      amountInPaise: _extractAmountPaise(incident.formData),
      lastUpdated: now,
      complaintId: IdGenerator.ncrpDemoComplaintId(),
      timeline: [
        CaseTimelineStep(
          status: CaseStatus.draft,
          occurredAt: now.subtract(const Duration(minutes: 2)),
        ),
        CaseTimelineStep(status: CaseStatus.submitted, occurredAt: now),
      ],
    );

    await ref.read(caseRepositoryProvider.notifier).add(caseRecord);
    await ref
        .read(notificationRepositoryProvider.notifier)
        .push(
          kind: NotificationKind.complaintUpdated,
          title: 'Complaint submitted',
          body:
              'Your ${incident.category.label} complaint (#${caseRecord.id}) has been submitted.',
        );

    if (!mounted) return;
    context.go('${AppRoutes.caseDetail}/${caseRecord.id}');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final incidents = ref.watch(incidentRepositoryProvider);
    final matches = incidents.where((i) => i.id == widget.incidentId);
    if (matches.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Complaint Review')),
        body: const Center(child: Text('This incident could not be found.')),
      );
    }
    final incident = matches.first;
    final profile = ref.watch(citizenProfileProvider);
    final evidence = ref
        .watch(evidenceRepositoryProvider)
        .where((e) => incident.evidenceIds.contains(e.id))
        .toList();

    final sections = ComplaintGenerator.buildSections(
      incident: incident,
      profile: profile,
      evidence: evidence,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Complaint Review')),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.lg),
        children: [
          Container(
            padding: const EdgeInsets.all(Spacing.md),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(Radii.md),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Text(
                    AppConstants.demoDisclaimer,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.lg),
          for (final section in sections) ...[
            RakshakCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: Spacing.sm),
                  for (final item in section.items)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            item.present
                                ? Icons.check_circle
                                : Icons.error_outline,
                            size: 18,
                            color: item.present
                                ? theme.colorScheme.tertiary
                                : theme.colorScheme.error,
                          ),
                          const SizedBox(width: Spacing.sm),
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: item.label,
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                  if (item.present &&
                                      item.value != null &&
                                      item.value!.isNotEmpty)
                                    TextSpan(
                                      text: ': ${item.value}',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  if (!item.present)
                                    TextSpan(
                                      text: ' — not provided',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme.colorScheme.error,
                                          ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: Spacing.md),
          ],

          RakshakCard(
            color: theme.colorScheme.secondaryContainer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppConstants.aiAssistedLabel,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                Text(
                  ComplaintGenerator.aiAssistedSummary(incident),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.xl),
          RakshakButton(
            label: 'Submit Complaint',
            icon: Icons.send_rounded,
            isLoading: _submitting,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
