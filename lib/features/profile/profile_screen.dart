import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/app_routes.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/rakshak_surfaces.dart';
import '../../data/models/citizen_profile.dart';
import '../../data/repositories/citizen_profile_repository.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(citizenProfileProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.lg),
        children: [
          Row(
            children: [
              RakshakAvatar(name: profile.name, radius: 32),
              const SizedBox(width: Spacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      profile.mobile,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => context.push(AppRoutes.citizenProfileEdit),
              ),
            ],
          ),
          const SizedBox(height: Spacing.xl),

          if (profile.jurisdiction != null)
            _jurisdictionCard(context, ref, profile.jurisdiction!),
          const SizedBox(height: Spacing.md),

          _tile(
            context,
            Icons.badge_outlined,
            'Identity Documents',
            'Aadhaar, PAN, and other ID documents',
            () => context.push(AppRoutes.identityDocuments),
          ),
          const SizedBox(height: Spacing.md),
          _tile(
            context,
            Icons.alternate_email_rounded,
            'Social Identities',
            'Accounts you have added for reference',
            () => context.push(AppRoutes.socialIdentities),
          ),
          const SizedBox(height: Spacing.md),
          _tile(
            context,
            Icons.settings_outlined,
            'Settings',
            'Appearance, language, and app preferences',
            () => context.push(AppRoutes.settings),
          ),
          const SizedBox(height: Spacing.xxl),

          Center(
            child: TextButton(
              onPressed: () => context.push(AppRoutes.adminLogin),
              child: Text(
                'Admin access',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _jurisdictionCard(
    BuildContext context,
    WidgetRef ref,
    JurisdictionInfo jurisdiction,
  ) {
    final theme = Theme.of(context);
    final confirmed =
        jurisdiction.status == JurisdictionConfirmationStatus.confirmed;
    return RakshakCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Suggested jurisdiction',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            jurisdiction.source,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            jurisdiction.suggestedPoliceStation,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            'Based on your registered address — not your current location, '
            'and not an official jurisdiction determination.',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Spacing.md),
          if (confirmed)
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 18,
                  color: theme.colorScheme.tertiary,
                ),
                const SizedBox(width: 6),
                const Text('Confirmed'),
              ],
            )
          else
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.tonal(
                onPressed: () => ref
                    .read(citizenProfileProvider.notifier)
                    .confirmJurisdiction(),
                child: const Text('Confirm'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _tile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    return RakshakCard(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}
