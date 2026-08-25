import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/local_storage_service.dart';
import '../storage/secure_storage_service.dart';

/// Overridden in `main.dart` after [LocalStorageService.create] resolves,
/// before `runApp` — every other provider that needs storage depends on
/// this being ready synchronously.
final localStorageProvider = Provider<LocalStorageService>((ref) {
  throw UnimplementedError(
    'localStorageProvider must be overridden in main() before runApp.',
  );
});

final secureStorageProvider = Provider<SecureStorageService>(
  (ref) => SecureStorageService(),
);
