import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/evidence_item.dart';
import '../theme/design_tokens.dart';
import 'rakshak_surfaces.dart';

IconData _iconFor(EvidenceType type) => switch (type) {
  EvidenceType.image => Icons.image_outlined,
  EvidenceType.pdf => Icons.picture_as_pdf_outlined,
  EvidenceType.video => Icons.videocam_outlined,
  EvidenceType.url => Icons.link_outlined,
  EvidenceType.text => Icons.notes_outlined,
  EvidenceType.document => Icons.description_outlined,
};

/// Card representing one item in the Evidence Vault.
class RakshakEvidenceCard extends StatelessWidget {
  const RakshakEvidenceCard({super.key, required this.item, this.onTap});

  final EvidenceItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateLabel = DateFormat('d MMM yyyy, h:mm a').format(item.createdAt);

    return RakshakCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: theme.colorScheme.secondaryContainer,
            child: Icon(
              _iconFor(item.type),
              color: theme.colorScheme.onSecondaryContainer,
            ),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.originalFileName,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.category.label} • ${item.formattedSize} • $dateLabel',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (item.extractedData?.hasAnyData ?? false) ...[
                  const SizedBox(height: Spacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(Radii.sm),
                    ),
                    child: Text(
                      'Extracted from evidence — please verify',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onTertiaryContainer,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
