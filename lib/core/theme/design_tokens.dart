/// Centralized spacing / radius / elevation tokens.
///
/// Widgets should reference these instead of hardcoding magic numbers so
/// spacing stays consistent across the app.
class Spacing {
  const Spacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

class Radii {
  const Radii._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double pill = 999;
}

class Elevations {
  const Elevations._();

  static const double flat = 0;
  static const double card = 1;
  static const double raised = 3;
  static const double dialog = 6;
}

class MotionDurations {
  const MotionDurations._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 260);
  static const Duration slow = Duration(milliseconds: 420);
}
