/// Feature flags controlling which capabilities are exposed in this demo.
///
/// Defaults reflect what genuinely works end-to-end in this prototype.
/// Flags that gate real government/production integrations default OFF
/// and are surfaced in Admin > Settings so the boundary is explicit.
class FeatureFlags {
  const FeatureFlags({
    this.safeLinkViewer = true,
    this.qrScanner = true,
    this.aiAssistant = true,
    this.digiLocker = false,
    this.realThreatIntelligence = false,
    this.governmentApiIntegration = false,
  });

  final bool safeLinkViewer;
  final bool qrScanner;
  final bool aiAssistant;
  final bool digiLocker;
  final bool realThreatIntelligence;
  final bool governmentApiIntegration;

  FeatureFlags copyWith({
    bool? safeLinkViewer,
    bool? qrScanner,
    bool? aiAssistant,
    bool? digiLocker,
    bool? realThreatIntelligence,
    bool? governmentApiIntegration,
  }) {
    return FeatureFlags(
      safeLinkViewer: safeLinkViewer ?? this.safeLinkViewer,
      qrScanner: qrScanner ?? this.qrScanner,
      aiAssistant: aiAssistant ?? this.aiAssistant,
      digiLocker: digiLocker ?? this.digiLocker,
      realThreatIntelligence:
          realThreatIntelligence ?? this.realThreatIntelligence,
      governmentApiIntegration:
          governmentApiIntegration ?? this.governmentApiIntegration,
    );
  }

  Map<String, dynamic> toJson() => {
    'safeLinkViewer': safeLinkViewer,
    'qrScanner': qrScanner,
    'aiAssistant': aiAssistant,
    'digiLocker': digiLocker,
    'realThreatIntelligence': realThreatIntelligence,
    'governmentApiIntegration': governmentApiIntegration,
  };

  factory FeatureFlags.fromJson(Map<String, dynamic> json) => FeatureFlags(
    safeLinkViewer: json['safeLinkViewer'] as bool? ?? true,
    qrScanner: json['qrScanner'] as bool? ?? true,
    aiAssistant: json['aiAssistant'] as bool? ?? true,
    digiLocker: json['digiLocker'] as bool? ?? false,
    realThreatIntelligence: json['realThreatIntelligence'] as bool? ?? false,
    governmentApiIntegration:
        json['governmentApiIntegration'] as bool? ?? false,
  );
}
