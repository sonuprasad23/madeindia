import 'package:flutter/material.dart';

/// Semantic colors for risk levels and case statuses.
///
/// Kept separate from [ColorScheme] because these carry fixed meaning
/// (danger is always this red) regardless of light/dark mode, only the
/// tone shifts for contrast.
class StatusColors {
  const StatusColors._();

  static const Color safeLight = Color(0xFF1E7A4C);
  static const Color safeDark = Color(0xFF5FD895);

  static const Color suspiciousLight = Color(0xFFB5590E);
  static const Color suspiciousDark = Color(0xFFFFB870);

  static const Color dangerousLight = Color(0xFFB3261E);
  static const Color dangerousDark = Color(0xFFFFB4AB);

  static const Color unknownLight = Color(0xFF5F6368);
  static const Color unknownDark = Color(0xFFC4C6CA);

  static Color safe(Brightness b) =>
      b == Brightness.dark ? safeDark : safeLight;
  static Color suspicious(Brightness b) =>
      b == Brightness.dark ? suspiciousDark : suspiciousLight;
  static Color dangerous(Brightness b) =>
      b == Brightness.dark ? dangerousDark : dangerousLight;
  static Color unknown(Brightness b) =>
      b == Brightness.dark ? unknownDark : unknownLight;
}
