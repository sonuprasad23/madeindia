import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/rakshak_button.dart';
import '../../core/widgets/rakshak_inputs.dart';
import '../../core/widgets/rakshak_status.dart';
import '../../core/widgets/rakshak_surfaces.dart';
import '../../data/models/risk_level.dart';
import '../../data/models/threat_domain.dart';
import '../../data/repositories/admin_repository.dart';

class AdminLinksScreen extends ConsumerWidget {
  const AdminLinksScreen({super.key});

  Future<void> _editDomain(
    BuildContext context,
    WidgetRef ref, {
    ThreatDomainRecord? existing,
  }) async {
    final domainController = TextEditingController(
      text: existing?.domain ?? '',
    );
    final reasonController = TextEditingController(
      text: existing?.reason ?? '',
    );
    RiskLevel status = existing?.status ?? RiskLevel.suspicious;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(existing == null ? 'Add domain' : 'Edit domain'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RakshakTextField(
                      label: 'Domain',
                      controller: domainController,
                      enabled: existing == null,
                    ),
                    const SizedBox(height: Spacing.lg),
                    RakshakDropdown<RiskLevel>(
                      label: 'Status',
                      value: status,
                      items: const [
                        RiskLevel.safe,
                        RiskLevel.suspicious,
                        RiskLevel.dangerous,
                      ],
                      itemLabel: (l) => l.shortLabel,
                      onChanged: (l) =>
                          setDialogState(() => status = l ?? status),
                    ),
                    const SizedBox(height: Spacing.lg),
                    RakshakTextField(
                      label: 'Reason',
                      controller: reasonController,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    if (domainController.text.trim().isEmpty) return;
                    ref
                        .read(threatDomainRepositoryProvider.notifier)
                        .upsert(
                          ThreatDomainRecord(
                            domain: domainController.text.trim().toLowerCase(),
                            status: status,
                            reason: reasonController.text.trim().isEmpty
                                ? 'Admin-reviewed record'
                                : reasonController.text.trim(),
                            lastUpdated: DateTime.now(),
                            reportCount: existing?.reportCount ?? 0,
                            checkCount: existing?.checkCount ?? 0,
                          ),
                        );
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final domains = ref.watch(threatDomainRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Threat Intelligence'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: RakshakButton(
                label: 'Add domain',
                icon: Icons.add_rounded,
                expand: false,
                onPressed: () => _editDomain(context, ref),
              ),
            ),
            const SizedBox(height: Spacing.lg),
            Expanded(
              child: ListView.separated(
                itemCount: domains.length,
                separatorBuilder: (_, _) => const SizedBox(height: Spacing.md),
                itemBuilder: (context, index) {
                  final d = domains[index];
                  return RakshakCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      d.domain,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                                  RakshakRiskBadge(
                                    level: d.status,
                                    dense: true,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                d.reason,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Reports: ${d.reportCount} • Checks: ${d.checkCount} • Updated ${AppFormatters.date(d.lastUpdated)}',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () =>
                              _editDomain(context, ref, existing: d),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded),
                          onPressed: () => ref
                              .read(threatDomainRepositoryProvider.notifier)
                              .remove(d.domain),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
