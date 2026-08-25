enum IdentityDocumentType {
  aadhaar,
  pan,
  drivingLicence,
  voterId,
  passport,
  other,
}

extension IdentityDocumentTypeX on IdentityDocumentType {
  String get label => switch (this) {
    IdentityDocumentType.aadhaar => 'Aadhaar',
    IdentityDocumentType.pan => 'PAN',
    IdentityDocumentType.drivingLicence => 'Driving Licence',
    IdentityDocumentType.voterId => 'Voter ID',
    IdentityDocumentType.passport => 'Passport',
    IdentityDocumentType.other => 'Other',
  };
}

enum DocumentSource { userProvided, digiLocker }

class IdentityDocument {
  const IdentityDocument({
    required this.type,
    required this.source,
    this.filePath,
    this.verified = false,
  });

  final IdentityDocumentType type;
  final DocumentSource source;
  final String? filePath;
  final bool verified;

  String get sourceLabel =>
      source == DocumentSource.digiLocker ? 'DigiLocker' : 'User provided';

  String get verificationLabel => verified ? 'Verified source' : 'Not verified';

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'source': source.name,
    'filePath': filePath,
    'verified': verified,
  };

  factory IdentityDocument.fromJson(Map<String, dynamic> json) =>
      IdentityDocument(
        type: IdentityDocumentType.values.byName(json['type'] as String),
        source: DocumentSource.values.byName(json['source'] as String),
        filePath: json['filePath'] as String?,
        verified: json['verified'] as bool? ?? false,
      );
}

enum SocialPlatform { instagram, facebook, x, whatsapp, telegram, email, phone }

extension SocialPlatformX on SocialPlatform {
  String get label => switch (this) {
    SocialPlatform.instagram => 'Instagram',
    SocialPlatform.facebook => 'Facebook',
    SocialPlatform.x => 'X (Twitter)',
    SocialPlatform.whatsapp => 'WhatsApp',
    SocialPlatform.telegram => 'Telegram',
    SocialPlatform.email => 'Email',
    SocialPlatform.phone => 'Phone',
  };
}

class SocialIdentity {
  const SocialIdentity({
    required this.platform,
    required this.username,
    this.profileUrl,
    this.verified = false,
    this.notes = '',
  });

  final SocialPlatform platform;
  final String username;
  final String? profileUrl;
  final bool verified;
  final String notes;

  Map<String, dynamic> toJson() => {
    'platform': platform.name,
    'username': username,
    'profileUrl': profileUrl,
    'verified': verified,
    'notes': notes,
  };

  factory SocialIdentity.fromJson(Map<String, dynamic> json) => SocialIdentity(
    platform: SocialPlatform.values.byName(json['platform'] as String),
    username: json['username'] as String,
    profileUrl: json['profileUrl'] as String?,
    verified: json['verified'] as bool? ?? false,
    notes: json['notes'] as String? ?? '',
  );
}

enum JurisdictionConfirmationStatus { suggested, confirmed }

class JurisdictionInfo {
  const JurisdictionInfo({
    required this.suggestedPoliceStation,
    required this.source,
    this.status = JurisdictionConfirmationStatus.suggested,
  });

  final String suggestedPoliceStation;
  final String source;
  final JurisdictionConfirmationStatus status;

  JurisdictionInfo copyWith({JurisdictionConfirmationStatus? status}) =>
      JurisdictionInfo(
        suggestedPoliceStation: suggestedPoliceStation,
        source: source,
        status: status ?? this.status,
      );

  Map<String, dynamic> toJson() => {
    'suggestedPoliceStation': suggestedPoliceStation,
    'source': source,
    'status': status.name,
  };

  factory JurisdictionInfo.fromJson(Map<String, dynamic> json) =>
      JurisdictionInfo(
        suggestedPoliceStation: json['suggestedPoliceStation'] as String,
        source: json['source'] as String,
        status: JurisdictionConfirmationStatus.values.byName(
          json['status'] as String,
        ),
      );
}

/// The reusable citizen profile — filled in once, reused across incident
/// reports so the user never has to retype identity/address details.
class CitizenProfile {
  const CitizenProfile({
    required this.id,
    required this.name,
    this.dateOfBirth,
    this.gender,
    this.mobile = '',
    this.email = '',
    this.permanentAddress = '',
    this.currentAddress = '',
    this.state = '',
    this.district = '',
    this.pincode = '',
    this.country = 'India',
    this.jurisdiction,
    this.identityDocuments = const [],
    this.socialIdentities = const [],
  });

  final String id;
  final String name;
  final DateTime? dateOfBirth;
  final String? gender;
  final String mobile;
  final String email;
  final String permanentAddress;
  final String currentAddress;
  final String state;
  final String district;
  final String pincode;
  final String country;
  final JurisdictionInfo? jurisdiction;
  final List<IdentityDocument> identityDocuments;
  final List<SocialIdentity> socialIdentities;

  bool get isComplete =>
      name.isNotEmpty && mobile.isNotEmpty && pincode.isNotEmpty;

  CitizenProfile copyWith({
    String? name,
    DateTime? dateOfBirth,
    String? gender,
    String? mobile,
    String? email,
    String? permanentAddress,
    String? currentAddress,
    String? state,
    String? district,
    String? pincode,
    JurisdictionInfo? jurisdiction,
    List<IdentityDocument>? identityDocuments,
    List<SocialIdentity>? socialIdentities,
  }) {
    return CitizenProfile(
      id: id,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      permanentAddress: permanentAddress ?? this.permanentAddress,
      currentAddress: currentAddress ?? this.currentAddress,
      state: state ?? this.state,
      district: district ?? this.district,
      pincode: pincode ?? this.pincode,
      country: country,
      jurisdiction: jurisdiction ?? this.jurisdiction,
      identityDocuments: identityDocuments ?? this.identityDocuments,
      socialIdentities: socialIdentities ?? this.socialIdentities,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'dateOfBirth': dateOfBirth?.toIso8601String(),
    'gender': gender,
    'mobile': mobile,
    'email': email,
    'permanentAddress': permanentAddress,
    'currentAddress': currentAddress,
    'state': state,
    'district': district,
    'pincode': pincode,
    'country': country,
    'jurisdiction': jurisdiction?.toJson(),
    'identityDocuments': identityDocuments.map((d) => d.toJson()).toList(),
    'socialIdentities': socialIdentities.map((s) => s.toJson()).toList(),
  };

  factory CitizenProfile.fromJson(Map<String, dynamic> json) => CitizenProfile(
    id: json['id'] as String,
    name: json['name'] as String,
    dateOfBirth: json['dateOfBirth'] == null
        ? null
        : DateTime.parse(json['dateOfBirth'] as String),
    gender: json['gender'] as String?,
    mobile: json['mobile'] as String? ?? '',
    email: json['email'] as String? ?? '',
    permanentAddress: json['permanentAddress'] as String? ?? '',
    currentAddress: json['currentAddress'] as String? ?? '',
    state: json['state'] as String? ?? '',
    district: json['district'] as String? ?? '',
    pincode: json['pincode'] as String? ?? '',
    country: json['country'] as String? ?? 'India',
    jurisdiction: json['jurisdiction'] == null
        ? null
        : JurisdictionInfo.fromJson(
            json['jurisdiction'] as Map<String, dynamic>,
          ),
    identityDocuments: (json['identityDocuments'] as List? ?? [])
        .map((d) => IdentityDocument.fromJson(d as Map<String, dynamic>))
        .toList(),
    socialIdentities: (json['socialIdentities'] as List? ?? [])
        .map((s) => SocialIdentity.fromJson(s as Map<String, dynamic>))
        .toList(),
  );
}
