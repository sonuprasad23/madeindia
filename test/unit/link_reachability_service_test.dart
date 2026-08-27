import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rakshak/data/models/risk_level.dart';
import 'package:rakshak/features/prevention/link_checker/link_reachability_service.dart';

void main() {
  group('LinkReachabilityService', () {
    test('a dangerous URL is never actually connected to', () async {
      var called = false;
      final service = LinkReachabilityService(
        client: MockClient((request) async {
          called = true;
          return http.Response('', 200);
        }),
      );

      final status = await service.check(
        'https://known-bad.example',
        RiskLevel.dangerous,
      );

      expect(status, ReachabilityStatus.skippedDangerous);
      expect(called, isFalse);
    });

    test(
      'any HTTP response (even an error status) counts as reachable',
      () async {
        final service = LinkReachabilityService(
          client: MockClient((request) async => http.Response('', 404)),
        );

        final status = await service.check(
          'https://example.com/missing',
          RiskLevel.safe,
        );

        expect(status, ReachabilityStatus.reachable);
      },
    );

    test('a network exception is reported as unreachable', () async {
      final service = LinkReachabilityService(
        client: MockClient(
          (request) async => throw Exception('no route to host'),
        ),
      );

      final status = await service.check(
        'https://unreachable.example',
        RiskLevel.unknown,
      );

      expect(status, ReachabilityStatus.unreachable);
    });
  });
}
