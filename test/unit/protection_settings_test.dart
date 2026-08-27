import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rakshak/core/services/app_providers.dart';
import 'package:rakshak/core/storage/local_storage_service.dart';
import 'package:rakshak/features/prevention/protection_settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ProtectionSettingsController', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final storage = await LocalStorageService.create();
      container = ProviderContainer(
        overrides: [localStorageProvider.overrideWithValue(storage)],
      );
      addTearDown(container.dispose);
    });

    test('defaults match the documented safe-by-default posture', () {
      final settings = container.read(protectionSettingsProvider);
      expect(settings.linkProtectionEnabled, isTrue);
      expect(settings.safeViewerDefaultOn, isFalse);
      expect(settings.warnAboutSuspiciousLinks, isTrue);
      expect(settings.openSafeLinksAutomatically, isFalse);
      expect(settings.showRiskExplanations, isTrue);
    });

    test('toggles persist across a fresh controller instance', () async {
      await container
          .read(protectionSettingsProvider.notifier)
          .setOpenSafeLinksAutomatically(true);
      await container
          .read(protectionSettingsProvider.notifier)
          .setWarnAboutSuspiciousLinks(false);

      final storage = container.read(localStorageProvider);
      final freshContainer = ProviderContainer(
        overrides: [localStorageProvider.overrideWithValue(storage)],
      );
      addTearDown(freshContainer.dispose);

      final reloaded = freshContainer.read(protectionSettingsProvider);
      expect(reloaded.openSafeLinksAutomatically, isTrue);
      expect(reloaded.warnAboutSuspiciousLinks, isFalse);
      // Untouched settings keep their defaults.
      expect(reloaded.showRiskExplanations, isTrue);
    });
  });
}
