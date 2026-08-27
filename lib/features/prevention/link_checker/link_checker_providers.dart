import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/backend_config.dart';
import '../../../core/services/feature_flags_controller.dart';
import '../../../data/repositories/admin_repository.dart';
import 'backend_proxy_threat_intelligence_provider.dart';
import 'link_analysis_service.dart';
import 'link_risk_engine.dart';
import 'threat_intelligence_provider.dart';

final linkRiskEngineProvider = Provider<LinkRiskEngine>((ref) {
  final thresholds = ref.watch(riskThresholdsProvider);
  return LinkRiskEngine(thresholds: thresholds);
});

/// Disabled unless BOTH the "Real Threat Intelligence" admin feature flag
/// is on AND a backend proxy URL has been configured at build time — see
/// [BackendConfig.threatIntelBackendUrl].
final threatIntelligenceProviderProvider = Provider<ThreatIntelligenceProvider>(
  (ref) {
    final flags = ref.watch(featureFlagsProvider);
    if (!flags.realThreatIntelligence ||
        BackendConfig.threatIntelBackendUrl.isEmpty) {
      return const DisabledThreatIntelligenceProvider();
    }
    return BackendProxyThreatIntelligenceProvider(
      baseUrl: BackendConfig.threatIntelBackendUrl,
    );
  },
);

final linkAnalysisServiceProvider = Provider<LinkAnalysisService>((ref) {
  return DemoLinkAnalysisService(
    engine: ref.watch(linkRiskEngineProvider),
    adminOverridesProvider: () => readThreatDomainOverrides(ref),
    threatIntelligenceProvider: ref.watch(threatIntelligenceProviderProvider),
  );
});
