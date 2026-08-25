import 'incident.dart';

enum CaseStatus {
  draft,
  submitted,
  forwarded,
  underReview,
  additionalInfoRequired,
  underInvestigation,
  resolved,
  closed,
}

extension CaseStatusX on CaseStatus {
  String get label => switch (this) {
    CaseStatus.draft => 'Draft',
    CaseStatus.submitted => 'Submitted',
    CaseStatus.forwarded => 'Forwarded to Authority',
    CaseStatus.underReview => 'Under Review',
    CaseStatus.additionalInfoRequired => 'Additional Information Required',
    CaseStatus.underInvestigation => 'Under Investigation',
    CaseStatus.resolved => 'Resolved',
    CaseStatus.closed => 'Closed',
  };

  String get explanation => switch (this) {
    CaseStatus.draft =>
      'Your complaint has been prepared but not yet submitted.',
    CaseStatus.submitted =>
      'Your complaint has been recorded in the demo system and is queued for routing.',
    CaseStatus.forwarded =>
      'The demo system shows this complaint as forwarded to the relevant authority.',
    CaseStatus.underReview =>
      'The complaint is currently shown as being reviewed.',
    CaseStatus.additionalInfoRequired =>
      'More information or evidence has been requested before this case can proceed.',
    CaseStatus.underInvestigation =>
      'The case is currently shown as under investigation.',
    CaseStatus.resolved =>
      'The case is currently shown as resolved based on available demo data.',
    CaseStatus.closed => 'This case is currently shown as closed.',
  };
}

/// A single step in a case's status timeline.
class CaseTimelineStep {
  const CaseTimelineStep({
    required this.status,
    required this.occurredAt,
    this.note,
  });

  final CaseStatus status;
  final DateTime occurredAt;
  final String? note;

  Map<String, dynamic> toJson() => {
    'status': status.name,
    'occurredAt': occurredAt.toIso8601String(),
    'note': note,
  };

  factory CaseTimelineStep.fromJson(Map<String, dynamic> json) =>
      CaseTimelineStep(
        status: CaseStatus.values.byName(json['status'] as String),
        occurredAt: DateTime.parse(json['occurredAt'] as String),
        note: json['note'] as String?,
      );
}

/// A tracked case derived from a submitted complaint.
class CaseRecord {
  CaseRecord({
    required this.id,
    required this.category,
    required this.createdAt,
    required this.status,
    required this.timeline,
    this.amountInPaise,
    this.state,
    this.jurisdictionPoliceStation,
    this.lastUpdated,
    this.complaintId,
  });

  final String id;
  final IncidentCategory category;
  final DateTime createdAt;
  final CaseStatus status;
  final List<CaseTimelineStep> timeline;
  final int? amountInPaise;
  final String? state;
  final String? jurisdictionPoliceStation;
  final DateTime? lastUpdated;
  final String? complaintId;

  CaseRecord copyWith({
    CaseStatus? status,
    List<CaseTimelineStep>? timeline,
    DateTime? lastUpdated,
  }) {
    return CaseRecord(
      id: id,
      category: category,
      createdAt: createdAt,
      status: status ?? this.status,
      timeline: timeline ?? this.timeline,
      amountInPaise: amountInPaise,
      state: state,
      jurisdictionPoliceStation: jurisdictionPoliceStation,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      complaintId: complaintId,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category.name,
    'createdAt': createdAt.toIso8601String(),
    'status': status.name,
    'timeline': timeline.map((e) => e.toJson()).toList(),
    'amountInPaise': amountInPaise,
    'state': state,
    'jurisdictionPoliceStation': jurisdictionPoliceStation,
    'lastUpdated': lastUpdated?.toIso8601String(),
    'complaintId': complaintId,
  };

  factory CaseRecord.fromJson(Map<String, dynamic> json) => CaseRecord(
    id: json['id'] as String,
    category: IncidentCategory.values.byName(json['category'] as String),
    createdAt: DateTime.parse(json['createdAt'] as String),
    status: CaseStatus.values.byName(json['status'] as String),
    timeline: (json['timeline'] as List? ?? [])
        .map((e) => CaseTimelineStep.fromJson(e as Map<String, dynamic>))
        .toList(),
    amountInPaise: json['amountInPaise'] as int?,
    state: json['state'] as String?,
    jurisdictionPoliceStation: json['jurisdictionPoliceStation'] as String?,
    lastUpdated: json['lastUpdated'] == null
        ? null
        : DateTime.parse(json['lastUpdated'] as String),
    complaintId: json['complaintId'] as String?,
  );
}
