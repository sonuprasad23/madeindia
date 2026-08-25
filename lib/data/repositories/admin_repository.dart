import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../datasources/demo_seed_data.dart';
import '../models/admin_models.dart';
import '../models/threat_domain.dart';

/// Admin-managed threat-intelligence domain list. [LinkRiskEngine] reads
/// this (via [DemoLinkAnalysisService]'s override provider) so an admin
/// action here immediately changes citizen-facing link check results —
/// exactly the seam a real threat-intel feed would plug into.
class ThreatDomainRepository extends Notifier<List<ThreatDomainRecord>> {
  @override
  List<ThreatDomainRecord> build() => DemoSeedData.threatDomains();

  void upsert(ThreatDomainRecord record) {
    final withoutExisting = state
        .where((r) => r.domain != record.domain)
        .toList();
    state = [record, ...withoutExisting];
  }

  void remove(String domain) {
    state = state.where((r) => r.domain != domain).toList();
  }
}

final threatDomainRepositoryProvider =
    NotifierProvider<ThreatDomainRepository, List<ThreatDomainRecord>>(
      ThreatDomainRepository.new,
    );

/// Read-only accessor the citizen-facing link checker uses to fetch
/// current admin overrides without depending on the admin feature module.
List<ThreatDomainRecord> readThreatDomainOverrides(Ref ref) =>
    ref.read(threatDomainRepositoryProvider);

class AdminUserRepository extends Notifier<List<AdminUserSummary>> {
  @override
  List<AdminUserSummary> build() => DemoSeedData.adminUsers();

  void setActive(String id, bool active) {
    state = state
        .map(
          (u) => u.id == id
              ? AdminUserSummary(
                  id: u.id,
                  name: u.name,
                  mobileMasked: u.mobileMasked,
                  state: u.state,
                  joinedAt: u.joinedAt,
                  caseCount: u.caseCount,
                  active: active,
                )
              : u,
        )
        .toList();
  }
}

final adminUserRepositoryProvider =
    NotifierProvider<AdminUserRepository, List<AdminUserSummary>>(
      AdminUserRepository.new,
    );

class ContentArticleRepository extends Notifier<List<ContentArticle>> {
  @override
  List<ContentArticle> build() => DemoSeedData.contentArticles();

  void upsert(ContentArticle article) {
    state = [article, ...state.where((a) => a.id != article.id)];
  }

  void remove(String id) {
    state = state.where((a) => a.id != id).toList();
  }
}

final contentArticleRepositoryProvider =
    NotifierProvider<ContentArticleRepository, List<ContentArticle>>(
      ContentArticleRepository.new,
    );

class RiskThresholdsController extends Notifier<RiskThresholds> {
  @override
  RiskThresholds build() => const RiskThresholds();

  void update({int? suspiciousAt, int? dangerousAt}) {
    state = state.copyWith(
      suspiciousAt: suspiciousAt,
      dangerousAt: dangerousAt,
    );
  }
}

final riskThresholdsProvider =
    NotifierProvider<RiskThresholdsController, RiskThresholds>(
      RiskThresholdsController.new,
    );
