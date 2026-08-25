import '../models/admin_models.dart';
import '../models/case_record.dart';
import '../models/citizen_profile.dart';
import '../models/incident.dart';
import '../models/notification_item.dart';
import '../models/risk_level.dart';
import '../models/threat_domain.dart';

/// Realistic (fictional) Indian demo data used to seed the app on first
/// launch. No real person's data is used anywhere here.
class DemoSeedData {
  const DemoSeedData._();

  static CitizenProfile citizenProfile() => CitizenProfile(
    id: 'user-ananya-sharma',
    name: 'Ananya Sharma',
    dateOfBirth: DateTime(1994, 3, 12),
    gender: 'Female',
    mobile: '9820012345',
    email: 'ananya.sharma@example.com',
    permanentAddress: '14, Sunder Nagar Society, Andheri West',
    currentAddress: '14, Sunder Nagar Society, Andheri West',
    state: 'Maharashtra',
    district: 'Mumbai Suburban',
    pincode: '400058',
    jurisdiction: const JurisdictionInfo(
      suggestedPoliceStation: 'Andheri Police Station, Mumbai Suburban',
      source: 'Based on your registered address (pincode 400058)',
    ),
  );

  static List<CaseRecord> cases() {
    final now = DateTime.now();
    return [
      CaseRecord(
        id: 'RKS-102394',
        category: IncidentCategory.upiFraud,
        createdAt: now.subtract(const Duration(days: 6)),
        status: CaseStatus.underInvestigation,
        amountInPaise: 5000000,
        state: 'Maharashtra',
        jurisdictionPoliceStation: 'Andheri Police Station, Mumbai Suburban',
        lastUpdated: now.subtract(const Duration(days: 1)),
        complaintId: 'NCRP-DEMO-88213',
        timeline: [
          CaseTimelineStep(
            status: CaseStatus.draft,
            occurredAt: now.subtract(const Duration(days: 6, hours: 2)),
          ),
          CaseTimelineStep(
            status: CaseStatus.submitted,
            occurredAt: now.subtract(const Duration(days: 6)),
          ),
          CaseTimelineStep(
            status: CaseStatus.forwarded,
            occurredAt: now.subtract(const Duration(days: 5)),
          ),
          CaseTimelineStep(
            status: CaseStatus.underReview,
            occurredAt: now.subtract(const Duration(days: 4)),
          ),
          CaseTimelineStep(
            status: CaseStatus.underInvestigation,
            occurredAt: now.subtract(const Duration(days: 1)),
            note: 'Demo status update from mock backend.',
          ),
        ],
      ),
      CaseRecord(
        id: 'RKS-102421',
        category: IncidentCategory.socialMediaHarassment,
        createdAt: now.subtract(const Duration(days: 3)),
        status: CaseStatus.additionalInfoRequired,
        state: 'Maharashtra',
        jurisdictionPoliceStation: 'Andheri Police Station, Mumbai Suburban',
        lastUpdated: now.subtract(const Duration(hours: 10)),
        complaintId: 'NCRP-DEMO-88401',
        timeline: [
          CaseTimelineStep(
            status: CaseStatus.draft,
            occurredAt: now.subtract(const Duration(days: 3, hours: 1)),
          ),
          CaseTimelineStep(
            status: CaseStatus.submitted,
            occurredAt: now.subtract(const Duration(days: 3)),
          ),
          CaseTimelineStep(
            status: CaseStatus.forwarded,
            occurredAt: now.subtract(const Duration(days: 2)),
          ),
          CaseTimelineStep(
            status: CaseStatus.additionalInfoRequired,
            occurredAt: now.subtract(const Duration(hours: 10)),
            note: 'Demo system requests a screenshot of the reported profile.',
          ),
        ],
      ),
    ];
  }

  static List<NotificationItem> notifications() {
    final now = DateTime.now();
    return [
      NotificationItem(
        id: 'n1',
        kind: NotificationKind.caseStatusChanged,
        title: 'Case RKS-102421 updated',
        body:
            'Additional information has been requested for your Instagram harassment case.',
        createdAt: now.subtract(const Duration(hours: 10)),
      ),
      NotificationItem(
        id: 'n2',
        kind: NotificationKind.linkChecked,
        title: 'Link checked',
        body: 'hdfc-bank-alert.info was flagged as a dangerous link.',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      NotificationItem(
        id: 'n3',
        kind: NotificationKind.evidenceSaved,
        title: 'Evidence saved',
        body: 'A screenshot was added to your Evidence Vault.',
        createdAt: now.subtract(const Duration(days: 2)),
        read: true,
      ),
    ];
  }

  static List<ThreatDomainRecord> threatDomains() {
    final now = DateTime.now();
    return [
      ThreatDomainRecord(
        domain: 'sbi-verify-kyc.com',
        status: RiskLevel.dangerous,
        reason: 'Demo phishing campaign impersonating SBI KYC verification.',
        lastUpdated: now.subtract(const Duration(days: 12)),
        reportCount: 129,
        checkCount: 842,
      ),
      ThreatDomainRecord(
        domain: 'paytm-cashback-offer.xyz',
        status: RiskLevel.dangerous,
        reason: 'Demo phishing campaign offering fake cashback.',
        lastUpdated: now.subtract(const Duration(days: 4)),
        reportCount: 76,
        checkCount: 310,
      ),
      ThreatDomainRecord(
        domain: 'flipkart.com',
        status: RiskLevel.safe,
        reason: 'Established e-commerce domain in demo reference data.',
        lastUpdated: now.subtract(const Duration(days: 40)),
        reportCount: 0,
        checkCount: 5321,
      ),
    ];
  }

  static List<AdminUserSummary> adminUsers() {
    final now = DateTime.now();
    return [
      AdminUserSummary(
        id: 'user-ananya-sharma',
        name: 'Ananya Sharma',
        mobileMasked: '98200XXXXX',
        state: 'Maharashtra',
        joinedAt: now.subtract(const Duration(days: 120)),
        caseCount: 2,
        active: true,
      ),
      AdminUserSummary(
        id: 'user-rahul-patel',
        name: 'Rahul Patel',
        mobileMasked: '90040XXXXX',
        state: 'Gujarat',
        joinedAt: now.subtract(const Duration(days: 88)),
        caseCount: 1,
        active: true,
      ),
      AdminUserSummary(
        id: 'user-aarav-mehta',
        name: 'Aarav Mehta',
        mobileMasked: '99880XXXXX',
        state: 'Delhi (NCT)',
        joinedAt: now.subtract(const Duration(days: 45)),
        caseCount: 0,
        active: true,
      ),
      AdminUserSummary(
        id: 'user-priya-shah',
        name: 'Priya Shah',
        mobileMasked: '98765XXXXX',
        state: 'Karnataka',
        joinedAt: now.subtract(const Duration(days: 200)),
        caseCount: 3,
        active: false,
      ),
    ];
  }

  static List<ContentArticle> contentArticles() {
    final now = DateTime.now();
    return [
      ContentArticle(
        id: 'a1',
        title: 'What to do immediately after a UPI fraud',
        category: 'Financial Fraud',
        body:
            'Contact your bank to block further transactions, note the transaction UTR number, '
            'call the national cyber helpline 1930, and preserve screenshots of the transaction.',
        languageCode: 'en',
        updatedAt: now.subtract(const Duration(days: 15)),
      ),
      ContentArticle(
        id: 'a2',
        title: 'Spotting a phishing message',
        category: 'Phishing',
        body:
            'Be cautious of urgent language, mismatched sender addresses, and links that ask you '
            'to "verify" or "update" account details.',
        languageCode: 'en',
        updatedAt: now.subtract(const Duration(days: 30)),
      ),
    ];
  }
}
