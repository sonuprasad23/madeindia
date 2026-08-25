import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/app_providers.dart';
import '../storage/local_storage_service.dart';

/// Supported app languages. Adding a new one means: add an ARB file under
/// `lib/core/localization/arb/`, run `flutter gen-l10n`, and add an entry
/// here — nothing else in the app needs to change.
class SupportedLanguage {
  const SupportedLanguage(this.code, this.nativeName);

  final String code;
  final String nativeName;

  Locale get locale => Locale(code);
}

const supportedLanguages = [
  SupportedLanguage('en', 'English'),
  SupportedLanguage('hi', 'हिन्दी'),
  SupportedLanguage('gu', 'ગુજરાતી'),
  SupportedLanguage('mr', 'मराठी'),
];

class LanguageController extends Notifier<Locale> {
  @override
  Locale build() {
    final stored = ref
        .read(localStorageProvider)
        .getString(StorageKeys.languageCode);
    final match = supportedLanguages.where((l) => l.code == stored);
    return match.isNotEmpty ? match.first.locale : const Locale('en');
  }

  Future<void> setLanguage(String code) async {
    state = Locale(code);
    await ref
        .read(localStorageProvider)
        .setString(StorageKeys.languageCode, code);
  }
}

final languageProvider = NotifierProvider<LanguageController, Locale>(
  LanguageController.new,
);
