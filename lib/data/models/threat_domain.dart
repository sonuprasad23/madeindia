import 'risk_level.dart';

/// An admin-managed domain record in the demo threat-intelligence store.
///
/// This is the seed for what would later become a real threat-intel feed
/// integration — [AdminLinkRepository] exposes the same shape either way.
class ThreatDomainRecord {
  const ThreatDomainRecord({
    required this.domain,
    required this.status,
    required this.reason,
    required this.lastUpdated,
    this.reportCount = 0,
    this.checkCount = 0,
    this.expiresAt,
  });

  final String domain;
  final RiskLevel status;
  final String reason;
  final DateTime lastUpdated;
  final int reportCount;
  final int checkCount;
  final DateTime? expiresAt;

  ThreatDomainRecord copyWith({
    RiskLevel? status,
    String? reason,
    DateTime? lastUpdated,
    int? reportCount,
    int? checkCount,
    DateTime? expiresAt,
  }) {
    return ThreatDomainRecord(
      domain: domain,
      status: status ?? this.status,
      reason: reason ?? this.reason,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      reportCount: reportCount ?? this.reportCount,
      checkCount: checkCount ?? this.checkCount,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
