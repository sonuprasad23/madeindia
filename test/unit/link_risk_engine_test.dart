import 'package:flutter_test/flutter_test.dart';
import 'package:rakshak/core/utils/url_utils.dart';
import 'package:rakshak/data/models/risk_level.dart';
import 'package:rakshak/features/prevention/link_checker/link_risk_engine.dart';

void main() {
  const engine = LinkRiskEngine();

  RiskAssessment assess(String url) {
    final normalized = UrlUtils.normalize(url)!;
    return engine.assess(normalized);
  }

  group('LinkRiskEngine.assess', () {
    test('is deterministic: same input always yields the same output', () {
      final a = assess('https://sbi-verify-kyc.com/login');
      final b = assess('https://sbi-verify-kyc.com/login');
      expect(a.score, b.score);
      expect(a.level, b.level);
    });

    test('classifies a known demo-malicious domain as dangerous', () {
      final result = assess('https://sbi-verify-kyc.com/login');
      expect(result.level, RiskLevel.dangerous);
    });

    test('classifies a well-known safe domain as safe', () {
      final result = assess('https://www.wikipedia.org/wiki/Cybersecurity');
      expect(result.level, RiskLevel.safe);
    });

    test('flags a raw IP address URL as at least suspicious', () {
      final result = assess('http://192.168.10.5/verify-login');
      expect(result.score, greaterThan(0));
      expect(result.level, isNot(RiskLevel.safe));
    });

    test('penalizes missing HTTPS', () {
      final httpResult = assess('http://example-shop.com');
      final httpsResult = assess('https://example-shop.com');
      expect(httpResult.score, greaterThanOrEqualTo(httpsResult.score));
    });

    test('every negative indicator has a non-empty explanation', () {
      final result = assess('https://sbi-verify-kyc-update.xyz/secure/login');
      for (final indicator in result.indicators.where((i) => !i.isPositive)) {
        expect(indicator.label, isNotEmpty);
        expect(indicator.detail, isNotEmpty);
      }
    });
  });
}
