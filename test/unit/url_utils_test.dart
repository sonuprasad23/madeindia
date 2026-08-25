import 'package:flutter_test/flutter_test.dart';
import 'package:rakshak/core/utils/url_utils.dart';

void main() {
  group('UrlUtils.normalize', () {
    test('adds a scheme when missing', () {
      final result = UrlUtils.normalize('example.com/page');
      expect(result, isNotNull);
      expect(result!.hadExplicitScheme, isFalse);
      expect(result.isHttps, isFalse);
      expect(result.domain, 'example.com');
    });

    test('preserves an explicit https scheme', () {
      final result = UrlUtils.normalize('https://Example.com/Login');
      expect(result, isNotNull);
      expect(result!.isHttps, isTrue);
      expect(result.domain, 'example.com');
    });

    test('returns null for empty input', () {
      expect(UrlUtils.normalize(''), isNull);
      expect(UrlUtils.normalize('   '), isNull);
    });

    test('returns null for a bare word with no dot and no scheme', () {
      expect(UrlUtils.normalize('notaurl'), isNull);
    });

    test('accepts a raw IP address as a host', () {
      final result = UrlUtils.normalize('192.168.1.1/admin');
      expect(result, isNotNull);
      expect(UrlUtils.isIpAddress(result!.domain), isTrue);
    });
  });

  group('UrlUtils helpers', () {
    test('detects punycode domains', () {
      expect(UrlUtils.isPunycode('xn--pypal-4ve.com'), isTrue);
      expect(UrlUtils.isPunycode('paypal.com'), isFalse);
    });

    test('counts hyphens only in the first label', () {
      expect(UrlUtils.hyphenCount('sbi-kyc-verify.com'), 2);
      expect(UrlUtils.hyphenCount('sbi.co.in'), 0);
    });

    test('computes subdomain depth', () {
      expect(UrlUtils.subdomainDepth('a.b.c.example.com'), 5);
      expect(UrlUtils.subdomainDepth('example.com'), 2);
    });

    test('extracts the top-level domain', () {
      expect(UrlUtils.topLevelDomain('example.xyz'), 'xyz');
      expect(UrlUtils.topLevelDomain('sbi.co.in'), 'in');
    });
  });
}
