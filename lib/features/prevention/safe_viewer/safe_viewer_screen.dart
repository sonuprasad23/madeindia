import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/theme/design_tokens.dart';
import '../../../core/utils/browser_launcher.dart';
import '../../../core/utils/widget_screenshot.dart';
import '../../../core/widgets/rakshak_button.dart';
import '../../../core/widgets/rakshak_status.dart';
import '../../../data/models/evidence_item.dart';
import '../../../data/models/link_check_result.dart';
import '../../../data/models/notification_item.dart';
import '../../../data/models/risk_level.dart';
import '../../../data/repositories/evidence_repository.dart';
import '../../../data/repositories/notification_repository.dart';

/// Demo Safe Viewer: loads a page inside an in-app WebView so the user
/// doesn't have to open a suspicious link in their everyday browser
/// (which carries their real cookies/session/autofill data).
///
/// This is explicitly labelled a DEMO implementation — it is not full
/// remote browser isolation (no disposable remote browser, no network
/// isolation). [LinkAnalysisService]-style abstraction means a future
/// version could swap this screen's rendering for a real isolated remote
/// session without changing how the rest of the app calls into it.
class SafeViewerScreen extends ConsumerStatefulWidget {
  const SafeViewerScreen({super.key, required this.result});

  final LinkCheckResult result;

  @override
  ConsumerState<SafeViewerScreen> createState() => _SafeViewerScreenState();
}

class _SafeViewerScreenState extends ConsumerState<SafeViewerScreen> {
  final GlobalKey _repaintKey = GlobalKey();
  late final WebViewController _controller;
  String _currentUrl = '';
  bool _isLoading = true;
  bool _loadFailed = false;
  bool _confirmedEntry = false;

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.result.normalizedUrl;
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) => setState(() {
            _currentUrl = url;
            _isLoading = true;
          }),
          onPageFinished: (url) => setState(() {
            _currentUrl = url;
            _isLoading = false;
          }),
          onWebResourceError: (_) => setState(() {
            _isLoading = false;
            _loadFailed = true;
          }),
        ),
      );

    // Dangerous/suspicious links require an explicit tap-through before
    // any content loads at all, on top of already being sandboxed here.
    _confirmedEntry =
        widget.result.riskLevel == RiskLevel.safe ||
        widget.result.riskLevel == RiskLevel.unknown;
    if (_confirmedEntry) {
      _controller.loadRequest(Uri.parse(widget.result.normalizedUrl));
    }
  }

  void _confirmAndLoad() {
    setState(() => _confirmedEntry = true);
    _controller.loadRequest(Uri.parse(widget.result.normalizedUrl));
  }

  Future<void> _saveSnapshotAsEvidence() async {
    final bytes = await captureRepaintBoundary(_repaintKey);
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);

    if (bytes == null) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Could not capture a visual snapshot on this device — saving the page URL instead.',
          ),
        ),
      );
      await _saveUrlOnlyEvidence();
      return;
    }

    try {
      final dir = await getApplicationDocumentsDirectory();
      final fileName =
          'safe_viewer_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${dir.path}/evidence/$fileName');
      await file.create(recursive: true);
      await file.writeAsBytes(bytes);

      final hash = sha256.convert(bytes).toString();
      final item = EvidenceItem(
        id: const Uuid().v4(),
        type: EvidenceType.image,
        category: EvidenceCategory.websites,
        source: 'Safe Viewer snapshot',
        createdAt: DateTime.now(),
        originalFileName: fileName,
        fileSizeBytes: bytes.length,
        sha256Hash: hash,
        filePath: file.path,
        description: 'Snapshot of $_currentUrl',
      );
      await ref.read(evidenceRepositoryProvider.notifier).add(item);
      await ref
          .read(notificationRepositoryProvider.notifier)
          .push(
            kind: NotificationKind.evidenceSaved,
            title: 'Evidence saved',
            body: 'A Safe Viewer snapshot was added to your Evidence Vault.',
          );
      messenger.showSnackBar(
        const SnackBar(content: Text('Snapshot saved to Evidence Vault')),
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Could not save the snapshot. Please try again.'),
        ),
      );
    }
  }

  Future<void> _saveUrlOnlyEvidence() async {
    final bytes = _currentUrl.codeUnits;
    final hash = sha256.convert(bytes).toString();
    final item = EvidenceItem(
      id: const Uuid().v4(),
      type: EvidenceType.url,
      category: EvidenceCategory.websites,
      source: 'Safe Viewer',
      createdAt: DateTime.now(),
      originalFileName: widget.result.domain,
      fileSizeBytes: bytes.length,
      sha256Hash: hash,
      textContent: _currentUrl,
    );
    await ref.read(evidenceRepositoryProvider.notifier).add(item);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Safe Viewer'),
        actions: [
          IconButton(
            tooltip: 'Open in Chrome instead',
            icon: const Icon(Icons.open_in_new_rounded),
            onPressed: () =>
                BrowserLauncher.openExternally(widget.result.normalizedUrl),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(Spacing.lg),
            color: theme.colorScheme.surfaceContainerHigh,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    RakshakRiskBadge(
                      level: widget.result.riskLevel,
                      dense: true,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(Radii.pill),
                      ),
                      child: Text(
                        'Demo Safe Viewer',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.sm),
                _urlRow(context, 'Original URL', widget.result.originalUrl),
                _urlRow(context, 'Final URL', _currentUrl),
                const SizedBox(height: Spacing.xs),
                Text(
                  'This page is loaded inside an isolated in-app view. This is a demo implementation, not full remote browser isolation — a future version could route this through a disposable remote browser with no access to your personal session data.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: !_confirmedEntry
                ? _buildGate(context)
                : RepaintBoundary(
                    key: _repaintKey,
                    child: Stack(
                      children: [
                        WebViewWidget(controller: _controller),
                        if (_isLoading) const LinearProgressIndicator(),
                        if (_loadFailed)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(Spacing.xl),
                              child: Text(
                                'This page could not be loaded inside the Safe Viewer.',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
          ),
          if (_confirmedEntry)
            Padding(
              padding: const EdgeInsets.all(Spacing.lg),
              child: RakshakButton(
                label: 'Save page as Evidence',
                icon: Icons.camera_alt_outlined,
                variant: RakshakButtonVariant.secondary,
                onPressed: _saveSnapshotAsEvidence,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGate(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.security_rounded,
              size: 48,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: Spacing.lg),
            Text(
              'This link was flagged as ${widget.result.riskLevel.shortLabel.toLowerCase()}. '
              'Continue only if you understand the risk.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: Spacing.lg),
            RakshakButton(
              label: 'Continue to Safe Viewer',
              onPressed: _confirmAndLoad,
              expand: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _urlRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          style: theme.textTheme.bodySmall,
          children: [
            TextSpan(
              text: '$label: ',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
