import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/rakshak_states.dart';
import '../../core/widgets/rakshak_surfaces.dart';
import '../../data/models/evidence_item.dart';
import '../../data/models/incident.dart';
import '../../data/repositories/evidence_repository.dart';
import '../../data/repositories/incident_repository.dart';

class EvidenceDetailScreen extends ConsumerWidget {
  const EvidenceDetailScreen({super.key, required this.evidenceId});

  final String evidenceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(evidenceRepositoryProvider);
    final matches = items.where((e) => e.id == evidenceId);
    if (matches.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Evidence')),
        body: const RakshakErrorState(
          message: 'This evidence item could not be found.',
        ),
      );
    }
    final item = matches.first;
    final theme = Theme.of(context);
    final incidents = ref.watch(incidentRepositoryProvider);
    final relatedIncident = incidents.where(
      (i) => i.id == item.relatedIncidentId,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Evidence detail')),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.lg),
        children: [
          if (item.type == EvidenceType.image && item.filePath != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(Radii.lg),
              child: Image.file(
                File(item.filePath!),
                fit: BoxFit.cover,
                height: 220,
                width: double.infinity,
              ),
            )
          else if (item.textContent != null)
            RakshakCard(child: SelectableText(item.textContent!))
          else
            RakshakCard(
              child: Row(
                children: [
                  Icon(
                    Icons.insert_drive_file_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(child: Text(item.originalFileName)),
                ],
              ),
            ),
          const SizedBox(height: Spacing.lg),

          RakshakCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _row(context, 'Evidence ID', item.id.substring(0, 8)),
                _row(context, 'Type', item.type.label),
                _row(context, 'Category', item.category.label),
                _row(context, 'Source', item.source),
                _row(context, 'Original filename', item.originalFileName),
                _row(context, 'File size', item.formattedSize),
                _row(context, 'SHA-256 hash', item.sha256Hash, monospace: true),
                _row(
                  context,
                  'Created',
                  AppFormatters.dateTime(item.createdAt),
                ),
                _row(
                  context,
                  'Related incident',
                  relatedIncident.isEmpty
                      ? 'None'
                      : relatedIncident.first.category.label,
                ),
              ],
            ),
          ),

          if (item.extractedData?.hasAnyData ?? false) ...[
            const SizedBox(height: Spacing.lg),
            RakshakCard(
              color: theme.colorScheme.tertiaryContainer,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Extracted from evidence — please verify',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onTertiaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: Spacing.sm),
                  if (item.extractedData!.amount != null)
                    _row(
                      context,
                      'Amount',
                      item.extractedData!.amount!,
                      onTertiary: true,
                    ),
                  if (item.extractedData!.utr != null)
                    _row(
                      context,
                      'UTR',
                      item.extractedData!.utr!,
                      onTertiary: true,
                    ),
                  if (item.extractedData!.bankOrWallet != null)
                    _row(
                      context,
                      'Bank / wallet',
                      item.extractedData!.bankOrWallet!,
                      onTertiary: true,
                    ),
                  if (item.extractedData!.transactionDate != null)
                    _row(
                      context,
                      'Transaction date',
                      item.extractedData!.transactionDate!,
                      onTertiary: true,
                    ),
                  if (item.extractedData!.upiId != null)
                    _row(
                      context,
                      'UPI ID',
                      item.extractedData!.upiId!,
                      onTertiary: true,
                    ),
                ],
              ),
            ),
          ],

          if (item.description.isNotEmpty) ...[
            const SizedBox(height: Spacing.lg),
            const RakshakSectionHeader(title: 'Description'),
            Text(item.description, style: theme.textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }

  Widget _row(
    BuildContext context,
    String label,
    String value, {
    bool monospace = false,
    bool onTertiary = false,
  }) {
    final theme = Theme.of(context);
    final labelColor = onTertiary
        ? theme.colorScheme.onTertiaryContainer.withValues(alpha: 0.8)
        : theme.colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(color: labelColor),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: monospace ? 'monospace' : null,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
