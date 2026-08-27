import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rakshak/core/branding/brand_config.dart';
import 'package:rakshak/core/widgets/rakshak_logo.dart';

void main() {
  group('Branding assets', () {
    for (final asset in [
      BrandConfig.appIcon,
      BrandConfig.logoAssetLight,
      BrandConfig.logoAssetDark,
      BrandConfig.logoMonochrome,
      BrandConfig.logoCompact,
    ]) {
      testWidgets('$asset renders without error', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: SvgPicture.asset(asset, width: 64, height: 64),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(SvgPicture), findsOneWidget);
      });
    }

    for (final variant in RakshakLogoVariant.values) {
      testWidgets('RakshakLogo renders variant $variant without error', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(child: RakshakLogo(variant: variant)),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(RakshakLogo), findsOneWidget);
      });
    }

    testWidgets('RakshakLogo with wordmark shows the app name', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: RakshakLogo(withWordmark: true))),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text(BrandConfig.appName), findsOneWidget);
    });
  });
}
