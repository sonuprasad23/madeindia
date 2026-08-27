import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/app_providers.dart';
import '../../core/services/system_actions_service.dart';
import '../../core/storage/local_storage_service.dart';

/// Whether Rakshak currently holds Android's "Default Browser" role — the
/// mechanism that actually routes every tapped http/https link to it (see
/// [SystemActionsService]). `null` means not checked yet.
class BrowserRoleController extends Notifier<bool?> {
  final SystemActionsService _systemActions = const SystemActionsService();

  @override
  bool? build() {
    // Kick off an initial status check without blocking first build —
    // Settings (and anything else watching this) updates once it resolves.
    Future.microtask(refresh);
    return null;
  }

  Future<void> refresh() async {
    state = await _systemActions.isDefaultBrowser();
  }

  Future<BrowserRoleOutcome> requestRole() async {
    final outcome = await _systemActions.requestBrowserRole();
    await refresh();
    return outcome;
  }

  /// Runs once ever, on the very first launch after install: proactively
  /// offers Android's "Set Rakshak as your Browser app?" system dialog.
  /// The app continues normally regardless of the outcome (granted,
  /// declined, or unavailable) — this never blocks navigation and is
  /// never shown again after this first run.
  Future<void> maybePromptOnFirstLaunch() async {
    final storage = ref.read(localStorageProvider);
    final alreadyPrompted =
        storage.getBool(StorageKeys.hasPromptedBrowserRoleOnFirstLaunch) ??
        false;
    if (alreadyPrompted) return;

    await storage.setBool(
      StorageKeys.hasPromptedBrowserRoleOnFirstLaunch,
      true,
    );
    await requestRole();
  }
}

final browserRoleControllerProvider =
    NotifierProvider<BrowserRoleController, bool?>(BrowserRoleController.new);
