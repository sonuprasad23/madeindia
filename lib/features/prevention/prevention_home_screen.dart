import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/app_routes.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/rakshak_surfaces.dart';
import '../../data/repositories/admin_repository.dart';
import '../../data/models/risk_level.dart';
import 'protection_settings_controller.dart';

class PreventionHomeScreen extends ConsumerWidget {
  const PreventionHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final protection = ref.watch(protectionSettingsProvider);
    final threatDomains = ref.watch(threatDomainRepositoryProvider);
    final dangerousCount = threatDomains
        .where((d) => d.status == RiskLevel.dangerous)
        .length;

    return Scaffold(
      appBar: AppBar(title: const Text('Protect')),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.lg),
        children: [
          RakshakCard(
            onTap: () => context.push(AppRoutes.linkChecker),
            child: const _Tile(
              icon: Icons.link_rounded,
              title: 'Link Checker',
              subtitle: 'Paste or share a URL to check it for known threats',
            ),
          ),
          const SizedBox(height: Spacing.md),
          RakshakCard(
            onTap: () => context.push(AppRoutes.qrScanner),
            child: const _Tile(
              icon: Icons.qr_code_scanner_rounded,
              title: 'QR Scanner',
              subtitle:
                  'Scan a QR code to check the link or UPI payment inside it',
            ),
          ),
          const SizedBox(height: Spacing.md),
          RakshakCard(
            onTap: () => context.push(AppRoutes.linkHistory),
            child: const _Tile(
              icon: Icons.history_rounded,
              title: 'Link History',
              subtitle: 'Review links you have checked previously',
            ),
          ),
          const SizedBox(height: Spacing.md),
          RakshakCard(
            child: _Tile(
              icon: Icons.shield_moon_outlined,
              title: 'Threat Reports',
              subtitle:
                  '$dangerousCount domains currently flagged as dangerous in demo threat intelligence',
            ),
          ),
          const SizedBox(height: Spacing.md),
          RakshakCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Tile(
                  icon: Icons.tune_rounded,
                  title: 'Protection Settings',
                  subtitle: 'Control how Rakshak checks and opens links',
                ),
                const SizedBox(height: Spacing.md),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Link protection'),
                  value: protection.linkProtectionEnabled,
                  onChanged: (v) => ref
                      .read(protectionSettingsProvider.notifier)
                      .setLinkProtection(v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Open suspicious links in Safe Viewer by default',
                  ),
                  value: protection.safeViewerDefaultOn,
                  onChanged: (v) => ref
                      .read(protectionSettingsProvider.notifier)
                      .setSafeViewerDefault(v),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.md),
          RakshakCard(
            onTap: () => context.push(AppRoutes.awareness),
            child: const _Tile(
              icon: Icons.menu_book_outlined,
              title: 'Scam Awareness',
              subtitle: 'Learn to recognize common scam patterns',
            ),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          foregroundColor: theme.colorScheme.onPrimaryContainer,
          child: Icon(icon),
        ),
        const SizedBox(width: Spacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
