import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/app_providers.dart';
import '../datasources/json_list_store.dart';
import '../models/link_check_result.dart';

const _kLinkHistoryKey = 'repo.link_history';
const _maxHistoryEntries = 100;

/// History of every URL the user has checked, most recent first.
class LinkRepository extends Notifier<List<LinkCheckResult>> {
  late JsonListStore<LinkCheckResult> _store;

  @override
  List<LinkCheckResult> build() {
    _store = JsonListStore<LinkCheckResult>(
      storage: ref.read(localStorageProvider),
      key: _kLinkHistoryKey,
      toJson: (r) => r.toJson(),
      fromJson: LinkCheckResult.fromJson,
    );
    return _store.load();
  }

  Future<void> record(LinkCheckResult result) async {
    state = [result, ...state].take(_maxHistoryEntries).toList();
    await _store.save(state);
  }

  Future<void> clear() async {
    state = [];
    await _store.save(state);
  }
}

final linkRepositoryProvider =
    NotifierProvider<LinkRepository, List<LinkCheckResult>>(LinkRepository.new);
