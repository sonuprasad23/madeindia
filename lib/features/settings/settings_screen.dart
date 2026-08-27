import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/localization/language_controller.dart';
import '../../core/services/system_actions_service.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/theme/theme_controller.dart';
import '../../core/widgets/rakshak_button.dart';
import '../../core/widgets/rakshak_surfaces.dart';
import '../location/current_location_controller.dart';
import '../prevention/protection_settings_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const _systemActions = SystemActionsService();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(languageProvider);
    final protection = ref.watch(protectionSettingsProvider);
    final location = ref.watch(currentLocationProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.lg),
        children: [
          const RakshakSectionHeader(title: 'Link Protection'),
          RakshakCard(
            color: theme.colorScheme.secondaryContainer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                    const SizedBox(width: Spacing.sm),
                    Expanded(
                      child: Text(
                        'Enable Link Protection',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.sm),
                Text(
                  'Rakshak can check web links before they are opened. To have every '
                  'tapped link route to Rakshak, set it as your device\'s default '
                  'browser below — Android\'s separate "Open supported links" screen '
                  'only applies to domains an app has verified ownership of (like a '
                  'company\'s own site), which doesn\'t apply here.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
                const SizedBox(height: Spacing.md),
                RakshakButton(
                  label: 'Set Rakshak as Default Browser',
                  icon: Icons.shield_outlined,
                  expand: false,
                  onPressed: () async {
                    final outcome = await _systemActions.requestBrowserRole();
                    if (!context.mounted) return;
                    final message = switch (outcome) {
                      BrowserRoleOutcome.granted =>
                        'Rakshak is now your default browser — links tapped elsewhere will open here.',
                      BrowserRoleOutcome.alreadyDefault =>
                        'Rakshak is already your default browser.',
                      BrowserRoleOutcome.declined =>
                        'Not set — you can try again anytime.',
                      BrowserRoleOutcome.unavailable =>
                        'Opened Android Settings — look for "Browser app" under Default apps.',
                      BrowserRoleOutcome.unsupportedPlatform =>
                        'Not supported on this device.',
                    };
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(message)));
                  },
                ),
                const SizedBox(height: Spacing.xs),
                RakshakButton(
                  label: 'Open Android Settings manually',
                  variant: RakshakButtonVariant.text,
                  expand: false,
                  onPressed: () async {
                    final opened = await _systemActions
                        .openLinkHandlerSettings();
                    if (!context.mounted) return;
                    if (!opened) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Could not open Android Settings on this device.',
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.md),
          RakshakCard(
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Check links before opening'),
                  value: protection.linkProtectionEnabled,
                  onChanged: (v) => ref
                      .read(protectionSettingsProvider.notifier)
                      .setLinkProtection(v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Safe Link Viewer'),
                  value: protection.safeViewerDefaultOn,
                  onChanged: (v) => ref
                      .read(protectionSettingsProvider.notifier)
                      .setSafeViewerDefault(v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Warn about suspicious links'),
                  subtitle: const Text(
                    'Shows an extra confirmation before "Open Anyway"',
                  ),
                  value: protection.warnAboutSuspiciousLinks,
                  onChanged: (v) => ref
                      .read(protectionSettingsProvider.notifier)
                      .setWarnAboutSuspiciousLinks(v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Open safe links automatically'),
                  subtitle: const Text(
                    'Only applies to links marked "No known threats detected"',
                  ),
                  value: protection.openSafeLinksAutomatically,
                  onChanged: (v) => ref
                      .read(protectionSettingsProvider.notifier)
                      .setOpenSafeLinksAutomatically(v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Show risk explanations'),
                  subtitle: const Text(
                    '"Why was this flagged?" details on results',
                  ),
                  value: protection.showRiskExplanations,
                  onChanged: (v) => ref
                      .read(protectionSettingsProvider.notifier)
                      .setShowRiskExplanations(v),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.xl),

          const RakshakSectionHeader(title: 'Location'),
          RakshakCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location.info != null
                      ? 'Current location: ${location.info!.displayLabel}'
                      : 'No location saved on this device.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Rakshak only retrieves your location when you ask it to, and never '
                  'tracks it continuously in the background.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (location.info != null) ...[
                  const SizedBox(height: Spacing.md),
                  RakshakButton(
                    label: 'Clear saved location',
                    icon: Icons.location_off_outlined,
                    variant: RakshakButtonVariant.secondary,
                    expand: false,
                    onPressed: () => ref
                        .read(currentLocationProvider.notifier)
                        .clearSavedLocation(),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: Spacing.xl),

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
