import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/widgets/rakshak_button.dart';
import '../../../data/repositories/link_repository.dart';
import 'link_analysis_service.dart';
import 'link_checker_providers.dart';

/// Entry point for URL analysis — accepts a pasted/typed URL, a URL shared
/// in from another app (via [initialUrl]), or a re-check from history.
class LinkCheckerScreen extends ConsumerStatefulWidget {
  const LinkCheckerScreen({super.key, this.initialUrl});

  final String? initialUrl;

  @override
  ConsumerState<LinkCheckerScreen> createState() => _LinkCheckerScreenState();
}

class _LinkCheckerScreenState extends ConsumerState<LinkCheckerScreen> {
  late final TextEditingController _controller;
  bool _isChecking = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialUrl ?? '');
    if (widget.initialUrl != null && widget.initialUrl!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _check());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      setState(() => _controller.text = data!.text!);
    }
  }

  Future<void> _check() async {
    final input = _controller.text.trim();
    if (input.isEmpty) return;

    setState(() {
      _isChecking = true;
      _error = null;
    });

    final service = ref.read(linkAnalysisServiceProvider);
    try {
      final result = await service.checkUrl(input);
      await ref.read(linkRepositoryProvider.notifier).record(result);
      if (!mounted) return;
      context.push(AppRoutes.linkCheckerResult, extra: result);
    } on UnparseableUrlException {
      setState(
        () => _error =
            'Could not interpret that as a URL. Try including "https://".',
      );
    } catch (_) {
      setState(
        () => _error = 'The security service is temporarily unavailable.',
      );
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Check Link')),
      body: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Paste or type a link to check it for known threats.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Spacing.lg),
            TextField(
              controller: _controller,
              autofocus: widget.initialUrl == null,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.go,
              onSubmitted: (_) => _check(),
              decoration: InputDecoration(
                labelText: 'URL',
                hintText: 'example.com or https://example.com/page',
                errorText: _error,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.content_paste_rounded),
                  tooltip: 'Paste from clipboard',
                  onPressed: _pasteFromClipboard,
                ),
              ),
            ),
            const SizedBox(height: Spacing.lg),
            RakshakButton(
              label: 'Check Link',
              icon: Icons.search_rounded,
              isLoading: _isChecking,
              onPressed: _check,
            ),
            const SizedBox(height: Spacing.xl),
            Text(
              'Tip',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              'You can also share a link into Rakshak from Chrome, WhatsApp, or any other app using the "Share" option.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
