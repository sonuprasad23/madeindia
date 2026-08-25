import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/app_providers.dart';
import '../../core/storage/local_storage_service.dart';

class ProtectionSettings {
  const ProtectionSettings({
    this.linkProtectionEnabled = true,
    this.safeViewerDefaultOn = false,
  });

  final bool linkProtectionEnabled;
  final bool safeViewerDefaultOn;

  ProtectionSettings copyWith({
    bool? linkProtectionEnabled,
    bool? safeViewerDefaultOn,
  }) => ProtectionSettings(
    linkProtectionEnabled: linkProtectionEnabled ?? this.linkProtectionEnabled,
    safeViewerDefaultOn: safeViewerDefaultOn ?? this.safeViewerDefaultOn,
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
}

final protectionSettingsProvider =
    NotifierProvider<ProtectionSettingsController, ProtectionSettings>(
      ProtectionSettingsController.new,
    );
