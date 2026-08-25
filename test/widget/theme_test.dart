import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rakshak/core/theme/app_theme.dart';

void main() {
  group('AppTheme', () {
    test('light theme uses a light brightness and Material 3', () {
      final theme = AppTheme.light();
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.light);
      expect(theme.colorScheme.brightness, Brightness.light);
    });

    test(
      'dark theme uses a dark brightness and is not the light theme inverted',
      () {
        final light = AppTheme.light();
        final dark = AppTheme.dark();
        expect(dark.brightness, Brightness.dark);
        expect(dark.colorScheme.brightness, Brightness.dark);
        expect(dark.colorScheme.surface, isNot(light.colorScheme.surface));
        expect(dark.cardTheme.color, isNot(light.cardTheme.color));
      },
    );

    test('both themes define distinguishable primary/secondary colors', () {
      for (final theme in [AppTheme.light(), AppTheme.dark()]) {
        expect(theme.colorScheme.primary, isNot(theme.colorScheme.secondary));
      }
    });
  });
}
