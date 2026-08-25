/// Cross-cutting app constants and mandatory disclaimer copy.
///
/// [demoDisclaimer] must be surfaced anywhere the app could otherwise be
/// mistaken for a real government/police/bank system.
class AppConstants {
  const AppConstants._();

  static const String caseIdPrefix = 'RKS';
  static const int minIncidentDescriptionLength = 200;

  static const String demoDisclaimer =
      'Rakshak is a demo/prototype. No data on this screen is submitted to '
      'the real National Cyber Crime Reporting Portal, any police authority, '
      'or any bank. This is DEMO DATA for illustration only.';

  static const String demoThreatIntelLabel = 'Demo Threat Intelligence';
  static const String extractedFromEvidenceLabel =
      'Extracted from evidence — please verify';
  static const String aiAssistedLabel =
      'AI-assisted explanation — review required';
}
