import 'package:flutter/services.dart';

/// Dart side of the native Android system-actions bridge in
/// `MainActivity.kt`: launching a URL in some OTHER app (never Rakshak
/// itself — see [openExternalBrowser]) and deep-linking into the Android
/// Settings screen where a user can set Rakshak as their preferred link
/// handler.
///
/// No-op (returns false) on platforms other than Android — callers should
/// fall back to a cross-platform mechanism (see `BrowserLauncher`).
class SystemActionsService {
  const SystemActionsService([MethodChannel? channel])
    : _channel = channel ?? const MethodChannel('app.rakshak/system');

  final MethodChannel _channel;

  /// Opens [url] in whichever other app handles it, explicitly excluding
  /// Rakshak from consideration so this can never route straight back
  /// into the Link Security Gateway (the "intent loop" this feature must
  /// avoid). Returns false if the platform channel isn't available
  /// (non-Android) or the native call failed, so the caller can fall back.
  Future<bool> openExternalBrowser(String url) async {
    try {
      final result = await _channel.invokeMethod<bool>('openExternalBrowser', {
        'url': url,
      });
      return result ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  /// Opens the Android Settings screen for managing which app opens links
  /// by default (API 31+), falling back to the app-info screen on older
  /// versions. Returns false on non-Android platforms.
  Future<bool> openLinkHandlerSettings() async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'openLinkHandlerSettings',
      );
      return result ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }
}
