enum NotificationKind {
  linkChecked,
  evidenceSaved,
  complaintUpdated,
  caseStatusChanged,
  general,
}

class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.createdAt,
    this.read = false,
  });

  final String id;
  final NotificationKind kind;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool read;

  NotificationItem copyWith({bool? read}) => NotificationItem(
    id: id,
    kind: kind,
    title: title,
    body: body,
    createdAt: createdAt,
    read: read ?? this.read,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'kind': kind.name,
    'title': title,
    'body': body,
    'createdAt': createdAt.toIso8601String(),
    'read': read,
  };

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      NotificationItem(
        id: json['id'] as String,
        kind: NotificationKind.values.byName(json['kind'] as String),
        title: json['title'] as String,
        body: json['body'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        read: json['read'] as bool? ?? false,
      );
}
