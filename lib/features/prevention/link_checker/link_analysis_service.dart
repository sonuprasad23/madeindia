import 'package:uuid/uuid.dart';

import '../../../core/utils/url_utils.dart';
import '../../../data/models/link_check_result.dart';
import '../../../data/models/risk_level.dart';
import '../../../data/models/threat_domain.dart';
import 'link_risk_engine.dart';
import 'threat_intelligence_provider.dart';

/// Thrown when a URL cannot be normalized/parsed at all.
class UnparseableUrlException implements Exception {
  UnparseableUrlException(this.input);
  final String input;
  @override
  String toString() => 'Could not interpret "$input" as a URL.';
}

/// Service boundary for URL analysis, structured as:
///
///   LinkAnalysisService -> Local Rules -> Threat Intelligence -> Risk Engine
///
/// [checkUrl] always runs the deterministic local [LinkRiskEngine] first
/// (see its doc comment — this never uses randomness). When a
/// [ThreatIntelligenceProvider] is supplied and finds a match, its
/// indicator is ADDED and can only ever escalate the risk level/score,
/// never quietly downgrade a local finding — a real feed corroborates or
/// adds evidence, it does not get to declare something "safe" that local
/// rules already flagged. [checkUrl] returns the same [LinkCheckResult]
/// shape regardless of which layers actually contributed to it.
abstract class LinkAnalysisService {
  Future<LinkCheckResult> checkUrl(String rawUrl, {String? sourceApp});
  Future<RiskAssessment> getRiskDetails(String rawUrl);
  List<ThreatIndicator> getThreatIndicators(LinkCheckResult result);
}

class DemoLinkAnalysisService implements LinkAnalysisService {
  DemoLinkAnalysisService({
    LinkRiskEngine? engine,
    List<ThreatDomainRecord> Function()? adminOverridesProvider,
    ThreatIntelligenceProvider? threatIntelligenceProvider,
    Uuid? uuid,
  }) : _engine = engine ?? const LinkRiskEngine(),
       _adminOverridesProvider = adminOverridesProvider,
       _threatIntelligenceProvider =
           threatIntelligenceProvider ??
           const DisabledThreatIntelligenceProvider(),
       _uuid = uuid ?? const Uuid();

  final LinkRiskEngine _engine;
  final List<ThreatDomainRecord> Function()? _adminOverridesProvider;
  final ThreatIntelligenceProvider _threatIntelligenceProvider;
  final Uuid _uuid;

  static const _levelSeverity = {
    RiskLevel.safe: 0,
    RiskLevel.unknown: 1,
    RiskLevel.suspicious: 2,
    RiskLevel.dangerous: 3,
  };

  @override
  Future<LinkCheckResult> checkUrl(String rawUrl, {String? sourceApp}) async {
    // Simulated latency so the UI can show a genuine (short) loading state
    // rather than an instantaneous, un-demo-able result.
    await Future<void>.delayed(const Duration(milliseconds: 500));

    final normalized = UrlUtils.normalize(rawUrl);
    if (normalized == null) {
      throw UnparseableUrlException(rawUrl);
    }

    final overrides =
        _adminOverridesProvider?.call() ?? const <ThreatDomainRecord>[];
    final assessment = _engine.assess(normalized, adminOverrides: overrides);

    var level = assessment.level;
    var score = assessment.score;
    final indicators = [...assessment.indicators];

    final remoteMatch = await _threatIntelligenceProvider.lookup(
      domain: normalized.domain,
      normalizedUrl: normalized.uri.toString(),
    );
    if (remoteMatch != null) {
      indicators.add(remoteMatch.indicator);
      if (_levelSeverity[remoteMatch.level]! > _levelSeverity[level]!) {
        level = remoteMatch.level;
        score = remoteMatch.level == RiskLevel.dangerous
            ? 95
            : (remoteMatch.level == RiskLevel.suspicious ? 60 : score);
      }
    }

    return LinkCheckResult(
      id: _uuid.v4(),
      originalUrl: rawUrl.trim(),
      normalizedUrl: normalized.uri.toString(),
      domain: normalized.domain,
      riskLevel: level,
      riskScore: score,
      indicators: indicators,
      isHttps: normalized.isHttps,
      checkedAt: DateTime.now(),
      sourceApp: sourceApp,
    );
  }

  @override
  Future<RiskAssessment> getRiskDetails(String rawUrl) async {
    final normalized = UrlUtils.normalize(rawUrl);
    if (normalized == null) throw UnparseableUrlException(rawUrl);
    final overrides =
        _adminOverridesProvider?.call() ?? const <ThreatDomainRecord>[];
    return _engine.assess(normalized, adminOverrides: overrides);
  }

  @override
  List<ThreatIndicator> getThreatIndicators(LinkCheckResult result) =>
      result.indicators;
}
