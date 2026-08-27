import 'package:http/http.dart' as http;

import '../../../data/models/risk_level.dart';

/// Result of a live "is this site actually up?" probe — deliberately
/// separate from the security risk verdict. A site can be perfectly
/// reachable and still dangerous, or briefly down and still safe; this
/// only answers "did something respond", never "is it safe".
enum ReachabilityStatus {
  checking,
  reachable,
  unreachable,

  /// Deliberately not probed — a known/strongly-suspected malicious URL
  /// is never connected to, even for a lightweight HEAD request.
  skippedDangerous,
}

extension ReachabilityStatusX on ReachabilityStatus {
  String get label => switch (this) {
    ReachabilityStatus.checking => 'Checking site availability…',
    ReachabilityStatus.reachable =>
      'Site responded — it appears to be reachable',
    ReachabilityStatus.unreachable => 'Could not reach this site right now',
    ReachabilityStatus.skippedDangerous =>
      'Not checked — connecting to this site was skipped for your safety',
  };
}

/// Live (non-mocked) reachability probe, used only for the demo "is this
/// link working right now" indicator on the result screen — never part of
/// the risk score itself. Labelled "Demo connectivity check" in the UI.
class LinkReachabilityService {
  LinkReachabilityService({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  static const _timeout = Duration(seconds: 6);

  Future<ReachabilityStatus> check(
    String normalizedUrl,
    RiskLevel level,
  ) async {
    if (level == RiskLevel.dangerous) {
      return ReachabilityStatus.skippedDangerous;
    }

    try {
      final uri = Uri.parse(normalizedUrl);
      // HEAD is enough to confirm the destination responds at all — no
      // page content is downloaded or displayed. Any HTTP response
      // (including a 404/405) counts as "reachable": the destination is
      // live, regardless of whether that specific request path is valid.
      await _client.head(uri).timeout(_timeout);
      return ReachabilityStatus.reachable;
    } catch (_) {
      return ReachabilityStatus.unreachable;
    }
  }
}
