/// Centralized route path constants so screens never hand-type paths.
class AppRoutes {
  const AppRoutes._();

  static const String home = '/home';
  static const String protect = '/protect';
  static const String report = '/report';
  static const String cases = '/cases';
  static const String profile = '/profile';

  static const String linkGateway = '/protect/link-gateway';
  static const String linkChecker = '/protect/link-checker';
  static const String linkCheckerResult = '/protect/link-checker/result';
  static const String linkHistory = '/protect/link-history';
  static const String qrScanner = '/protect/qr-scanner';
  static const String safeViewer = '/protect/safe-viewer';
  static const String awareness = '/protect/awareness';

  static const String incidentCategory = '/report/category';
  static const String incidentForm = '/report/form';
  static const String incidentTimeline = '/report/timeline';
  static const String complaintReview = '/report/review';

  static const String caseDetail = '/cases/detail';

  static const String evidenceVault = '/evidence';
  static const String evidenceDetail = '/evidence/detail';

  static const String citizenProfileEdit = '/profile/edit';
  static const String identityDocuments = '/profile/documents';
  static const String socialIdentities = '/profile/social';
  static const String settings = '/profile/settings';

  static const String assistant = '/assistant';
  static const String notifications = '/notifications';

  static const String adminLogin = '/admin/login';
  static const String adminDashboard = '/admin/dashboard';
  static const String adminUsers = '/admin/users';
  static const String adminCases = '/admin/cases';
  static const String adminLinks = '/admin/links';
  static const String adminContent = '/admin/content';
  static const String adminSettings = '/admin/settings';
}
