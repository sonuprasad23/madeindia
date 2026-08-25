import 'package:url_launcher/url_launcher.dart';

/// Thin wrapper around `url_launcher` so the "Open in Chrome" / "Open
/// Anyway" actions genuinely hand off to the device's default browser via
/// Android's normal URL intent mechanism — this is never faked.
class BrowserLauncher {
  const BrowserLauncher._();

  static Future<bool> openExternally(String url) async {
    final uri = Uri.parse(url);
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
