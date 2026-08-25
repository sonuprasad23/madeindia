import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/localization/language_controller.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/theme/theme_controller.dart';
import '../../core/widgets/rakshak_surfaces.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(languageProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.lg),
        children: [
          const RakshakSectionHeader(title: 'Appearance'),
          RakshakCard(
            child: RadioGroup<ThemeMode>(
              groupValue: themeMode,
              onChanged: (m) =>
                  ref.read(themeModeProvider.notifier).setThemeMode(m!),
              child: const Column(
                children: [
                  RadioListTile<ThemeMode>(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Light'),
                    value: ThemeMode.light,
                  ),
                  RadioListTile<ThemeMode>(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Dark'),
                    value: ThemeMode.dark,
                  ),
                  RadioListTile<ThemeMode>(
                    contentPadding: EdgeInsets.zero,
                    title: Text('System'),
                    value: ThemeMode.system,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Spacing.xl),

          const RakshakSectionHeader(title: 'Language'),
          RakshakCard(
            child: RadioGroup<String>(
              groupValue: locale.languageCode,
              onChanged: (code) =>
                  ref.read(languageProvider.notifier).setLanguage(code!),
              child: Column(
                children: supportedLanguages
                    .map(
                      (lang) => RadioListTile<String>(
                        contentPadding: EdgeInsets.zero,
                        title: Text(lang.nativeName),
                        value: lang.code,
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: Spacing.xl),

          const RakshakSectionHeader(title: 'About'),
          RakshakCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rakshak — demo build',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                Text(
                  AppConstants.demoDisclaimer,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
