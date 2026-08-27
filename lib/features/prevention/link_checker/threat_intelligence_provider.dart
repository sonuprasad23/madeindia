import '../../../data/models/link_check_result.dart';
import '../../../data/models/risk_level.dart';

/// Result of an external threat-intelligence lookup — only returned when
/// that source actually has a matching record for the domain/URL. A null
/// return from [ThreatIntelligenceProvider.lookup] means "no match, or the
/// source is unavailable" — never treated as a safety guarantee either way.
class ThreatIntelLookupResult {
  const ThreatIntelLookupResult({required this.level, required this.indicator});

  final RiskLevel level;
  final ThreatIndicator indicator;
}

/// The "Threat Intelligence" layer in:
///   LinkAnalysisService -> Local Rules -> Threat Intelligence -> Risk Engine
///
/// This sits alongside (not instead of) the deterministic local
/// [LinkRiskEngine] — it can only ever ADD corroborating evidence to a
/// result, never silently downgrade a local "dangerous" finding.
abstract class ThreatIntelligenceProvider {
  Future<ThreatIntelLookupResult?> lookup({
    required String domain,
    required String normalizedUrl,
  });
}

/// Default provider: always returns null immediately. Used whenever the
/// "Real Threat Intelligence" feature flag is off (the default), or no
/// backend proxy URL has been configured.
class DisabledThreatIntelligenceProvider implements ThreatIntelligenceProvider {
  const DisabledThreatIntelligenceProvider();

  @override
  Future<ThreatIntelLookupResult?> lookup({
    required String domain,
    required String normalizedUrl,
  }) async => null;
}
