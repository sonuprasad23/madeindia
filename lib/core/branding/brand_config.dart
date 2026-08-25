import 'package:flutter/material.dart';

/// Centralized branding configuration for Rakshak.
///
/// Nothing in the UI layer should hardcode the app name, logo asset path,
/// or brand colors directly — everything reads from here so the identity
/// can be swapped (e.g. white-labelled for a state deployment) without
/// touching feature code.
class BrandConfig {
  const BrandConfig._();

  static const String appName = 'Rakshak';
  static const String appTagline = 'Cyber Safety & Cybercrime Assistance';
  static const String logoAssetLight = 'assets/branding/rakshak_logo_light.svg';
  static const String logoAssetDark = 'assets/branding/rakshak_logo_dark.svg';
  static const String logoMonochrome = 'assets/branding/rakshak_logo_mono.svg';
  static const String logoCompact = 'assets/branding/rakshak_logo_compact.svg';
  static const String appIcon = 'assets/branding/rakshak_icon.svg';

  // Indian public-service inspired palette: deep navy (trust/authority),
  // restrained saffron (alert/energy, used sparingly), supporting green
  // (safety/positive states). Kept deliberately muted — no flag-waving.
  static const Color primaryNavy = Color(0xFF0B2545);
  static const Color secondarySaffron = Color(0xFFC96A1E);
  static const Color accentGreen = Color(0xFF1E7A4C);
  static const Color neutralWhite = Color(0xFFFCFCFB);

  static const String fontFamily = 'Roboto';
}
