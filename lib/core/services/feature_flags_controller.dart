import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/feature_flags.dart';
import '../storage/local_storage_service.dart';
import 'app_providers.dart';

/// Feature flags are normally fixed per build, but the Admin > Settings
/// screen can override them at runtime for this demo so the effect is
/// immediately visible without a rebuild.
class FeatureFlagsController extends Notifier<FeatureFlags> {
  @override
  FeatureFlags build() {
    final raw = ref
        .read(localStorageProvider)
        .getString(StorageKeys.featureFlagsOverride);
    if (raw == null) return const FeatureFlags();
    try {
      return FeatureFlags.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const FeatureFlags();
    }
  }

  Future<void> update(FeatureFlags Function(FeatureFlags) updater) async {
    state = updater(state);
    await ref
        .read(localStorageProvider)
        .setString(
          StorageKeys.featureFlagsOverride,
          jsonEncode(state.toJson()),
        );
  }
}

final featureFlagsProvider =
    NotifierProvider<FeatureFlagsController, FeatureFlags>(
      FeatureFlagsController.new,
    );
