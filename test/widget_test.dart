import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rakshak/core/services/app_providers.dart';
import 'package:rakshak/core/storage/local_storage_service.dart';
import 'package:rakshak/main.dart';

void main() {
  testWidgets('App boots to the dashboard and can navigate to Protect', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final storage = await LocalStorageService.create();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localStorageProvider.overrideWithValue(storage)],
        child: const RakshakApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Rakshak'), findsWidgets);
    expect(find.text('Cyber Safety'), findsOneWidget);
    expect(find.text('Check Link'), findsOneWidget);

    await tester.tap(find.text('Protect').last);
    await tester.pumpAndSettle();

    expect(find.text('Link Checker'), findsOneWidget);
  });
}
