import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/app_providers.dart';
import '../datasources/demo_seed_data.dart';
import '../datasources/json_list_store.dart';
import '../models/citizen_profile.dart';

const _kProfileKey = 'repo.citizen_profile';

/// The reusable citizen profile. Modeled as a single-item repository
/// (rather than a list) since this demo supports exactly one signed-in
/// citizen at a time.
class CitizenProfileRepository extends Notifier<CitizenProfile> {
  late JsonListStore<CitizenProfile> _store;

  @override
  CitizenProfile build() {
    _store = JsonListStore<CitizenProfile>(
      storage: ref.read(localStorageProvider),
      key: _kProfileKey,
      toJson: (p) => p.toJson(),
      fromJson: CitizenProfile.fromJson,
    );
    final loaded = _store.load(seed: () => [DemoSeedData.citizenProfile()]);
    return loaded.isNotEmpty ? loaded.first : DemoSeedData.citizenProfile();
  }

  Future<void> update(CitizenProfile Function(CitizenProfile) updater) async {
    state = updater(state);
    await _store.save([state]);
  }

  Future<void> confirmJurisdiction() async {
    final jurisdiction = state.jurisdiction;
    if (jurisdiction == null) return;
    await update(
      (p) => p.copyWith(
        jurisdiction: jurisdiction.copyWith(
          status: JurisdictionConfirmationStatus.confirmed,
        ),
      ),
    );
  }
}

final citizenProfileProvider =
    NotifierProvider<CitizenProfileRepository, CitizenProfile>(
      CitizenProfileRepository.new,
    );
