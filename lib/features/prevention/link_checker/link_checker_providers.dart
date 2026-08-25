import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/admin_repository.dart';
import 'link_analysis_service.dart';
import 'link_risk_engine.dart';

final linkRiskEngineProvider = Provider<LinkRiskEngine>((ref) {
  final thresholds = ref.watch(riskThresholdsProvider);
  return LinkRiskEngine(thresholds: thresholds);
});

final linkAnalysisServiceProvider = Provider<LinkAnalysisService>((ref) {
  return DemoLinkAnalysisService(
    engine: ref.watch(linkRiskEngineProvider),
    adminOverridesProvider: () => readThreatDomainOverrides(ref),
  );
});
