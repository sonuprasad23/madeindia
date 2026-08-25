import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/app_providers.dart';
import '../storage/local_storage_service.dart';

class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final stored = ref
        .read(localStorageProvider)
        .getString(StorageKeys.themeMode);
    return switch (stored) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await ref
        .read(localStorageProvider)
        .setString(StorageKeys.themeMode, mode.name);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);
