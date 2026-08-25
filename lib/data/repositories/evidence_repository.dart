import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/app_providers.dart';
import '../datasources/json_list_store.dart';
import '../models/evidence_item.dart';

const _kEvidenceKey = 'repo.evidence';

class EvidenceRepository extends Notifier<List<EvidenceItem>> {
  late JsonListStore<EvidenceItem> _store;

  @override
  List<EvidenceItem> build() {
    _store = JsonListStore<EvidenceItem>(
      storage: ref.read(localStorageProvider),
      key: _kEvidenceKey,
      toJson: (e) => e.toJson(),
      fromJson: EvidenceItem.fromJson,
    );
    return _store.load();
  }

  List<EvidenceItem> forIncident(String incidentId) =>
      state.where((e) => e.relatedIncidentId == incidentId).toList();

  List<EvidenceItem> byIds(List<String> ids) =>
      state.where((e) => ids.contains(e.id)).toList();

  Future<void> add(EvidenceItem item) async {
    state = [item, ...state];
    await _store.save(state);
  }

  Future<void> update(
    String id,
    EvidenceItem Function(EvidenceItem) updater,
  ) async {
    state = state.map((e) => e.id == id ? updater(e) : e).toList();
    await _store.save(state);
  }

  Future<void> linkToIncident(String evidenceId, String incidentId) async {
    await update(evidenceId, (e) => e.copyWith(relatedIncidentId: incidentId));
  }

  Future<void> delete(String id) async {
    state = state.where((e) => e.id != id).toList();
    await _store.save(state);
  }
}

final evidenceRepositoryProvider =
    NotifierProvider<EvidenceRepository, List<EvidenceItem>>(
      EvidenceRepository.new,
    );
