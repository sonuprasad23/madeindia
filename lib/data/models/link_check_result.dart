import 'risk_level.dart';

/// A single reason contributing to a link's risk classification.
class ThreatIndicator {
  const ThreatIndicator({
    required this.label,
    required this.detail,
    this.isPositive = false,
  });

  /// Short label, e.g. "Recently registered domain".
  final String label;

  /// Longer explanation shown under "Why was this flagged?".
  final String detail;

  /// True for reassuring signals (e.g. "HTTPS present"), false for
  /// risk-contributing signals.
  final bool isPositive;

  Map<String, dynamic> toJson() => {
    'label': label,
    'detail': detail,
    'isPositive': isPositive,
  };

  factory ThreatIndicator.fromJson(Map<String, dynamic> json) =>
      ThreatIndicator(
        label: json['label'] as String,
        detail: json['detail'] as String,
        isPositive: json['isPositive'] as bool? ?? false,
      );
}

/// Result of analyzing a single URL.
class LinkCheckResult {
  const LinkCheckResult({
    required this.id,
    required this.originalUrl,
    required this.normalizedUrl,
    required this.domain,
    required this.riskLevel,
    required this.riskScore,
    required this.indicators,
    required this.isHttps,
    required this.checkedAt,
    this.finalUrl,
    this.source = 'Demo Threat Intelligence',
  });

  final String id;
  final String originalUrl;
  final String normalizedUrl;
  final String domain;
  final RiskLevel riskLevel;

  /// 0-100, higher is riskier. Derived deterministically, not random.
  final int riskScore;
  final List<ThreatIndicator> indicators;
  final bool isHttps;
  final DateTime checkedAt;

  /// Where redirects were followed (demo does not perform live network
  /// redirects; this reflects known demo redirect chains only).
  final String? finalUrl;
  final String source;

  List<ThreatIndicator> get negativeIndicators =>
      indicators.where((i) => !i.isPositive).toList();
  List<ThreatIndicator> get positiveIndicators =>
      indicators.where((i) => i.isPositive).toList();

  Map<String, dynamic> toJson() => {
    'id': id,
    'originalUrl': originalUrl,
    'normalizedUrl': normalizedUrl,
    'domain': domain,
    'riskLevel': riskLevel.name,
    'riskScore': riskScore,
    'isHttps': isHttps,
    'checkedAt': checkedAt.toIso8601String(),
    'finalUrl': finalUrl,
    'source': source,
    'indicators': indicators.map((i) => i.toJson()).toList(),
  };

  factory LinkCheckResult.fromJson(Map<String, dynamic> json) =>
      LinkCheckResult(
        id: json['id'] as String,
        originalUrl: json['originalUrl'] as String,
        normalizedUrl: json['normalizedUrl'] as String,
        domain: json['domain'] as String,
        riskLevel: RiskLevel.values.byName(json['riskLevel'] as String),
        riskScore: json['riskScore'] as int,
        indicators: (json['indicators'] as List? ?? [])
            .map((i) => ThreatIndicator.fromJson(i as Map<String, dynamic>))
            .toList(),
        isHttps: json['isHttps'] as bool,
        checkedAt: DateTime.parse(json['checkedAt'] as String),
        finalUrl: json['finalUrl'] as String?,
        source: json['source'] as String? ?? 'Demo Threat Intelligence',
      );
}
