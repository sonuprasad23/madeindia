import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/localization/generated/app_localizations.dart';
import 'core/localization/language_controller.dart';
import 'core/routing/app_router.dart';
import 'core/routing/app_routes.dart';
import 'core/services/app_providers.dart';
import 'core/services/share_intent_service.dart';
import 'core/storage/local_storage_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final localStorage = await LocalStorageService.create();

  runApp(
    ProviderScope(
      overrides: [localStorageProvider.overrideWithValue(localStorage)],
      child: const RakshakApp(),
    ),
  );
}

class RakshakApp extends ConsumerStatefulWidget {
  const RakshakApp({super.key});

  @override
  ConsumerState<RakshakApp> createState() => _RakshakAppState();
}

class _RakshakAppState extends ConsumerState<RakshakApp> {
  final _shareIntentService = ShareIntentService();

  @override
  void initState() {
    super.initState();
    _wireShareIntent();
  }

  Future<void> _wireShareIntent() async {
    final initial = await _shareIntentService.consumeInitialSharedText();
    if (initial != null && initial.isNotEmpty) {
      _openSharedText(initial);
    }
    _shareIntentService.sharedTextStream.listen(_openSharedText);
  }

  void _openSharedText(String text) {
    final router = ref.read(goRouterProvider);
    router.push(AppRoutes.linkChecker, extra: text);
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(languageProvider);

    return MaterialApp.router(
      title: 'Rakshak',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}
