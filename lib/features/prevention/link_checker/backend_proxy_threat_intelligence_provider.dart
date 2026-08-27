import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../data/models/link_check_result.dart';
import '../../../data/models/risk_level.dart';
import 'threat_intelligence_provider.dart';

/// Real HTTP client for a backend-proxied threat-intelligence lookup.
///
/// IMPORTANT — this is wiring, not a live integration: [baseUrl] is empty
/// by default (see `THREAT_INTEL_BACKEND_URL` in `.env.example`), and this
/// repository does not include or deploy that backend. It exists so a real
/// deployment is "point this at your proxy", not "rewrite the app".
///
/// This class deliberately never talks to URLhaus/VirusTotal/etc.
/// directly: both currently require a secret API key (URLhaus an Auth-Key
/// header, VirusTotal a per-account key with a strict non-commercial rate
/// limit), and a mobile app must never hold or transmit that key itself —
/// see README's "Threat intelligence limitations" section. The expected
/// backend contract is a single endpoint:
///
///   GET {baseUrl}/v1/link-check?url=(urlencoded normalized URL)
///   -> 200 { "matched": bool, "level": "safe"|"suspicious"|"dangerous",
///            "label": string, "detail": string }
///   -> matched:false (or any non-2xx / timeout) means "no corroborating
///      external record" and is treated as a soft no-op, never an error
///      shown to the user.
class BackendProxyThreatIntelligenceProvider
    implements ThreatIntelligenceProvider {
  BackendProxyThreatIntelligenceProvider({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  static const _timeout = Duration(seconds: 4);

  @override
  Future<ThreatIntelLookupResult?> lookup({
    required String domain,
    required String normalizedUrl,
  }) async {
    if (baseUrl.isEmpty) return null;

    try {
      final uri = Uri.parse(
        '$baseUrl/v1/link-check',
      ).replace(queryParameters: {'url': normalizedUrl});
      final response = await _client.get(uri).timeout(_timeout);
      if (response.statusCode != 200) return null;

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['matched'] != true) return null;

      final level = RiskLevel.values.byName(
        (body['level'] as String?) ?? 'unknown',
      );
      return ThreatIntelLookupResult(
        level: level,
        indicator: ThreatIndicator(
          label: (body['label'] as String?) ?? 'Threat intelligence match',
          detail:
              (body['detail'] as String?) ??
              'Matched an external threat-intelligence record.',
        ),
      );
    } catch (_) {
      // Network failure, timeout, malformed response, service down —
      // treated as "no corroborating record available", never surfaced
      // as an error. Local rule-based analysis already stands on its own.
      return null;
    }
  }
}
