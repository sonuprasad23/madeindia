import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/services/app_providers.dart';
import '../datasources/demo_seed_data.dart';
import '../datasources/json_list_store.dart';
import '../models/notification_item.dart';

const _kNotificationsKey = 'repo.notifications';

class NotificationRepository extends Notifier<List<NotificationItem>> {
  late JsonListStore<NotificationItem> _store;
  final _uuid = const Uuid();

  @override
  List<NotificationItem> build() {
    _store = JsonListStore<NotificationItem>(
      storage: ref.read(localStorageProvider),
      key: _kNotificationsKey,
      toJson: (n) => n.toJson(),
      fromJson: NotificationItem.fromJson,
    );
    return _store.load(seed: DemoSeedData.notifications);
  }

  int get unreadCount => state.where((n) => !n.read).length;

  Future<void> push({
    required NotificationKind kind,
    required String title,
    required String body,
  }) async {
    final item = NotificationItem(
      id: _uuid.v4(),
      kind: kind,
      title: title,
      body: body,
      createdAt: DateTime.now(),
    );
    state = [item, ...state];
    await _store.save(state);
  }

  Future<void> markRead(String id) async {
    state = state.map((n) => n.id == id ? n.copyWith(read: true) : n).toList();
    await _store.save(state);
  }

  Future<void> markAllRead() async {
    state = state.map((n) => n.copyWith(read: true)).toList();
    await _store.save(state);
  }
}

final notificationRepositoryProvider =
    NotifierProvider<NotificationRepository, List<NotificationItem>>(
      NotificationRepository.new,
    );
