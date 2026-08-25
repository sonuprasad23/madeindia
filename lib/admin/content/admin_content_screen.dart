import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/widgets/rakshak_button.dart';
import '../../core/widgets/rakshak_inputs.dart';
import '../../core/widgets/rakshak_surfaces.dart';
import '../../data/models/admin_models.dart';
import '../../data/repositories/admin_repository.dart';

class AdminContentScreen extends ConsumerWidget {
  const AdminContentScreen({super.key});

  Future<void> _editArticle(
    BuildContext context,
    WidgetRef ref, {
    ContentArticle? existing,
  }) async {
    final title = TextEditingController(text: existing?.title ?? '');
    final category = TextEditingController(
      text: existing?.category ?? 'General',
    );
    final body = TextEditingController(text: existing?.body ?? '');

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existing == null ? 'New article' : 'Edit article'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RakshakTextField(label: 'Title', controller: title),
              const SizedBox(height: Spacing.lg),
              RakshakTextField(label: 'Category', controller: category),
              const SizedBox(height: Spacing.lg),
              RakshakTextField(label: 'Body', controller: body, maxLines: 5),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (title.text.trim().isEmpty) return;
              ref
                  .read(contentArticleRepositoryProvider.notifier)
                  .upsert(
                    ContentArticle(
                      id: existing?.id ?? const Uuid().v4(),
                      title: title.text.trim(),
                      category: category.text.trim(),
                      body: body.text.trim(),
                      languageCode: 'en',
                      updatedAt: DateTime.now(),
                      published: existing?.published ?? true,
                    ),
                  );
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articles = ref.watch(contentArticleRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Content'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: RakshakButton(
                label: 'New article',
                icon: Icons.add_rounded,
                expand: false,
                onPressed: () => _editArticle(context, ref),
              ),
            ),
            const SizedBox(height: Spacing.lg),
            Expanded(
              child: ListView.separated(
                itemCount: articles.length,
                separatorBuilder: (_, _) => const SizedBox(height: Spacing.md),
                itemBuilder: (context, index) {
                  final a = articles[index];
                  return RakshakCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                a.category,
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                              ),
                              Text(
                                a.title,
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: a.published,
                          onChanged: (v) => ref
                              .read(contentArticleRepositoryProvider.notifier)
                              .upsert(
                                ContentArticle(
                                  id: a.id,
                                  title: a.title,
                                  category: a.category,
                                  body: a.body,
                                  languageCode: a.languageCode,
                                  updatedAt: DateTime.now(),
                                  published: v,
                                ),
                              ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () =>
                              _editArticle(context, ref, existing: a),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded),
                          onPressed: () => ref
                              .read(contentArticleRepositoryProvider.notifier)
                              .remove(a.id),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
