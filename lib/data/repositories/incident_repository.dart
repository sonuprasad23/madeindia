import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/services/app_providers.dart';
import '../datasources/json_list_store.dart';
import '../models/incident.dart';

const _kIncidentsKey = 'repo.incidents';

/// Draft incident reports — created when a user starts "Report an
/// Incident" and taps a category, before the complaint is reviewed and
/// submitted (at which point a [CaseRecord] is created from it).
class IncidentRepository extends Notifier<List<Incident>> {
  late JsonListStore<Incident> _store;
  final _uuid = const Uuid();

  @override
  List<Incident> build() {
    _store = JsonListStore<Incident>(
      storage: ref.read(localStorageProvider),
      key: _kIncidentsKey,
      toJson: (i) => i.toJson(),
      fromJson: Incident.fromJson,
    );
    return _store.load();
  }

  Incident? byId(String id) {
    final matches = state.where((i) => i.id == id);
    return matches.isEmpty ? null : matches.first;
  }

  Future<Incident> create(IncidentCategory category) async {
    final incident = Incident(
      id: _uuid.v4(),
      category: category,
      createdAt: DateTime.now(),
    );
    state = [incident, ...state];
    await _store.save(state);
    return incident;
  }

  Future<void> update(String id, Incident Function(Incident) updater) async {
    state = state.map((i) => i.id == id ? updater(i) : i).toList();
    await _store.save(state);
  }

  Future<void> delete(String id) async {
    state = state.where((i) => i.id != id).toList();
    await _store.save(state);
  }

  Future<void> addTimelineEvent(String incidentId, TimelineEvent event) async {
    await update(incidentId, (i) {
      final updated = [...i.timeline, event]
        ..sort((a, b) => a.occurredAt.compareTo(b.occurredAt));
      return i.copyWith(timeline: updated);
    });
  }

  Future<void> attachEvidence(String incidentId, String evidenceId) async {
    await update(incidentId, (i) {
      if (i.evidenceIds.contains(evidenceId)) return i;
      return i.copyWith(evidenceIds: [...i.evidenceIds, evidenceId]);
    });
  }
}

final incidentRepositoryProvider =
    NotifierProvider<IncidentRepository, List<Incident>>(
      IncidentRepository.new,
    );
