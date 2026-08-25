import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_gu.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_mr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('gu'),
    Locale('hi'),
    Locale('mr'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Rakshak'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Cyber Safety & Cybercrime Assistance'**
  String get appTagline;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navProtect.
  ///
  /// In en, this message translates to:
  /// **'Protect'**
  String get navProtect;

  /// No description provided for @navReport.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get navReport;

  /// No description provided for @navCases.
  ///
  /// In en, this message translates to:
  /// **'Cases'**
  String get navCases;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @yourDashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your cyber safety dashboard'**
  String get yourDashboardSubtitle;

  /// No description provided for @cyberSafety.
  ///
  /// In en, this message translates to:
  /// **'Cyber Safety'**
  String get cyberSafety;

  /// No description provided for @protectionActive.
  ///
  /// In en, this message translates to:
  /// **'Protection active'**
  String get protectionActive;

  /// No description provided for @linkProtection.
  ///
  /// In en, this message translates to:
  /// **'Link protection'**
  String get linkProtection;

  /// No description provided for @safeLinkViewer.
  ///
  /// In en, this message translates to:
  /// **'Safe Link Viewer'**
  String get safeLinkViewer;

  /// No description provided for @on.
  ///
  /// In en, this message translates to:
  /// **'ON'**
  String get on;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'OFF'**
  String get off;

  /// No description provided for @actionCheckLink.
  ///
  /// In en, this message translates to:
  /// **'Check Link'**
  String get actionCheckLink;

  /// No description provided for @actionScanQr.
  ///
  /// In en, this message translates to:
  /// **'Scan QR'**
  String get actionScanQr;

  /// No description provided for @actionReportIncident.
  ///
  /// In en, this message translates to:
  /// **'Report Incident'**
  String get actionReportIncident;

  /// No description provided for @actionSaveEvidence.
  ///
  /// In en, this message translates to:
  /// **'Save Evidence'**
  String get actionSaveEvidence;

  /// No description provided for @myCases.
  ///
  /// In en, this message translates to:
  /// **'My Cases'**
  String get myCases;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get recentActivity;

  /// No description provided for @riskSafeLabel.
  ///
  /// In en, this message translates to:
  /// **'No known threats detected'**
  String get riskSafeLabel;

  /// No description provided for @riskSuspiciousLabel.
  ///
  /// In en, this message translates to:
  /// **'Suspicious Link'**
  String get riskSuspiciousLabel;

  /// No description provided for @riskDangerousLabel.
  ///
  /// In en, this message translates to:
  /// **'Dangerous Link'**
  String get riskDangerousLabel;

  /// No description provided for @riskUnknownLabel.
  ///
  /// In en, this message translates to:
  /// **'Unable to determine'**
  String get riskUnknownLabel;

  /// No description provided for @viewSafely.
  ///
  /// In en, this message translates to:
  /// **'View Safely'**
  String get viewSafely;

  /// No description provided for @openAnyway.
  ///
  /// In en, this message translates to:
  /// **'Open Anyway'**
  String get openAnyway;

  /// No description provided for @dontOpen.
  ///
  /// In en, this message translates to:
  /// **'Don\'t Open'**
  String get dontOpen;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// No description provided for @openInBrowser.
  ///
  /// In en, this message translates to:
  /// **'Open in Chrome'**
  String get openInBrowser;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @continueWithoutThisInformation.
  ///
  /// In en, this message translates to:
  /// **'Continue without this information'**
  String get continueWithoutThisInformation;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @addEvidence.
  ///
  /// In en, this message translates to:
  /// **'Add evidence'**
  String get addEvidence;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @whyWasThisFlagged.
  ///
  /// In en, this message translates to:
  /// **'Why was this flagged?'**
  String get whyWasThisFlagged;

  /// No description provided for @demoThreatIntelligence.
  ///
  /// In en, this message translates to:
  /// **'Demo Threat Intelligence'**
  String get demoThreatIntelligence;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @askRakshak.
  ///
  /// In en, this message translates to:
  /// **'Ask Rakshak'**
  String get askRakshak;

  /// No description provided for @askRakshakPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Ask a question about your case or the app'**
  String get askRakshakPlaceholder;

  /// No description provided for @aiAssistedExplanation.
  ///
  /// In en, this message translates to:
  /// **'AI-assisted explanation — review required'**
  String get aiAssistedExplanation;

  /// No description provided for @whatHappened.
  ///
  /// In en, this message translates to:
  /// **'What happened?'**
  String get whatHappened;

  /// No description provided for @incidentDetails.
  ///
  /// In en, this message translates to:
  /// **'Incident details'**
  String get incidentDetails;

  /// No description provided for @complaintReview.
  ///
  /// In en, this message translates to:
  /// **'Complaint Review'**
  String get complaintReview;

  /// No description provided for @evidenceVault.
  ///
  /// In en, this message translates to:
  /// **'Evidence Vault'**
  String get evidenceVault;

  /// No description provided for @statusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get statusDraft;

  /// No description provided for @statusSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get statusSubmitted;

  /// No description provided for @statusForwarded.
  ///
  /// In en, this message translates to:
  /// **'Forwarded to Authority'**
  String get statusForwarded;

  /// No description provided for @statusUnderReview.
  ///
  /// In en, this message translates to:
  /// **'Under Review'**
  String get statusUnderReview;

  /// No description provided for @statusAdditionalInfoRequired.
  ///
  /// In en, this message translates to:
  /// **'Additional Information Required'**
  String get statusAdditionalInfoRequired;

  /// No description provided for @statusUnderInvestigation.
  ///
  /// In en, this message translates to:
  /// **'Under Investigation'**
  String get statusUnderInvestigation;

  /// No description provided for @statusResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get statusResolved;

  /// No description provided for @statusClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get statusClosed;

  /// No description provided for @demoDisclaimerShort.
  ///
  /// In en, this message translates to:
  /// **'This is a demo. No data is sent to a real government system.'**
  String get demoDisclaimerShort;

  /// No description provided for @emptyStateNoData.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get emptyStateNoData;

  /// No description provided for @errorGenericTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorGenericTitle;

  /// No description provided for @errorGenericRetry.
  ///
  /// In en, this message translates to:
  /// **'Please try again'**
  String get errorGenericRetry;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'gu', 'hi', 'mr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'gu':
      return AppLocalizationsGu();
    case 'hi':
      return AppLocalizationsHi();
    case 'mr':
      return AppLocalizationsMr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
