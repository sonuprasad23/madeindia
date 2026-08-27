/// Backend endpoint configuration for optional real integrations.
///
/// Empty by default — meaning no external threat-intelligence backend is
/// configured, so [DisabledThreatIntelligenceProvider] is used regardless
/// of the "Real Threat Intelligence" feature flag. Set at build time via
/// `--dart-define=THREAT_INTEL_BACKEND_URL=https://your-proxy.example.com`
/// (see `.env.example`) once a real backend proxy exists — see
/// `BackendProxyThreatIntelligenceProvider` for why this must be a backend
/// and never a direct call from Flutter.
class BackendConfig {
  const BackendConfig._();

  static const String threatIntelBackendUrl = String.fromEnvironment(
    'THREAT_INTEL_BACKEND_URL',
  );
}
