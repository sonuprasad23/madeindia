import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/branding/brand_config.dart';
import '../../core/services/feature_flags_controller.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/rakshak_surfaces.dart';
import '../../data/repositories/admin_repository.dart';

class AdminSettingsScreen extends ConsumerWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flags = ref.watch(featureFlagsProvider);
    final thresholds = ref.watch(riskThresholdsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.lg),
        children: [
          const RakshakSectionHeader(title: 'Feature flags'),
          RakshakCard(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Safe Link Viewer'),
                  value: flags.safeLinkViewer,
                  onChanged: (v) => ref
                      .read(featureFlagsProvider.notifier)
                      .update((f) => f.copyWith(safeLinkViewer: v)),
                ),
                SwitchListTile(
                  title: const Text('QR Scanner'),
                  value: flags.qrScanner,
                  onChanged: (v) => ref
                      .read(featureFlagsProvider.notifier)
                      .update((f) => f.copyWith(qrScanner: v)),
                ),
                SwitchListTile(
                  title: const Text('AI Assistant'),
                  value: flags.aiAssistant,
                  onChanged: (v) => ref
                      .read(featureFlagsProvider.notifier)
                      .update((f) => f.copyWith(aiAssistant: v)),
                ),
                SwitchListTile(
                  title: const Text('DigiLocker'),
                  subtitle: const Text(
                    'Not implemented in this demo — placeholder integration boundary only.',
                  ),
                  value: flags.digiLocker,
                  onChanged: (v) => ref
                      .read(featureFlagsProvider.notifier)
                      .update((f) => f.copyWith(digiLocker: v)),
                ),
                SwitchListTile(
                  title: const Text('Real Threat Intelligence'),
                  subtitle: const Text(
                    'Would replace the demo domain list with a live feed.',
                  ),
                  value: flags.realThreatIntelligence,
                  onChanged: (v) => ref
                      .read(featureFlagsProvider.notifier)
                      .update((f) => f.copyWith(realThreatIntelligence: v)),
                ),
                SwitchListTile(
                  title: const Text('Government API Integration'),
                  subtitle: const Text(
                    'Would route complaint submission to a real NCRP-equivalent API.',
                  ),
                  value: flags.governmentApiIntegration,
                  onChanged: (v) => ref
                      .read(featureFlagsProvider.notifier)
                      .update((f) => f.copyWith(governmentApiIntegration: v)),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.xl),

          const RakshakSectionHeader(title: 'Link checker risk thresholds'),
          RakshakCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Suspicious at score ≥ ${thresholds.suspiciousAt}',
                  style: theme.textTheme.bodyMedium,
                ),
                Slider(
                  value: thresholds.suspiciousAt.toDouble(),
                  min: 10,
                  max: 60,
                  divisions: 50,
                  onChanged: (v) => ref
                      .read(riskThresholdsProvider.notifier)
                      .update(suspiciousAt: v.round()),
                ),
                const SizedBox(height: Spacing.md),
                Text(
                  'Dangerous at score ≥ ${thresholds.dangerousAt}',
                  style: theme.textTheme.bodyMedium,
                ),
                Slider(
                  value: thresholds.dangerousAt.toDouble(),
                  min: 40,
                  max: 100,
                  divisions: 60,
                  onChanged: (v) => ref
                      .read(riskThresholdsProvider.notifier)
                      .update(dangerousAt: v.round()),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.xl),

          const RakshakSectionHeader(title: 'Branding'),
          RakshakCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'App name: ${BrandConfig.appName}',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Logo assets and brand colors are defined in BrandConfig and can be replaced without touching '
                  'feature code. A future admin build could expose file upload for these directly.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
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
