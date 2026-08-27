import 'package:url_launcher/url_launcher.dart';

import '../services/system_actions_service.dart';

/// Opens a URL in the device's actual default/other browser — Rakshak
/// itself is never a candidate, so this can safely be called from a
/// screen the user reached via an incoming link without ever routing
/// back into Rakshak (see `SystemActionsService.openExternalBrowser` and
/// the native exclude-self logic in `MainActivity.kt`).
///
/// Never hardcodes Chrome or any specific browser — the user's configured
/// default (or an explicit chooser excluding Rakshak) handles the URL via
/// Android's normal `ACTION_VIEW` mechanism.
class BrowserLauncher {
  const BrowserLauncher._();

  static final SystemActionsService _systemActions =
      const SystemActionsService();

  static Future<bool> openExternally(String url) async {
    final handledNatively = await _systemActions.openExternalBrowser(url);
    if (handledNatively) return true;

    // Non-Android platforms (or a native-channel failure): fall back to
    // url_launcher's standard external-application mode.
    final uri = Uri.parse(url);
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
