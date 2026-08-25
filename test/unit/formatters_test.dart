import 'package:flutter_test/flutter_test.dart';
import 'package:rakshak/core/utils/formatters.dart';

void main() {
  group('AppFormatters', () {
    test('formats rupees with the ₹ symbol and Indian grouping', () {
      final formatted = AppFormatters.rupees(50000);
      expect(formatted, startsWith('₹'));
      expect(formatted, contains('50,000'));
    });

    test('formats paise into rupees', () {
      expect(AppFormatters.rupeesFromPaise(500000), AppFormatters.rupees(5000));
    });

    test('formats dates as "d MMM yyyy"', () {
      expect(AppFormatters.date(DateTime(2026, 8, 24)), '24 Aug 2026');
    });
  });
}
