import 'package:flutter_test/flutter_test.dart';
import 'package:rakshak/data/models/link_check_result.dart';
import 'package:rakshak/data/models/risk_level.dart';
import 'package:rakshak/features/prevention/link_checker/link_analysis_service.dart';
import 'package:rakshak/features/prevention/link_checker/threat_intelligence_provider.dart';

class _FakeThreatIntelProvider implements ThreatIntelligenceProvider {
  _FakeThreatIntelProvider(this.result);
  final ThreatIntelLookupResult? result;

  @override
  Future<ThreatIntelLookupResult?> lookup({
    required String domain,
    required String normalizedUrl,
  }) async => result;
}

void main() {
  group('DemoLinkAnalysisService', () {
    test(
      'with the disabled provider, behaves exactly like local rules alone',
      () async {
        final service = DemoLinkAnalysisService(
          threatIntelligenceProvider:
              const DisabledThreatIntelligenceProvider(),
        );
        final result = await service.checkUrl('https://example-shop.com');
        expect(
          result.indicators.any(
            (i) => i.label.toLowerCase().contains('threat intelligence'),
          ),
          isFalse,
        );
      },
    );

    test(
      'a matching external provider escalates a local "safe" verdict to dangerous',
      () async {
        final service = DemoLinkAnalysisService(
          threatIntelligenceProvider: _FakeThreatIntelProvider(
            const ThreatIntelLookupResult(
              level: RiskLevel.dangerous,
              indicator: ThreatIndicator(
                label: 'Threat intelligence match',
                detail: 'Matched a demo backend record.',
              ),
            ),
          ),
        );
        final result = await service.checkUrl('https://wikipedia.org');

        expect(result.riskLevel, RiskLevel.dangerous);
        expect(
          result.indicators.any((i) => i.label == 'Threat intelligence match'),
          isTrue,
        );
      },
    );

    test('a null lookup result never changes the local verdict', () async {
      final service = DemoLinkAnalysisService(
        threatIntelligenceProvider: _FakeThreatIntelProvider(null),
      );
      final result = await service.checkUrl('https://wikipedia.org');
      expect(result.riskLevel, RiskLevel.safe);
    });

    test('sourceApp flows through into the result', () async {
      final service = DemoLinkAnalysisService(
        threatIntelligenceProvider: const DisabledThreatIntelligenceProvider(),
      );
      final result = await service.checkUrl(
        'https://example.com',
        sourceApp: 'WhatsApp',
      );
      expect(result.sourceApp, 'WhatsApp');
    });
  });
}
