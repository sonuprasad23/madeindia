import 'package:crypto/crypto.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/utils/browser_launcher.dart';
import '../../../core/widgets/rakshak_button.dart';
import '../../../core/widgets/rakshak_status.dart';
import '../../../data/models/evidence_item.dart';
import '../../../data/models/link_check_result.dart';
import '../../../data/models/notification_item.dart';
import '../../../data/models/risk_level.dart';
import '../../../data/repositories/evidence_repository.dart';
import '../../../data/repositories/notification_repository.dart';

class LinkResultScreen extends ConsumerWidget {
  const LinkResultScreen({super.key, required this.result});

  final LinkCheckResult result;

  Future<void> _openExternally(BuildContext context) async {
    final ok = await BrowserLauncher.openExternally(result.normalizedUrl);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open a browser for this link.'),
        ),
      );
    }
  }

  Future<void> _saveAsEvidence(BuildContext context, WidgetRef ref) async {
    final bytes = utf8.encode(result.normalizedUrl);
    final hash = sha256.convert(bytes).toString();
    final item = EvidenceItem(
      id: const Uuid().v4(),
      type: EvidenceType.url,
      category: EvidenceCategory.websites,
      source: 'Link Checker result',
      createdAt: DateTime.now(),
      originalFileName: result.domain,
      fileSizeBytes: bytes.length,
      sha256Hash: hash,
      textContent: result.normalizedUrl,
      description: '${result.riskLevel.shortLabel} link check result',
    );
    await ref.read(evidenceRepositoryProvider.notifier).add(item);
    await ref
        .read(notificationRepositoryProvider.notifier)
        .push(
          kind: NotificationKind.evidenceSaved,
          title: 'Evidence saved',
          body: '${result.domain} was saved to your Evidence Vault.',
        );
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Saved to Evidence Vault')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final color = result.riskLevel.color(brightness);

    return Scaffold(
      appBar: AppBar(title: const Text('Link Check Result')),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.lg),
        children: [
          Center(child: RakshakRiskBadge(level: result.riskLevel)),
          const SizedBox(height: Spacing.xl),
          _detailRow(context, 'Domain', result.domain),
          _detailRow(
            context,
            'HTTPS',
            result.isHttps ? '✓ Present' : '✗ Not present',
          ),
          _detailRow(context, 'Risk score', '${result.riskScore} / 100'),
          _detailRow(context, 'Checked', 'Just now'),
          const SizedBox(height: Spacing.xl),

          if (result.negativeIndicators.isNotEmpty) ...[
            Text(
              'Why was this flagged?',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: Spacing.sm),
            ...result.negativeIndicators.map(
              (i) => _IndicatorRow(indicator: i, color: color),
            ),
            const SizedBox(height: Spacing.lg),
          ],
          if (result.positiveIndicators.isNotEmpty) ...[
            Text(
              'Reassuring signals',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: Spacing.sm),
            ...result.positiveIndicators.map(
              (i) => _IndicatorRow(
                indicator: i,
                color: theme.colorScheme.tertiary,
              ),
            ),
            const SizedBox(height: Spacing.lg),
          ],

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
                    '${AppConstants.demoThreatIntelLabel} — for demonstration purposes only.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.xl),
          ..._actionsFor(context, ref),
          const SizedBox(height: Spacing.md),
          RakshakButton(
            label: 'Save as Evidence',
            icon: Icons.bookmark_add_outlined,
            variant: RakshakButtonVariant.text,
            onPressed: () => _saveAsEvidence(context, ref),
          ),
        ],
      ),
    );
  }

  List<Widget> _actionsFor(BuildContext context, WidgetRef ref) {
    void viewSafely() => context.push(AppRoutes.safeViewer, extra: result);

    switch (result.riskLevel) {
      case RiskLevel.safe:
        return [
          RakshakButton(
            label: 'Open in Chrome',
            icon: Icons.open_in_new_rounded,
            onPressed: () => _openExternally(context),
          ),
          const SizedBox(height: Spacing.sm),
          RakshakButton(
            label: 'View Safely',
            icon: Icons.visibility_outlined,
            variant: RakshakButtonVariant.secondary,
            onPressed: viewSafely,
          ),
        ];
      case RiskLevel.suspicious:
        return [
          RakshakButton(
            label: 'View Safely',
            icon: Icons.visibility_outlined,
            onPressed: viewSafely,
          ),
          const SizedBox(height: Spacing.sm),
          RakshakButton(
            label: 'Open Anyway',
            icon: Icons.warning_amber_rounded,
            variant: RakshakButtonVariant.secondary,
            onPressed: () => _confirmAndOpen(context),
          ),
          const SizedBox(height: Spacing.sm),
          RakshakButton(
            label: "Don't Open",
            variant: RakshakButtonVariant.text,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ];
      case RiskLevel.dangerous:
        return [
          RakshakButton(
            label: 'View Safely',
            icon: Icons.visibility_outlined,
            onPressed: viewSafely,
          ),
          const SizedBox(height: Spacing.sm),
          RakshakButton(
            label: 'Go Back',
            variant: RakshakButtonVariant.secondary,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ];
      case RiskLevel.unknown:
        return [
          RakshakButton(
            label: 'View Safely',
            icon: Icons.visibility_outlined,
            onPressed: viewSafely,
          ),
          const SizedBox(height: Spacing.sm),
          RakshakButton(
            label: 'Open',
            variant: RakshakButtonVariant.secondary,
            onPressed: () => _openExternally(context),
          ),
        ];
    }
  }

  Future<void> _confirmAndOpen(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Open this link?'),
        content: const Text(
          'This link has suspicious indicators. Opening it may expose you to a phishing or scam page. Continue at your own risk.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Open Anyway'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await _openExternally(context);
    }
  }

  Widget _detailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _IndicatorRow extends StatelessWidget {
  const _IndicatorRow({required this.indicator, required this.color});

  final ThreatIndicator indicator;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            indicator.isPositive
                ? Icons.check_circle_outline
                : Icons.error_outline,
            size: 18,
            color: color,
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  indicator.label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  indicator.detail,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
