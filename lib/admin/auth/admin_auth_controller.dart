import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/services/app_providers.dart';
import '../../core/storage/local_storage_service.dart';
import '../../core/storage/secure_storage_service.dart';
import 'demo_admin_credentials.dart';

class AdminAuthController extends Notifier<bool> {
  @override
  bool build() =>
      ref.read(localStorageProvider).getBool(StorageKeys.adminSessionActive) ??
      false;

  Future<bool> signIn(String username, String password) async {
    final valid =
        username == DemoAdminCredentials.username &&
        password == DemoAdminCredentials.password;
    if (!valid) return false;

    // Demo-only: a locally generated opaque token, not a real signed
    // session — a production build would validate against a real
    // identity provider and store its issued token here instead.
    await ref
        .read(secureStorageProvider)
        .write(SecureStorageKeys.adminAuthToken, const Uuid().v4());
    await ref
        .read(localStorageProvider)
        .setBool(StorageKeys.adminSessionActive, true);
    state = true;
    return true;
  }

  Future<void> signOut() async {
    await ref
        .read(secureStorageProvider)
        .delete(SecureStorageKeys.adminAuthToken);
    await ref
        .read(localStorageProvider)
        .setBool(StorageKeys.adminSessionActive, false);
    state = false;
  }
}

final adminAuthProvider = NotifierProvider<AdminAuthController, bool>(
  AdminAuthController.new,
);
