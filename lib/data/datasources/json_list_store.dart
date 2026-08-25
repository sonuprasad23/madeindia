import 'dart:convert';

import '../../core/storage/local_storage_service.dart';

/// Generic helper for persisting a list of JSON-serializable domain objects
/// under a single [LocalStorageService] key.
///
/// This is the demo persistence boundary — swapping to a real backend
/// later means replacing calls to this class with a repository that hits
/// an API, without changing the repository's public method signatures.
class JsonListStore<T> {
  JsonListStore({
    required LocalStorageService storage,
    required String key,
    required Map<String, dynamic> Function(T) toJson,
    required T Function(Map<String, dynamic>) fromJson,
  }) : _storage = storage,
       _key = key,
       _toJson = toJson,
       _fromJson = fromJson;

  final LocalStorageService _storage;
  final String _key;
  final Map<String, dynamic> Function(T) _toJson;
  final T Function(Map<String, dynamic>) _fromJson;

  List<T> load({List<T> Function()? seed}) {
    final raw = _storage.getString(_key);
    if (raw == null || raw.isEmpty) {
      final seeded = seed?.call() ?? <T>[];
      if (seeded.isNotEmpty) save(seeded);
      return seeded;
    }
    try {
      final decoded = jsonDecode(raw) as List;
      return decoded.map((e) => _fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return seed?.call() ?? <T>[];
    }
  }

  Future<void> save(List<T> items) async {
    final encoded = jsonEncode(items.map(_toJson).toList());
    await _storage.setString(_key, encoded);
  }
}
