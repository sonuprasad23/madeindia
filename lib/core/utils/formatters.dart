import 'package:intl/intl.dart';

/// Indian-locale formatting helpers (₹ currency with lakh/crore grouping,
/// dd MMM yyyy dates) used throughout the app instead of ad-hoc formatting.
class AppFormatters {
  const AppFormatters._();

  static final NumberFormat _rupee = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );
  static final DateFormat _date = DateFormat('d MMM yyyy');
  static final DateFormat _dateTime = DateFormat('d MMM yyyy, h:mm a');
  static final DateFormat _time = DateFormat('h:mm a');

  static String rupeesFromPaise(int paise) => _rupee.format(paise / 100);
  static String rupees(num amount) => _rupee.format(amount);
  static String date(DateTime dt) => _date.format(dt);
  static String dateTime(DateTime dt) => _dateTime.format(dt);
  static String time(DateTime dt) => _time.format(dt);

  static String relativeShort(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return date(dt);
  }
}
