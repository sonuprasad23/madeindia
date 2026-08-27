import 'dart:async';

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

/// Launch arguments carrying both the URL and (when known) which app it
/// arrived from — used when routing here from the Link Security Gateway.
/// A plain `String` extra is also accepted for the simpler in-app cases
/// (QR scan results, manual re-checks) that have no source app to report.
class LinkCheckerLaunchArgs {
  const LinkCheckerLaunchArgs({required this.url, this.sourceApp});

  final String url;
  final String? sourceApp;
}

/// Steps shown while a check is in progress. Purely presentational —
/// the actual analysis is a single synchronous [LinkRiskEngine] pass; this
/// just paces the loading state so "Analyzing…" reads as real work being
/// done rather than an instant, un-demo-able flash.
const _analyzingSteps = [
  'Normalizing URL…',
  'Checking domain reputation…',
  'Analyzing URL structure…',
  'Compiling risk report…',
];

/// Entry point for URL analysis — accepts a pasted/typed URL, a URL shared
/// in from another app (via [initialUrl]), or a re-check from history.
class LinkCheckerScreen extends ConsumerStatefulWidget {
  const LinkCheckerScreen({super.key, this.initialUrl, this.sourceApp});

  final String? initialUrl;

  /// Best-effort friendly name of the app this URL arrived from, when
  /// known (see [LinkCheckerLaunchArgs]).
  final String? sourceApp;

  @override
  ConsumerState<LinkCheckerScreen> createState() => _LinkCheckerScreenState();
}

class _LinkCheckerScreenState extends ConsumerState<LinkCheckerScreen> {
  late final TextEditingController _controller;
  bool _isChecking = false;
  String? _error;
  int _analyzingStepIndex = 0;
  Timer? _analyzingTimer;

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
    _analyzingTimer?.cancel();
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
      _analyzingStepIndex = 0;
    });
    _analyzingTimer = Timer.periodic(const Duration(milliseconds: 450), (_) {
      if (!mounted) return;
      setState(() {
        if (_analyzingStepIndex < _analyzingSteps.length - 1) {
          _analyzingStepIndex++;
        }
      });
    });

    final service = ref.read(linkAnalysisServiceProvider);
    try {
      final result = await service.checkUrl(input, sourceApp: widget.sourceApp);
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
      _analyzingTimer?.cancel();
      if (mounted) setState(() => _isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Check Link')),
      body: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Paste or type a link to check it for known threats.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Spacing.lg),
            TextField(
              controller: _controller,
              enabled: !_isChecking,
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
                  onPressed: _isChecking ? null : _pasteFromClipboard,
                ),
              ),
            ),
            const SizedBox(height: Spacing.lg),
            RakshakButton(
              label: 'Check Link',
              icon: Icons.search_rounded,
              isLoading: _isChecking,
              onPressed: _isChecking ? null : _check,
            ),
            if (_isChecking) ...[
              const SizedBox(height: Spacing.lg),
              ClipRRect(
                borderRadius: BorderRadius.circular(Radii.pill),
                child: const LinearProgressIndicator(minHeight: 4),
              ),
              const SizedBox(height: Spacing.md),
              Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Text(
                      _analyzingSteps[_analyzingStepIndex],
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: Spacing.xl),
            Text(
              'Tip',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              'You can also share a link into Rakshak from Chrome, WhatsApp, or any other app using the "Share" option.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
