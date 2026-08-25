import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/design_tokens.dart';
import '../../../core/widgets/rakshak_surfaces.dart';
import '../../../data/repositories/admin_repository.dart';

/// Scam-awareness articles. Content is admin-managed (see Admin > Content)
/// so this list reflects whatever the admin has published, rather than
/// being hardcoded in the UI.
class AwarenessScreen extends ConsumerWidget {
  const AwarenessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articles = ref
        .watch(contentArticleRepositoryProvider)
        .where((a) => a.published)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Scam Awareness')),
      body: ListView.separated(
        padding: const EdgeInsets.all(Spacing.lg),
        itemCount: articles.length,
        separatorBuilder: (_, _) => const SizedBox(height: Spacing.md),
        itemBuilder: (context, index) {
          final article = articles[index];
          return RakshakCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.category,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  article.title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: Spacing.sm),
                Text(
                  article.body,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
