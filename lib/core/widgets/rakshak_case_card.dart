import 'package:flutter/material.dart';

import '../../data/models/case_record.dart';
import '../../data/models/incident.dart';
import '../utils/formatters.dart';
import 'rakshak_status.dart';
import 'rakshak_surfaces.dart';
import '../theme/design_tokens.dart';

/// Card summarizing one tracked case — used in the dashboard's "My Cases"
/// section and the full Case Management list.
class RakshakCaseCard extends StatelessWidget {
  const RakshakCaseCard({super.key, required this.caseRecord, this.onTap});

  final CaseRecord caseRecord;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RakshakCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  caseRecord.category.label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              RakshakStatusChip(status: caseRecord.status),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '#${caseRecord.id}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (caseRecord.amountInPaise != null) ...[
            const SizedBox(height: Spacing.sm),
            Text(
              AppFormatters.rupeesFromPaise(caseRecord.amountInPaise!),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: Spacing.sm),
          Text(
            'Last updated ${AppFormatters.relativeShort(caseRecord.lastUpdated ?? caseRecord.createdAt)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
