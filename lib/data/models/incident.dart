enum IncidentCategory {
  financialFraud,
  phishing,
  socialMediaHarassment,
  cyberbullying,
  fakeProfile,
  accountHacking,
  threatBlackmail,
  ransomware,
  onlineShoppingFraud,
  investmentFraud,
  upiFraud,
  cardFraud,
  identityTheft,
  emailFraud,
  cryptocurrencyFraud,
  other,
}

extension IncidentCategoryX on IncidentCategory {
  String get label => switch (this) {
    IncidentCategory.financialFraud => 'Financial Fraud',
    IncidentCategory.phishing => 'Phishing',
    IncidentCategory.socialMediaHarassment => 'Social Media Harassment',
    IncidentCategory.cyberbullying => 'Cyberbullying',
    IncidentCategory.fakeProfile => 'Fake Profile',
    IncidentCategory.accountHacking => 'Account Hacking',
    IncidentCategory.threatBlackmail => 'Threat / Blackmail',
    IncidentCategory.ransomware => 'Ransomware',
    IncidentCategory.onlineShoppingFraud => 'Online Shopping Fraud',
    IncidentCategory.investmentFraud => 'Investment Fraud',
    IncidentCategory.upiFraud => 'UPI Fraud',
    IncidentCategory.cardFraud => 'Credit/Debit Card Fraud',
    IncidentCategory.identityTheft => 'Identity Theft',
    IncidentCategory.emailFraud => 'Email Fraud',
    IncidentCategory.cryptocurrencyFraud => 'Cryptocurrency Fraud',
    IncidentCategory.other => 'Other',
  };
}

/// A single event in an incident's chronological timeline.
class TimelineEvent {
  TimelineEvent({
    required this.id,
    required this.occurredAt,
    required this.description,
    this.notes = '',
    this.attachedEvidenceIds = const [],
  });

  final String id;
  final DateTime occurredAt;
  final String description;
  final String notes;
  final List<String> attachedEvidenceIds;

  TimelineEvent copyWith({
    DateTime? occurredAt,
    String? description,
    String? notes,
    List<String>? attachedEvidenceIds,
  }) {
    return TimelineEvent(
      id: id,
      occurredAt: occurredAt ?? this.occurredAt,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      attachedEvidenceIds: attachedEvidenceIds ?? this.attachedEvidenceIds,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'occurredAt': occurredAt.toIso8601String(),
    'description': description,
    'notes': notes,
    'attachedEvidenceIds': attachedEvidenceIds,
  };

  factory TimelineEvent.fromJson(Map<String, dynamic> json) => TimelineEvent(
    id: json['id'] as String,
    occurredAt: DateTime.parse(json['occurredAt'] as String),
    description: json['description'] as String,
    notes: json['notes'] as String? ?? '',
    attachedEvidenceIds:
        (json['attachedEvidenceIds'] as List?)?.cast<String>() ?? const [],
  );
}

/// A draft incident report — the "what happened" stage before a complaint
/// is structured and submitted.
class Incident {
  Incident({
    required this.id,
    required this.category,
    required this.createdAt,
    this.timeline = const [],
    this.evidenceIds = const [],
    this.formData = const {},
    this.description = '',
  });

  final String id;
  final IncidentCategory category;
  final DateTime createdAt;
  final List<TimelineEvent> timeline;
  final List<String> evidenceIds;

  /// Free-form field values keyed by field id, populated by the dynamic
  /// crime-specific form. Values are always user-provided or explicitly
  /// user-confirmed extracted data — never fabricated.
  final Map<String, String> formData;
  final String description;

  Incident copyWith({
    List<TimelineEvent>? timeline,
    List<String>? evidenceIds,
    Map<String, String>? formData,
    String? description,
  }) {
    return Incident(
      id: id,
      category: category,
      createdAt: createdAt,
      timeline: timeline ?? this.timeline,
      evidenceIds: evidenceIds ?? this.evidenceIds,
      formData: formData ?? this.formData,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category.name,
    'createdAt': createdAt.toIso8601String(),
    'timeline': timeline.map((e) => e.toJson()).toList(),
    'evidenceIds': evidenceIds,
    'formData': formData,
    'description': description,
  };

  factory Incident.fromJson(Map<String, dynamic> json) => Incident(
    id: json['id'] as String,
    category: IncidentCategory.values.byName(json['category'] as String),
    createdAt: DateTime.parse(json['createdAt'] as String),
    timeline: (json['timeline'] as List? ?? [])
        .map((e) => TimelineEvent.fromJson(e as Map<String, dynamic>))
        .toList(),
    evidenceIds: (json['evidenceIds'] as List?)?.cast<String>() ?? const [],
    formData: (json['formData'] as Map?)?.cast<String, String>() ?? const {},
    description: json['description'] as String? ?? '',
  );
}
