import 'package:uuid/uuid.dart';

import '../../../core/utils/url_utils.dart';
import '../../../data/models/link_check_result.dart';
import '../../../data/models/threat_domain.dart';
import 'link_risk_engine.dart';

/// Thrown when a URL cannot be normalized/parsed at all.
class UnparseableUrlException implements Exception {
  UnparseableUrlException(this.input);
  final String input;
  @override
  String toString() => 'Could not interpret "$input" as a URL.';
}

/// Service boundary for URL analysis.
///
/// This is intentionally the seam where a real threat-intelligence API
/// would be plugged in later — [checkUrl] returns the same [LinkCheckResult]
/// shape regardless of whether [LinkRiskEngine] or a live feed produced it.
abstract class LinkAnalysisService {
  Future<LinkCheckResult> checkUrl(String rawUrl);
  Future<RiskAssessment> getRiskDetails(String rawUrl);
  List<ThreatIndicator> getThreatIndicators(LinkCheckResult result);
}

class DemoLinkAnalysisService implements LinkAnalysisService {
  DemoLinkAnalysisService({
    LinkRiskEngine? engine,
    List<ThreatDomainRecord> Function()? adminOverridesProvider,
    Uuid? uuid,
  }) : _engine = engine ?? const LinkRiskEngine(),
       _adminOverridesProvider = adminOverridesProvider,
       _uuid = uuid ?? const Uuid();

  final LinkRiskEngine _engine;
  final List<ThreatDomainRecord> Function()? _adminOverridesProvider;
  final Uuid _uuid;

  @override
  Future<LinkCheckResult> checkUrl(String rawUrl) async {
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

    return LinkCheckResult(
      id: _uuid.v4(),
      originalUrl: rawUrl.trim(),
      normalizedUrl: normalized.uri.toString(),
      domain: normalized.domain,
      riskLevel: assessment.level,
      riskScore: assessment.score,
      indicators: assessment.indicators,
      isHttps: normalized.isHttps,
      checkedAt: DateTime.now(),
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
