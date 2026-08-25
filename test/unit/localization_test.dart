import 'package:flutter_test/flutter_test.dart';
import 'package:rakshak/core/localization/generated/app_localizations.dart';
import 'package:rakshak/core/localization/language_controller.dart';

void main() {
  group('Localization', () {
    test('a delegate exists for every supported language', () {
      for (final lang in supportedLanguages) {
        expect(
          AppLocalizations.supportedLocales.map((l) => l.languageCode),
          contains(lang.code),
        );
      }
    });

    test(
      'every supported locale resolves and provides the core strings',
      () async {
        for (final locale in AppLocalizations.supportedLocales) {
          final localizations = await AppLocalizations.delegate.load(locale);
          expect(localizations.appName, isNotEmpty);
          expect(localizations.riskSafeLabel, isNotEmpty);
          expect(localizations.demoDisclaimerShort, isNotEmpty);
        }
      },
    );
  });
}
