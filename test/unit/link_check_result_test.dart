import 'package:flutter_test/flutter_test.dart';
import 'package:rakshak/data/models/link_check_result.dart';
import 'package:rakshak/data/models/risk_level.dart';

void main() {
  group('RiskLevel.description', () {
    test('matches the required conservative wording for each level', () {
      expect(RiskLevel.safe.description, 'No known threats detected.');
      expect(
        RiskLevel.suspicious.description,
        'This URL contains indicators commonly associated with suspicious activity.',
      );
      expect(
        RiskLevel.dangerous.description,
        'Known or strongly suspected malicious activity was detected.',
      );
      expect(
        RiskLevel.unknown.description,
        'We could not establish sufficient information about this URL.',
      );
    });

    test('never claims certainty', () {
      const bannedPhrases = [
        '100%',
        'guarantee',
        'definitely',
        'completely safe',
      ];
      for (final level in RiskLevel.values) {
        final lower = level.description.toLowerCase();
        for (final phrase in bannedPhrases) {
          expect(
            lower.contains(phrase),
            isFalse,
            reason: '${level.name} description contains "$phrase"',
          );
        }
      }
    });
  });

  group('LinkUserAction', () {
    test('every action has a non-empty label', () {
      for (final action in LinkUserAction.values) {
        expect(action.label, isNotEmpty);
      }
    });
  });

  group('LinkCheckResult', () {
    LinkCheckResult buildResult() => LinkCheckResult(
      id: 'link-1',
      originalUrl: 'suspicious-site.xyz/login',
      normalizedUrl: 'http://suspicious-site.xyz/login',
      domain: 'suspicious-site.xyz',
      riskLevel: RiskLevel.suspicious,
      riskScore: 45,
      indicators: const [
        ThreatIndicator(label: 'Uncommon TLD', detail: 'Detail text'),
      ],
      isHttps: false,
      checkedAt: DateTime(2026, 8, 24, 9, 0),
      sourceApp: 'WhatsApp',
    );

    test('copyWith only changes userAction and preserves everything else', () {
      final original = buildResult();
      final updated = original.copyWith(
        userAction: LinkUserAction.viewedSafely,
      );

      expect(updated.userAction, LinkUserAction.viewedSafely);
      expect(updated.sourceApp, 'WhatsApp');
      expect(updated.domain, original.domain);
      expect(updated.riskLevel, original.riskLevel);
    });

    test('round-trips sourceApp and userAction through JSON', () {
      final original = buildResult().copyWith(
        userAction: LinkUserAction.openedAnyway,
      );
      final restored = LinkCheckResult.fromJson(original.toJson());

      expect(restored.sourceApp, 'WhatsApp');
      expect(restored.userAction, LinkUserAction.openedAnyway);
      expect(restored.originalUrl, original.originalUrl);
    });

    test('a result with no recorded action round-trips userAction as null', () {
      final restored = LinkCheckResult.fromJson(buildResult().toJson());
      expect(restored.userAction, isNull);
    });
  });
}
