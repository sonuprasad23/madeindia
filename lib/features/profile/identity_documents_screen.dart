import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/widgets/rakshak_states.dart';
import '../../core/widgets/rakshak_surfaces.dart';
import '../../data/models/citizen_profile.dart';
import '../../data/repositories/citizen_profile_repository.dart';

class IdentityDocumentsScreen extends ConsumerWidget {
  const IdentityDocumentsScreen({super.key});

  Future<void> _addDocument(BuildContext context, WidgetRef ref) async {
    final type = await showModalBottomSheet<IdentityDocumentType>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: IdentityDocumentType.values
              .map(
                (t) => ListTile(
                  title: Text(t.label),
                  onTap: () => Navigator.of(context).pop(t),
                ),
              )
              .toList(),
        ),
      ),
    );
    if (type == null) return;

    final result = await FilePicker.pickFiles(type: FileType.image);
    final path = (result == null || result.files.isEmpty)
        ? null
        : result.files.first.path;
    if (path == null) return;

    final profile = ref.read(citizenProfileProvider);
    final updated = [
      ...profile.identityDocuments.where((d) => d.type != type),
      IdentityDocument(
        type: type,
        source: DocumentSource.userProvided,
        filePath: path,
      ),
    ];
    await ref
        .read(citizenProfileProvider.notifier)
        .update((p) => p.copyWith(identityDocuments: updated));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(citizenProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Identity Documents'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _addDocument(context, ref),
          ),
        ],
      ),
      body: profile.identityDocuments.isEmpty
          ? RakshakEmptyState(
              title: 'No documents added',
              message:
                  'Add Aadhaar, PAN, or another ID document. This stays on your device in this demo.',
              icon: Icons.badge_outlined,
              actionLabel: 'Add document',
              onAction: () => _addDocument(context, ref),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(Spacing.lg),
              itemCount: profile.identityDocuments.length + 1,
              separatorBuilder: (_, _) => const SizedBox(height: Spacing.md),
              itemBuilder: (context, index) {
                if (index == profile.identityDocuments.length) {
                  return RakshakCard(
                    child: Row(
                      children: [
                        const Icon(Icons.cloud_outlined),
                        const SizedBox(width: Spacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'DigiLocker',
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              Text(
                                'Not connected in this demo — see Admin > Settings for the integration boundary.',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
                final doc = profile.identityDocuments[index];
                return RakshakCard(
                  child: Row(
                    children: [
                      if (doc.filePath != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(Radii.sm),
                          child: Image.file(
                            File(doc.filePath!),
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        const Icon(Icons.badge_outlined),
                      const SizedBox(width: Spacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doc.type.label,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              '${doc.sourceLabel} • ${doc.verificationLabel}',
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
