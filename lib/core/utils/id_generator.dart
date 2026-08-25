import 'dart:math';

import '../constants/app_constants.dart';

/// Generates display identifiers that look like real case/complaint
/// numbers for demo purposes. These are NOT issued by any real system —
/// see [AppConstants.demoDisclaimer].
class IdGenerator {
  const IdGenerator._();

  static final Random _random = Random();

  static String caseId() {
    final n = 100000 + _random.nextInt(899999);
    return '${AppConstants.caseIdPrefix}-$n';
  }

  static String ncrpDemoComplaintId() {
    final n = 10000 + _random.nextInt(89999);
    return 'NCRP-DEMO-$n';
  }
}
