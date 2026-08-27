import 'risk_level.dart';

/// What the user ultimately did with a checked link — recorded into Link
/// History after the fact so the history reads like a real audit trail
/// ("Checked example.com — Low Risk — Opened in default browser").
enum LinkUserAction {
  openedInBrowser,
  viewedSafely,
  openedAnyway,
  dontOpen,
  cancelled,
}

extension LinkUserActionX on LinkUserAction {
  String get label => switch (this) {
    LinkUserAction.openedInBrowser => 'Opened in default browser',
    LinkUserAction.viewedSafely => 'Viewed safely',
    LinkUserAction.openedAnyway => 'Opened anyway',
    LinkUserAction.dontOpen => "Didn't open",
    LinkUserAction.cancelled => 'Cancelled',
  };
}

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
    this.sourceApp,
    this.userAction,
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

  /// Best-effort friendly name of the app this link arrived from (e.g.
  /// "WhatsApp"), when it reached Rakshak via an Android share/view
  /// intent. Null for links checked by typing/pasting or via QR.
  final String? sourceApp;

  /// What the user ultimately did with this result. Set after the fact
  /// (the result exists before the user acts), so this starts null and is
  /// filled in via [LinkRepository.recordAction].
  final LinkUserAction? userAction;

  List<ThreatIndicator> get negativeIndicators =>
      indicators.where((i) => !i.isPositive).toList();
  List<ThreatIndicator> get positiveIndicators =>
      indicators.where((i) => i.isPositive).toList();

  LinkCheckResult copyWith({LinkUserAction? userAction}) => LinkCheckResult(
    id: id,
    originalUrl: originalUrl,
    normalizedUrl: normalizedUrl,
    domain: domain,
    riskLevel: riskLevel,
    riskScore: riskScore,
    indicators: indicators,
    isHttps: isHttps,
    checkedAt: checkedAt,
    finalUrl: finalUrl,
    source: source,
    sourceApp: sourceApp,
    userAction: userAction ?? this.userAction,
  );

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
    'sourceApp': sourceApp,
    'userAction': userAction?.name,
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
        sourceApp: json['sourceApp'] as String?,
        userAction: json['userAction'] == null
            ? null
            : LinkUserAction.values.byName(json['userAction'] as String),
      );
}
