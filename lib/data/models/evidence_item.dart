enum EvidenceCategory {
  financial,
  socialMedia,
  messages,
  calls,
  websites,
  transactions,
  documents,
  other,
}

extension EvidenceCategoryX on EvidenceCategory {
  String get label => switch (this) {
    EvidenceCategory.financial => 'Financial',
    EvidenceCategory.socialMedia => 'Social Media',
    EvidenceCategory.messages => 'Messages',
    EvidenceCategory.calls => 'Calls',
    EvidenceCategory.websites => 'Websites',
    EvidenceCategory.transactions => 'Transactions',
    EvidenceCategory.documents => 'Documents',
    EvidenceCategory.other => 'Other',
  };
}

enum EvidenceType { image, pdf, video, url, text, document }

extension EvidenceTypeX on EvidenceType {
  String get label => switch (this) {
    EvidenceType.image => 'Image',
    EvidenceType.pdf => 'PDF',
    EvidenceType.video => 'Video',
    EvidenceType.url => 'URL',
    EvidenceType.text => 'Text note',
    EvidenceType.document => 'Document',
  };
}

/// Data extracted from an evidence file by the (demo) extraction pipeline.
/// Always shown to the user labelled as "extracted, please verify" — never
/// treated as authoritative or silently merged into a complaint.
class ExtractedEvidenceData {
  const ExtractedEvidenceData({
    this.amount,
    this.utr,
    this.bankOrWallet,
    this.transactionDate,
    this.upiId,
  });

  final String? amount;
  final String? utr;
  final String? bankOrWallet;
  final String? transactionDate;
  final String? upiId;

  bool get hasAnyData =>
      amount != null ||
      utr != null ||
      bankOrWallet != null ||
      transactionDate != null ||
      upiId != null;

  Map<String, dynamic> toJson() => {
    'amount': amount,
    'utr': utr,
    'bankOrWallet': bankOrWallet,
    'transactionDate': transactionDate,
    'upiId': upiId,
  };

  factory ExtractedEvidenceData.fromJson(Map<String, dynamic> json) =>
      ExtractedEvidenceData(
        amount: json['amount'] as String?,
        utr: json['utr'] as String?,
        bankOrWallet: json['bankOrWallet'] as String?,
        transactionDate: json['transactionDate'] as String?,
        upiId: json['upiId'] as String?,
      );
}

/// A single piece of evidence added to the Evidence Vault.
///
/// The original file is never modified in place — extraction results are
/// stored separately in [extractedData].
class EvidenceItem {
  EvidenceItem({
    required this.id,
    required this.type,
    required this.category,
    required this.source,
    required this.createdAt,
    required this.originalFileName,
    required this.fileSizeBytes,
    required this.sha256Hash,
    this.filePath,
    this.description = '',
    this.userNotes = '',
    this.relatedIncidentId,
    this.extractedData,
    this.textContent,
  });

  final String id;
  final EvidenceType type;
  final EvidenceCategory category;

  /// Where this evidence came from, e.g. "Uploaded by user", "Safe Viewer capture".
  final String source;
  final DateTime createdAt;
  final String originalFileName;
  final int fileSizeBytes;
  final String sha256Hash;
  final String? filePath;
  final String description;
  final String userNotes;
  final String? relatedIncidentId;
  final ExtractedEvidenceData? extractedData;

  /// For text/URL evidence, the raw content itself.
  final String? textContent;

  EvidenceItem copyWith({
    String? description,
    String? userNotes,
    String? relatedIncidentId,
    ExtractedEvidenceData? extractedData,
  }) {
    return EvidenceItem(
      id: id,
      type: type,
      category: category,
      source: source,
      createdAt: createdAt,
      originalFileName: originalFileName,
      fileSizeBytes: fileSizeBytes,
      sha256Hash: sha256Hash,
      filePath: filePath,
      description: description ?? this.description,
      userNotes: userNotes ?? this.userNotes,
      relatedIncidentId: relatedIncidentId ?? this.relatedIncidentId,
      extractedData: extractedData ?? this.extractedData,
      textContent: textContent,
    );
  }

  String get formattedSize {
    if (fileSizeBytes < 1024) return '$fileSizeBytes B';
    if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'category': category.name,
    'source': source,
    'createdAt': createdAt.toIso8601String(),
    'originalFileName': originalFileName,
    'fileSizeBytes': fileSizeBytes,
    'sha256Hash': sha256Hash,
    'filePath': filePath,
    'description': description,
    'userNotes': userNotes,
    'relatedIncidentId': relatedIncidentId,
    'extractedData': extractedData?.toJson(),
    'textContent': textContent,
  };

  factory EvidenceItem.fromJson(Map<String, dynamic> json) => EvidenceItem(
    id: json['id'] as String,
    type: EvidenceType.values.byName(json['type'] as String),
    category: EvidenceCategory.values.byName(json['category'] as String),
    source: json['source'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    originalFileName: json['originalFileName'] as String,
    fileSizeBytes: json['fileSizeBytes'] as int,
    sha256Hash: json['sha256Hash'] as String,
    filePath: json['filePath'] as String?,
    description: json['description'] as String? ?? '',
    userNotes: json['userNotes'] as String? ?? '',
    relatedIncidentId: json['relatedIncidentId'] as String?,
    extractedData: json['extractedData'] == null
        ? null
        : ExtractedEvidenceData.fromJson(
            json['extractedData'] as Map<String, dynamic>,
          ),
    textContent: json['textContent'] as String?,
  );
}
