import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/widgets/rakshak_button.dart';
import '../../core/widgets/rakshak_inputs.dart';
import '../../core/widgets/rakshak_overlays.dart';
import '../../core/widgets/rakshak_states.dart';
import '../../core/widgets/rakshak_surfaces.dart';
import '../../data/models/citizen_profile.dart';
import '../../data/repositories/citizen_profile_repository.dart';

class SocialIdentitiesScreen extends ConsumerWidget {
  const SocialIdentitiesScreen({super.key});

  Future<void> _addIdentity(BuildContext context, WidgetRef ref) async {
    SocialPlatform platform = SocialPlatform.instagram;
    final username = TextEditingController();
    final profileUrl = TextEditingController();
    final notes = TextEditingController();

    await showRakshakBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add social identity',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: Spacing.lg),
              RakshakDropdown<SocialPlatform>(
                label: 'Platform',
                value: platform,
                items: SocialPlatform.values,
                itemLabel: (p) => p.label,
                onChanged: (p) => setSheetState(() => platform = p ?? platform),
              ),
              const SizedBox(height: Spacing.lg),
              RakshakTextField(label: 'Username', controller: username),
              const SizedBox(height: Spacing.lg),
              RakshakTextField(
                label: 'Profile URL (optional)',
                controller: profileUrl,
              ),
              const SizedBox(height: Spacing.lg),
              RakshakTextField(label: 'Notes (optional)', controller: notes),
              const SizedBox(height: Spacing.lg),
              RakshakButton(
                label: 'Add',
                onPressed: () async {
                  if (username.text.trim().isEmpty) return;
                  final profile = ref.read(citizenProfileProvider);
                  final updated = [
                    ...profile.socialIdentities,
                    SocialIdentity(
                      platform: platform,
                      username: username.text.trim(),
                      profileUrl: profileUrl.text.trim().isEmpty
                          ? null
                          : profileUrl.text.trim(),
                      notes: notes.text.trim(),
                    ),
                  ];
                  await ref
                      .read(citizenProfileProvider.notifier)
                      .update((p) => p.copyWith(socialIdentities: updated));
                  if (context.mounted) Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(citizenProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Social Identities'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _addIdentity(context, ref),
          ),
        ],
      ),
      body: profile.socialIdentities.isEmpty
          ? RakshakEmptyState(
              title: 'No social identities added',
              message:
                  'Add accounts you control so incident forms can reference them. Rakshak does not monitor your accounts.',
              icon: Icons.alternate_email_rounded,
              actionLabel: 'Add identity',
              onAction: () => _addIdentity(context, ref),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(Spacing.lg),
              itemCount: profile.socialIdentities.length,
              separatorBuilder: (_, _) => const SizedBox(height: Spacing.md),
              itemBuilder: (context, index) {
                final s = profile.socialIdentities[index];
                return RakshakCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.platform.label,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                            ),
                            Text(
                              s.username,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            if (s.notes.isNotEmpty)
                              Text(
                                s.notes,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
