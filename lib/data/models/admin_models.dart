/// Lightweight admin-facing summary models. Kept separate from the citizen
/// [CitizenProfile]/[CaseRecord] models because the admin panel should only
/// ever see summarized/metadata views, not raw sensitive content.
class AdminUserSummary {
  const AdminUserSummary({
    required this.id,
    required this.name,
    required this.mobileMasked,
    required this.state,
    required this.joinedAt,
    required this.caseCount,
    required this.active,
  });

  final String id;
  final String name;
  final String mobileMasked;
  final String state;
  final DateTime joinedAt;
  final int caseCount;
  final bool active;
}

class ContentArticle {
  const ContentArticle({
    required this.id,
    required this.title,
    required this.category,
    required this.body,
    required this.languageCode,
    required this.updatedAt,
    this.published = true,
  });

  final String id;
  final String title;
  final String category;
  final String body;
  final String languageCode;
  final DateTime updatedAt;
  final bool published;
}

class RiskThresholds {
  const RiskThresholds({this.suspiciousAt = 35, this.dangerousAt = 65});

  final int suspiciousAt;
  final int dangerousAt;

  RiskThresholds copyWith({int? suspiciousAt, int? dangerousAt}) =>
      RiskThresholds(
        suspiciousAt: suspiciousAt ?? this.suspiciousAt,
        dangerousAt: dangerousAt ?? this.dangerousAt,
      );
}
