import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around [SharedPreferences] for non-sensitive local
/// persistence (theme choice, language, feature flags, demo data caches).
///
/// Sensitive data (identity documents, admin session tokens) must go
/// through [SecureStorageService] instead.
class LocalStorageService {
  LocalStorageService(this._prefs);

  final SharedPreferences _prefs;

  static Future<LocalStorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorageService(prefs);
  }

  String? getString(String key) => _prefs.getString(key);
  Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);

  bool? getBool(String key) => _prefs.getBool(key);
  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);

  Future<bool> remove(String key) => _prefs.remove(key);
}

/// Keys used for local persistence. Centralized to avoid typo drift.
class StorageKeys {
  const StorageKeys._();

  static const String themeMode = 'settings.theme_mode';
  static const String languageCode = 'settings.language_code';
  static const String linkProtectionEnabled =
      'settings.link_protection_enabled';
  static const String safeViewerDefault = 'settings.safe_viewer_default';
  static const String warnAboutSuspiciousLinks =
      'settings.warn_about_suspicious_links';
  static const String openSafeLinksAutomatically =
      'settings.open_safe_links_automatically';
  static const String showRiskExplanations = 'settings.show_risk_explanations';
  static const String onboardingComplete = 'app.onboarding_complete';
  static const String currentUserId = 'app.current_user_id';
  static const String adminSessionActive = 'admin.session_active';
  static const String featureFlagsOverride = 'admin.feature_flags_override';
  static const String hasPromptedLocationBefore =
      'location.has_prompted_before';
  static const String savedLocationInfo = 'location.saved_info';
  static const String hasPromptedBrowserRoleOnFirstLaunch =
      'app.has_prompted_browser_role_on_first_launch';
}
