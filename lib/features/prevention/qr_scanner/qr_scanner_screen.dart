import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/design_tokens.dart';
import 'qr_payload_parser.dart';
import 'upi_verify_sheet.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDetect(BarcodeCapture capture) {
    if (_handled) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null || raw.isEmpty) return;

    _handled = true;
    final payload = QrPayloadParser.parse(raw);

    switch (payload.kind) {
      case QrPayloadKind.url:
        context
            .push(AppRoutes.linkChecker, extra: payload.raw)
            .then((_) => _handled = false);
      case QrPayloadKind.upi:
        showUpiVerifySheet(context, payload.upi!).then((_) => _handled = false);
      case QrPayloadKind.text:
        _showTextResult(payload.raw);
    }
  }

  void _showTextResult(String text) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR code content'),
        content: SelectableText(text),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() => _handled = false);
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR'),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, state, child) {
                return Icon(
                  state.torchState == TorchState.on
                      ? Icons.flash_on_rounded
                      : Icons.flash_off_rounded,
                );
              },
            ),
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(controller: _controller, onDetect: _handleDetect),
          Center(
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.8),
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(Radii.lg),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 32,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.xl),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.lg,
                      vertical: Spacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(Radii.pill),
                    ),
                    child: const Text(
                      'Point your camera at a QR code',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.linkChecker),
        icon: const Icon(Icons.keyboard_outlined),
        label: const Text('Enter manually'),
      ),
    );
  }
}

extension _FirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
