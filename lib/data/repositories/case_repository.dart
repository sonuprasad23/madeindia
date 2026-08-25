import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/app_providers.dart';
import '../datasources/demo_seed_data.dart';
import '../datasources/json_list_store.dart';
import '../models/case_record.dart';

const _kCasesKey = 'repo.cases';

class CaseRepository extends Notifier<List<CaseRecord>> {
  late JsonListStore<CaseRecord> _store;

  @override
  List<CaseRecord> build() {
    _store = JsonListStore<CaseRecord>(
      storage: ref.read(localStorageProvider),
      key: _kCasesKey,
      toJson: (c) => c.toJson(),
      fromJson: CaseRecord.fromJson,
    );
    return _store.load(seed: DemoSeedData.cases);
  }

  CaseRecord? byId(String id) {
    final matches = state.where((c) => c.id == id);
    return matches.isEmpty ? null : matches.first;
  }

  Future<void> add(CaseRecord record) async {
    state = [record, ...state];
    await _store.save(state);
  }

  Future<void> advanceStatus(
    String id,
    CaseStatus newStatus, {
    String? note,
  }) async {
    state = state.map((c) {
      if (c.id != id) return c;
      return c.copyWith(
        status: newStatus,
        lastUpdated: DateTime.now(),
        timeline: [
          ...c.timeline,
          CaseTimelineStep(
            status: newStatus,
            occurredAt: DateTime.now(),
            note: note,
          ),
        ],
      );
    }).toList();
    await _store.save(state);
  }
}

final caseRepositoryProvider =
    NotifierProvider<CaseRepository, List<CaseRecord>>(CaseRepository.new);
