import 'package:flutter/material.dart';

import '../../core/theme/status_colors.dart';

/// Risk classification for a checked URL.
///
/// Deliberately probabilistic language throughout the app — never
/// "guaranteed safe". See [LinkAnalysisService] for how this is derived.
enum RiskLevel { safe, suspicious, dangerous, unknown }

extension RiskLevelX on RiskLevel {
  String get label => switch (this) {
    RiskLevel.safe => 'No known threats detected',
    RiskLevel.suspicious => 'Suspicious Link',
    RiskLevel.dangerous => 'Dangerous Link',
    RiskLevel.unknown => 'Unable to determine',
  };

  /// The longer, plain-language explanation shown under the result badge.
  /// Wording is deliberately hedged — never a certainty claim.
  String get description => switch (this) {
    RiskLevel.safe => 'No known threats detected.',
    RiskLevel.suspicious =>
      'This URL contains indicators commonly associated with suspicious activity.',
    RiskLevel.dangerous =>
      'Known or strongly suspected malicious activity was detected.',
    RiskLevel.unknown =>
      'We could not establish sufficient information about this URL.',
  };

  String get shortLabel => switch (this) {
    RiskLevel.safe => 'Safe',
    RiskLevel.suspicious => 'Suspicious',
    RiskLevel.dangerous => 'Dangerous',
    RiskLevel.unknown => 'Unknown',
  };

  String get emoji => switch (this) {
    RiskLevel.safe => '🟢',
    RiskLevel.suspicious => '🟠',
    RiskLevel.dangerous => '🔴',
    RiskLevel.unknown => '⚪',
  };

  Color color(Brightness brightness) => switch (this) {
    RiskLevel.safe => StatusColors.safe(brightness),
    RiskLevel.suspicious => StatusColors.suspicious(brightness),
    RiskLevel.dangerous => StatusColors.dangerous(brightness),
    RiskLevel.unknown => StatusColors.unknown(brightness),
  };

  IconData get icon => switch (this) {
    RiskLevel.safe => Icons.verified_outlined,
    RiskLevel.suspicious => Icons.warning_amber_rounded,
    RiskLevel.dangerous => Icons.dangerous_outlined,
    RiskLevel.unknown => Icons.help_outline_rounded,
  };
}
