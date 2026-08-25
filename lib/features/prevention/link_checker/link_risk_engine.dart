import '../../../core/utils/url_utils.dart';
import '../../../data/models/admin_models.dart';
import '../../../data/models/link_check_result.dart';
import '../../../data/models/risk_level.dart';
import '../../../data/models/threat_domain.dart';

/// Outcome of the deterministic scoring pass, before it is turned into a
/// [LinkCheckResult] by [LinkAnalysisService].
class RiskAssessment {
  const RiskAssessment({
    required this.score,
    required this.indicators,
    required this.level,
  });

  final int score;
  final List<ThreatIndicator> indicators;
  final RiskLevel level;
}

/// Curated demo threat-intelligence lists.
///
/// These are illustrative only — labelled everywhere in the UI as
/// "Demo Threat Intelligence" — and are exactly the kind of thing that
/// would be swapped for a real feed via [AdminLinkRepository] later.
class DemoThreatIntel {
  const DemoThreatIntel._();

  static const List<String> knownSafeDomains = [
    'google.com',
    'wikipedia.org',
    'github.com',
    'microsoft.com',
    'apple.com',
    'sbi.co.in',
    'onlinesbi.sbi',
    'hdfcbank.com',
    'icicibank.com',
    'axisbank.com',
    'uidai.gov.in',
    'incometax.gov.in',
    'npci.org.in',
    'rbi.org.in',
    'digilocker.gov.in',
    'amazon.in',
    'flipkart.com',
    'paytm.com',
    'phonepe.com',
    'whatsapp.com',
    'instagram.com',
    'facebook.com',
    'x.com',
    'cybercrime.gov.in',
  ];

  static const Map<String, String> knownMaliciousDomains = {
    'sbi-verify-kyc.com':
        'Reported in demo threat feed for SBI KYC phishing template',
    'paytm-cashback-offer.xyz':
        'Reported in demo threat feed for fake cashback phishing',
    'hdfc-bank-alert.info':
        'Reported in demo threat feed for HDFC account-alert phishing',
    'amaz0n-rewards.com':
        'Reported in demo threat feed for brand-impersonation phishing',
    'whatsapp-verify-account.net':
        'Reported in demo threat feed for account-takeover phishing',
    'income-tax-refund-claim.co':
        'Reported in demo threat feed for tax-refund phishing',
    'win-lottery-claim.top':
        'Reported in demo threat feed for lottery-scam phishing',
    'kbc-lucky-winner.club':
        'Reported in demo threat feed for KBC lottery-scam phishing',
  };

  static const List<String> brandKeywords = [
    'sbi',
    'hdfc',
    'icici',
    'axis',
    'paytm',
    'phonepe',
    'amazon',
    'google',
    'whatsapp',
    'instagram',
    'facebook',
    'incometax',
    'kbc',
    'lottery',
    'rbi',
    'npci',
  ];

  static const List<String> suspiciousKeywords = [
    'verify',
    'kyc',
    'login',
    'secure',
    'update',
    'confirm',
    'refund',
    'prize',
    'winner',
    'urgent',
    'block',
    'suspend',
    'reward',
    'claim',
    'cashback',
  ];

  /// Deterministic "recently registered" simulation: a fixed set of
  /// domains explicitly marked aged/trusted are exempt; anything else that
  /// mixes digits/hyphens with a brand keyword is treated as recently
  /// registered for demo purposes.
  static bool looksRecentlyRegistered(String domain) {
    if (knownSafeDomains.contains(bareDomain(domain))) return false;
    final hasDigit = RegExp(r'\d').hasMatch(domain);
    final hasHyphen = domain.contains('-');
    return hasDigit || hasHyphen;
  }

  /// Strips a leading "www." so demo reference lists don't need a
  /// separate entry for the www-prefixed form of every domain.
  static String bareDomain(String domain) =>
      domain.startsWith('www.') ? domain.substring(4) : domain;
}

/// Pure, deterministic URL risk scoring. No randomness — every input maps
/// to the same output every time, which is what makes this testable and
/// explainable to the user.
class LinkRiskEngine {
  const LinkRiskEngine({this.thresholds = const RiskThresholds()});

  final RiskThresholds thresholds;

  RiskAssessment assess(
    NormalizedUrl url, {
    List<ThreatDomainRecord> adminOverrides = const [],
  }) {
    final domain = url.domain;
    final bareDomain = DemoThreatIntel.bareDomain(domain);
    final indicators = <ThreatIndicator>[];
    var score = 0;

    final override = adminOverrides
        .where((r) => r.domain == bareDomain)
        .firstOrNull;
    if (override != null) {
      indicators.add(
        ThreatIndicator(
          label: 'Admin-reviewed domain record',
          detail: override.reason,
        ),
      );
      final level = override.status;
      return RiskAssessment(
        score: level == RiskLevel.dangerous
            ? 95
            : (level == RiskLevel.suspicious ? 50 : 5),
        indicators: indicators,
        level: level,
      );
    }

    if (DemoThreatIntel.knownMaliciousDomains.containsKey(bareDomain)) {
      indicators.add(
        ThreatIndicator(
          label: 'Matches known malicious demo record',
          detail: DemoThreatIntel.knownMaliciousDomains[bareDomain]!,
        ),
      );
      return RiskAssessment(
        score: 95,
        indicators: indicators,
        level: RiskLevel.dangerous,
      );
    }

    final isKnownSafe = DemoThreatIntel.knownSafeDomains.contains(bareDomain);

    if (UrlUtils.isIpAddress(domain)) {
      score += 30;
      indicators.add(
        const ThreatIndicator(
          label: 'Raw IP address',
          detail:
              'This link uses a numeric IP address instead of a domain name, a pattern rarely used by legitimate services.',
        ),
      );
    }

    if (UrlUtils.isPunycode(domain)) {
      score += 25;
      indicators.add(
        const ThreatIndicator(
          label: 'Punycode domain',
          detail:
              'This domain uses punycode encoding, which can be used to visually impersonate another domain.',
        ),
      );
    }

    final tld = UrlUtils.topLevelDomain(domain);
    if (tld != null && UrlUtils.suspiciousTlds.contains(tld) && !isKnownSafe) {
      score += 15;
      indicators.add(
        ThreatIndicator(
          label: 'Uncommon top-level domain (.$tld)',
          detail:
              'This top-level domain is frequently associated with low-cost, short-lived phishing campaigns in demo threat data.',
        ),
      );
    }

    if (url.uri.toString().length > 90) {
      score += 10;
      indicators.add(
        const ThreatIndicator(
          label: 'Unusually long URL',
          detail:
              'Long URLs are sometimes used to obscure the true destination.',
        ),
      );
    }

    if (UrlUtils.subdomainDepth(domain) >= 4 && !isKnownSafe) {
      score += 10;
      indicators.add(
        const ThreatIndicator(
          label: 'Multiple nested subdomains',
          detail:
              'A deeply nested subdomain structure can be used to make a URL look more official than it is.',
        ),
      );
    }

    if (UrlUtils.hyphenCount(domain) >= 2 && !isKnownSafe) {
      score += 10;
      indicators.add(
        const ThreatIndicator(
          label: 'Multiple hyphens in domain',
          detail:
              'Domains with several hyphens are a common phishing pattern used to mimic brand names.',
        ),
      );
    }

    final matchedBrand = DemoThreatIntel.brandKeywords
        .where((b) => domain.contains(b))
        .where((_) => !isKnownSafe)
        .firstOrNull;
    if (matchedBrand != null) {
      score += 30;
      indicators.add(
        ThreatIndicator(
          label: 'Possible brand impersonation',
          detail:
              'This domain resembles "$matchedBrand" but is not on the list of that brand\'s official domains.',
        ),
      );
    }

    final path = '${url.uri.path}?${url.uri.query}'.toLowerCase();
    final matchedKeywords = DemoThreatIntel.suspiciousKeywords
        .where((k) => path.contains(k))
        .take(3);
    if (matchedKeywords.isNotEmpty) {
      score += 10;
      indicators.add(
        ThreatIndicator(
          label: 'Login/verification-related URL',
          detail:
              'The URL path contains terms often used in credential-harvesting pages: ${matchedKeywords.join(', ')}.',
        ),
      );
    }

    if (!url.isHttps) {
      score += 10;
      indicators.add(
        const ThreatIndicator(
          label: 'Not using HTTPS',
          detail:
              'This connection is not encrypted, which makes it easier to intercept submitted data.',
        ),
      );
    } else {
      indicators.add(
        const ThreatIndicator(
          label: 'HTTPS present',
          detail: 'The connection to this domain is encrypted.',
          isPositive: true,
        ),
      );
    }

    if (!isKnownSafe &&
        DemoThreatIntel.looksRecentlyRegistered(domain) &&
        matchedBrand != null) {
      score += 15;
      indicators.add(
        const ThreatIndicator(
          label: 'Domain age unknown / possibly new',
          detail:
              'Demo registration data suggests this domain may be recently registered, which is common for short-lived phishing sites.',
        ),
      );
    }

    if (isKnownSafe) {
      score = (score - 40).clamp(0, 100);
      indicators.add(
        const ThreatIndicator(
          label: 'Recognized domain',
          detail:
              'This domain matches a widely recognized, established organization in demo reference data.',
          isPositive: true,
        ),
      );
    }

    RiskLevel level;
    if (score >= thresholds.dangerousAt) {
      level = RiskLevel.dangerous;
    } else if (score >= thresholds.suspiciousAt) {
      level = RiskLevel.suspicious;
    } else if (isKnownSafe || url.isHttps) {
      level = RiskLevel.safe;
    } else {
      level = RiskLevel.unknown;
    }

    return RiskAssessment(
      score: score.clamp(0, 100),
      indicators: indicators,
      level: level,
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
