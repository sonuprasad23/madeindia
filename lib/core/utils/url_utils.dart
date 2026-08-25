/// Result of normalizing raw user/shared input into a checkable URL.
class NormalizedUrl {
  const NormalizedUrl({
    required this.uri,
    required this.domain,
    required this.isHttps,
    required this.hadExplicitScheme,
  });

  final Uri uri;
  final String domain;
  final bool isHttps;
  final bool hadExplicitScheme;
}

/// URL normalization used before analysis. Kept separate from the risk
/// engine and covered directly by unit tests.
class UrlUtils {
  const UrlUtils._();

  static const List<String> _knownSchemes = ['http', 'https'];

  /// Returns null if [raw] cannot be interpreted as a URL at all.
  static NormalizedUrl? normalize(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    final hasScheme = RegExp(r'^[a-zA-Z][a-zA-Z0-9+\-.]*://').hasMatch(trimmed);
    final candidate = hasScheme ? trimmed : 'http://$trimmed';

    final uri = Uri.tryParse(candidate);
    if (uri == null || uri.host.isEmpty) return null;
    if (hasScheme && !_knownSchemes.contains(uri.scheme.toLowerCase())) {
      return null;
    }
    if (!uri.host.contains('.') && !isIpAddress(uri.host)) return null;

    return NormalizedUrl(
      uri: uri,
      domain: uri.host.toLowerCase(),
      isHttps: uri.scheme.toLowerCase() == 'https',
      hadExplicitScheme: hasScheme,
    );
  }

  static bool isIpAddress(String host) {
    final ipv4 = RegExp(r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$');
    return ipv4.hasMatch(host);
  }

  static bool isPunycode(String domain) =>
      domain.split('.').any((label) => label.startsWith('xn--'));

  static int subdomainDepth(String domain) => domain.split('.').length;

  static int hyphenCount(String domain) =>
      domain.split('.').first.split('-').length - 1;

  static const List<String> suspiciousTlds = [
    'xyz',
    'top',
    'tk',
    'club',
    'info',
    'win',
    'loan',
    'click',
    'work',
    'gq',
    'cf',
    'ml',
  ];

  static String? topLevelDomain(String domain) {
    final parts = domain.split('.');
    if (parts.length < 2) return null;
    return parts.last;
  }
}
