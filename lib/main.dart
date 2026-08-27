import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/localization/generated/app_localizations.dart';
import 'core/localization/language_controller.dart';
import 'core/routing/app_router.dart';
import 'core/routing/app_routes.dart';
import 'core/services/app_providers.dart';
import 'core/services/incoming_link_service.dart';
import 'core/storage/local_storage_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/prevention/browser_role_controller.dart';

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
  final _incomingLinkService = IncomingLinkService();

  @override
  void initState() {
    super.initState();
    _wireIncomingLinks();
    // Runs once ever, after the first frame so the system dialog never
    // races the app's own UI. Whether the user accepts, declines, or the
    // role is unavailable on this device, the app continues normally.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(browserRoleControllerProvider.notifier)
          .maybePromptOnFirstLaunch();
    });
  }

  Future<void> _wireIncomingLinks() async {
    final initial = await _incomingLinkService.consumeInitialLink();
    if (initial != null && initial.url.isNotEmpty) {
      _openIncomingLink(initial);
    }
    _incomingLinkService.incomingLinkStream.listen(_openIncomingLink);
  }

  /// Every link that arrives from outside Rakshak — tapped in another app
  /// or shared in — goes through the Link Security Gateway first. Nothing
  /// is opened or analyzed automatically just because a link arrived.
  void _openIncomingLink(IncomingLinkEvent event) {
    final router = ref.read(goRouterProvider);
    router.push(
      AppRoutes.linkGateway,
      extra: {'url': event.url, 'sourceApp': event.sourceAppLabel},
    );
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
