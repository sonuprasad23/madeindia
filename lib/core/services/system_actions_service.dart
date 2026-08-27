import 'package:flutter/services.dart';

/// Outcome of [SystemActionsService.requestBrowserRole].
enum BrowserRoleOutcome {
  /// The user accepted the system prompt — Rakshak is now the default
  /// browser and every generic http/https link will route to it.
  granted,

  /// The user declined the system prompt.
  declined,

  /// Rakshak already held the role before asking.
  alreadyDefault,

  /// The role request isn't available on this device/Android version
  /// (below Android 10, or the OEM doesn't expose it) — the native side
  /// falls back to opening the "Open by default" Settings screen instead.
  unavailable,

  /// The platform channel itself wasn't reachable (non-Android platform).
  unsupportedPlatform,
}

/// Dart side of the native Android system-actions bridge in
/// `MainActivity.kt`: launching a URL in some OTHER app (never Rakshak
/// itself — see [openExternalBrowser]), requesting Android's "Default
/// Browser" role (the mechanism that actually makes every tapped link
/// route to Rakshak — see [requestBrowserRole]), and a settings-screen
/// fallback for devices where that role isn't available.
///
/// No-op (returns a "not supported" outcome) on platforms other than
/// Android — callers should fall back to a cross-platform mechanism (see
/// `BrowserLauncher`).
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

  /// Requests Android's "Default Browser" role directly via a system
  /// dialog — this is the mechanism that actually makes every tapped
  /// http/https link route to Rakshak, and does NOT require owning a
  /// domain (unlike Android's separate, unrelated "App Links" / "Open
  /// supported links" screen, which only ever applies to domains an app
  /// has verified ownership of).
  Future<BrowserRoleOutcome> requestBrowserRole() async {
    try {
      final result = await _channel.invokeMethod<String>('requestBrowserRole');
      return switch (result) {
        'granted' => BrowserRoleOutcome.granted,
        'declined' => BrowserRoleOutcome.declined,
        'already_default' => BrowserRoleOutcome.alreadyDefault,
        _ => BrowserRoleOutcome.unavailable,
      };
    } on MissingPluginException {
      return BrowserRoleOutcome.unsupportedPlatform;
    } on PlatformException {
      return BrowserRoleOutcome.unsupportedPlatform;
    }
  }

  /// Reports whether Rakshak currently holds the Default Browser role —
  /// a pure status check with no system dialog, so Settings can show
  /// "Rakshak is your default browser" without re-asking. False on
  /// non-Android platforms, API < 29, or if the role isn't exposed.
  Future<bool> isDefaultBrowser() async {
    try {
      final result = await _channel.invokeMethod<bool>('isDefaultBrowser');
      return result ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  /// Opens the Android Settings screen for managing which app opens links
  /// by default (API 31+), falling back to the app-info screen on older
  /// versions. Returns false on non-Android platforms. Kept as a manual
  /// escape hatch — [requestBrowserRole] is the primary, recommended path.
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
