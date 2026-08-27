import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/app_providers.dart';
import '../../core/storage/local_storage_service.dart';

class ProtectionSettings {
  const ProtectionSettings({
    this.linkProtectionEnabled = true,
    this.safeViewerDefaultOn = false,
    this.warnAboutSuspiciousLinks = true,
    this.openSafeLinksAutomatically = false,
    this.showRiskExplanations = true,
  });

  final bool linkProtectionEnabled;
  final bool safeViewerDefaultOn;

  /// Shows an extra confirmation dialog before "Open Anyway" on a
  /// suspicious result. Turning this off never skips the tap itself —
  /// a suspicious/dangerous link is never opened without deliberate
  /// user action either way.
  final bool warnAboutSuspiciousLinks;

  /// When a checked link comes back "safe", opens it in the default
  /// browser automatically instead of waiting for a tap. Never applies
  /// to suspicious/dangerous/unknown results.
  final bool openSafeLinksAutomatically;

  /// Shows the "Why was this flagged?" / "Reassuring signals" sections on
  /// the result screen. Turning this off only hides the explanation —
  /// the risk badge and action buttons are always shown.
  final bool showRiskExplanations;

  ProtectionSettings copyWith({
    bool? linkProtectionEnabled,
    bool? safeViewerDefaultOn,
    bool? warnAboutSuspiciousLinks,
    bool? openSafeLinksAutomatically,
    bool? showRiskExplanations,
  }) => ProtectionSettings(
    linkProtectionEnabled: linkProtectionEnabled ?? this.linkProtectionEnabled,
    safeViewerDefaultOn: safeViewerDefaultOn ?? this.safeViewerDefaultOn,
    warnAboutSuspiciousLinks:
        warnAboutSuspiciousLinks ?? this.warnAboutSuspiciousLinks,
    openSafeLinksAutomatically:
        openSafeLinksAutomatically ?? this.openSafeLinksAutomatically,
    showRiskExplanations: showRiskExplanations ?? this.showRiskExplanations,
  );
}

class ProtectionSettingsController extends Notifier<ProtectionSettings> {
  @override
  ProtectionSettings build() {
    final storage = ref.read(localStorageProvider);
    return ProtectionSettings(
      linkProtectionEnabled:
          storage.getBool(StorageKeys.linkProtectionEnabled) ?? true,
      safeViewerDefaultOn:
          storage.getBool(StorageKeys.safeViewerDefault) ?? false,
      warnAboutSuspiciousLinks:
          storage.getBool(StorageKeys.warnAboutSuspiciousLinks) ?? true,
      openSafeLinksAutomatically:
          storage.getBool(StorageKeys.openSafeLinksAutomatically) ?? false,
      showRiskExplanations:
          storage.getBool(StorageKeys.showRiskExplanations) ?? true,
    );
  }

  Future<void> setLinkProtection(bool enabled) async {
    state = state.copyWith(linkProtectionEnabled: enabled);
    await ref
        .read(localStorageProvider)
        .setBool(StorageKeys.linkProtectionEnabled, enabled);
  }

  Future<void> setSafeViewerDefault(bool enabled) async {
    state = state.copyWith(safeViewerDefaultOn: enabled);
    await ref
        .read(localStorageProvider)
        .setBool(StorageKeys.safeViewerDefault, enabled);
  }

  Future<void> setWarnAboutSuspiciousLinks(bool enabled) async {
    state = state.copyWith(warnAboutSuspiciousLinks: enabled);
    await ref
        .read(localStorageProvider)
        .setBool(StorageKeys.warnAboutSuspiciousLinks, enabled);
  }

  Future<void> setOpenSafeLinksAutomatically(bool enabled) async {
    state = state.copyWith(openSafeLinksAutomatically: enabled);
    await ref
        .read(localStorageProvider)
        .setBool(StorageKeys.openSafeLinksAutomatically, enabled);
  }

  Future<void> setShowRiskExplanations(bool enabled) async {
    state = state.copyWith(showRiskExplanations: enabled);
    await ref
        .read(localStorageProvider)
        .setBool(StorageKeys.showRiskExplanations, enabled);
  }
}

final protectionSettingsProvider =
    NotifierProvider<ProtectionSettingsController, ProtectionSettings>(
      ProtectionSettingsController.new,
    );
