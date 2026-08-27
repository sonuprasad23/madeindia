# Rakshak

**Rakshak** ("protector") is a demo/prototype Indian cyber-safety and
cybercrime-assistance platform built in Flutter. It combines proactive
protection (link/QR checking, a safe in-app viewer) with a structured
cybercrime-reporting experience (evidence vault, crime-specific forms,
complaint review, case tracking) and a conservative, rule-based assistant.

> **This is a demo/prototype, not a production government system.**
> Nothing submitted inside this app reaches the real National Cyber Crime
> Reporting Portal (NCRP), any police authority, or any bank. Every screen
> that could be mistaken for a real submission is labelled as demo data.
> See [Security & scope limitations](#security--scope-limitations).

---

## Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Features](#features)
- [Folder structure](#folder-structure)
- [Local setup](#local-setup)
- [Environment variables](#environment-variables)
- [Demo credentials](#demo-credentials)
- [Running locally](#running-locally)
- [Running tests](#running-tests)
- [Building the APK / App Bundle](#building-the-apk--app-bundle)
- [Codemagic CI](#codemagic-ci)
- [Link Checker architecture](#link-checker-architecture)
- [Threat intelligence limitations](#threat-intelligence-limitations)
- [Android link interception](#android-link-interception)
- [Safe Viewer architecture](#safe-viewer-architecture)
- [Location](#location)
- [Mock government integration architecture](#mock-government-integration-architecture)
- [Admin panel](#admin-panel)
- [Future production integrations](#future-production-integrations)
- [Security & scope limitations](#security--scope-limitations)

---

## Overview

Rakshak follows one philosophy throughout:

> **Prevent → Preserve → Prepare → Report → Track → Understand**

The app never claims to be the police, a court, a bank, or a legal
authority — it assists a citizen through the process, using conservative
language ("no known threats detected", "currently shown as under
investigation") rather than guarantees.

## Architecture

- **Flutter + Dart**, Material 3, Android-first, responsive up to tablet/web.
- **State management**: Riverpod (`Notifier`/`NotifierProvider`, no code
  generation — kept deliberately simple to avoid a `build_runner` step).
- **Routing**: `go_router`, with two `ShellRoute`s (`AppShell` for the
  citizen app's bottom navigation / nav rail, `AdminShell` for the admin
  panel's side navigation) and an auth-based redirect guarding `/admin/*`.
- **Persistence**: `SharedPreferences`-backed JSON repositories
  (`lib/data/repositories/`) behind small, swappable interfaces — the UI
  never talks to `SharedPreferences` directly. `flutter_secure_storage` is
  used only for the admin demo session token.
- **Localization**: standard Flutter ARB + `flutter gen-l10n` pipeline
  (`lib/core/localization/arb/*.arb`), English/Hindi/Gujarati/Marathi seeded
  today; adding a language is "add an ARB file, run gen-l10n, register it
  in `language_controller.dart`".
- **Design system**: `lib/core/widgets/` (`RakshakButton`, `RakshakCard`,
  `RakshakRiskBadge`, `RakshakTimeline`, empty/error/loading states, etc.)
  plus centralized theme tokens in `lib/core/theme/`.

The architecture is intentionally layered so a mock service can be swapped
for a real one without touching feature UI — see the three sections below
on the Link Checker, Safe Viewer, and mock government integration for the
specific seams.

## Features

**Prevention**
- Link Checker with a deterministic, explainable risk engine (not random),
  layered as Local Rules → optional Threat Intelligence → Risk Engine.
- Android link interception: Rakshak can be selected as an http/https
  handler, so tapping a link in WhatsApp/SMS/Gmail/Telegram/etc. opens the
  **Link Security Gateway** ("Check this link before opening?") before
  anything loads — plus Share-to-Rakshak from any app. Both go through one
  native `MainActivity.kt` bridge — no third-party plugin needed.
- QR scanner (URL / plain text / UPI payment payloads).
- Demo Safe Viewer: an in-app WebView with an explicit risk gate, clearly
  labelled as a demo implementation, not full remote browser isolation.
- Link history (URL, domain, risk, reasons, source app, and what the user
  ultimately did with it), scam-awareness articles (admin-managed content).
- One-shot current-location card on Home, clearly distinct from the
  citizen profile's registered address/jurisdiction.

**Reporting & case assistance**
- Reusable citizen profile (identity, address, jurisdiction suggestion,
  identity documents, social identities).
- Evidence Vault: images/PDFs/video/text/URLs, SHA-256 hashed, original
  files never modified; demo "extraction" of transaction details from
  financial screenshots, always labelled "please verify".
- Crime-specific dynamic incident forms (16 categories) driven by a single
  data-driven form registry, not 16 bespoke screens.
- Complaint Review that shows exactly what is/isn't provided, plus a
  template-based (never generative-fact-inventing) "AI-assisted" summary.
- Case tracking with a status timeline and per-status "what does this
  mean?" explanations.
- "Ask Rakshak" — a rule-based conservative assistant, not a generative
  model with access to invent facts.

**Admin**
- Dashboard with synthetic + live-blended analytics (`fl_chart`), including
  a Link Checks breakdown (safe/suspicious/dangerous/unknown counts) and a
  Location Statistics card (state-level aggregation only — never exact
  per-user coordinates).
- User directory, case status management (the app's "mock backend"),
  threat-intelligence domain management, content management, feature
  flags, and link-checker risk thresholds.

## Folder structure

```text
lib/
  core/            theme, branding, routing, constants, utils, widgets,
                   services, storage, localization (ARB + generated)
  features/        auth, dashboard, profile, prevention/*, evidence,
                   incidents, complaints, cases, assistant,
                   notifications, settings
  admin/           dashboard, users, complaints (case status), links
                   (threat intel), content, settings, auth, shared shell
  data/            models, repositories, datasources (seed data + JSON store)
  main.dart
test/
  unit/            pure-Dart logic tests (risk engine, formatters, models…)
  widget/          theme tests
  widget_test.dart end-to-end smoke test (boot → navigate)
android/           standard Flutter Android project + the share-intent bridge
```

## Local setup

- Flutter **3.38.5** (Dart 3.10.4) — see `environment: sdk: ^3.10.4` in
  `pubspec.yaml`. Using a different Flutter version is not guaranteed to
  work; install this one via `flutter version 3.38.5` (or use `fvm`).
- Run `flutter pub get`.
- Run `flutter gen-l10n` if you edit any `.arb` file (also runs
  automatically as part of `flutter pub get` / `flutter build` because
  `generate: true` is set in `pubspec.yaml`).

## Environment variables

Copy `.env.example` for reference. Flutter doesn't read `.env` files
directly — pass the same keys via `--dart-define` at run/build time, or as
encrypted environment variables in Codemagic. Two variables currently have
any effect: the demo admin credentials (see below), and
`THREAT_INTEL_BACKEND_URL` (empty by default — see [Threat intelligence
limitations](#threat-intelligence-limitations); leaving it unset keeps the
"Real Threat Intelligence" flag a no-op even if turned on in Admin).

## Demo credentials

Admin panel (`Profile → Admin access`, or `/admin/login`):

```text
Username: admin
Password: Rakshak@Demo123
```

These are **demo-only** and overridable via
`--dart-define=ADMIN_DEMO_USERNAME=...` /
`--dart-define=ADMIN_DEMO_PASSWORD=...` (see
`lib/admin/auth/demo_admin_credentials.dart`). They are never hardcoded as
a real secret and never committed as a production credential.

## Running locally

```bash
flutter pub get
flutter run
```

The citizen app opens directly; reach the admin panel from
**Profile → Admin access**.

## Running tests

```bash
flutter analyze
dart format --output=none --set-exit-if-changed .
flutter test
```

Test coverage includes: URL normalization, the deterministic link-risk
engine, incident form-registry validation, evidence metadata/serialization,
case status semantics, currency/date formatting, theme (light vs. dark are
genuinely different, not inverted), localization (every supported locale
resolves), and an end-to-end boot + navigation smoke test.

## Building the APK / App Bundle

Locally (requires the Android SDK — not required for `flutter analyze` /
`flutter test`, only for an on-device/emulator build):

```bash
flutter build apk --release
flutter build appbundle --release
```

The default Flutter Android project signs release builds with the debug
key (see `android/app/build.gradle.kts`) — enough to install and test, but
**not a real release signature**. Add a real keystore (never committed;
see `.gitignore`) before shipping anywhere beyond internal testing.

## Codemagic CI

`codemagic.yaml` lives at the repository root (required by Codemagic) and
defines an `android-demo` workflow that: installs dependencies, checks
formatting, runs `flutter analyze`, runs `flutter test`, then builds an
APK and an App Bundle — both unsigned/demo-signed, since no keystore is
configured. A commented-out `android-release` workflow sketches the shape
of a future signed pipeline, and the file notes where an iOS workflow would
be added once iOS platform files exist.

## Link Checker architecture

```text
User input (typed / pasted / shared / view-intent / QR)
        │
        ▼
UrlUtils.normalize()             — parsing only, no scoring; the ORIGINAL
        │                          string is preserved and shown to the
        │                          user untouched — only a normalized copy
        │                          is used for analysis
        ▼
LinkRiskEngine.assess()          — "Local Rules": pure, deterministic
        │                          scoring (known-safe / known-malicious
        │                          demo lists, IP hosts, punycode,
        │                          suspicious TLDs, brand-impersonation
        │                          keywords, HTTPS, …). No randomness —
        │                          same input always produces the same
        │                          output.
        ▼
ThreatIntelligenceProvider.lookup() — "Threat Intelligence": optional
        │                          layer, OFF by default (see next
        │                          section). Can only ADD a corroborating
        │                          indicator and escalate severity — never
        │                          silently downgrades a local finding.
        ▼
LinkAnalysisService.checkUrl()   — the swappable seam: returns the exact
        │                          same LinkCheckResult shape regardless
        │                          of which layers actually contributed
        ▼
LinkCheckResult (risk level, score, explained indicators, recorded to
Link History together with the source app it arrived from and what the
user ultimately did with it)
```

Replacing the demo lists in `DemoThreatIntel` with a live feed means
implementing a new `ThreatIntelligenceProvider` (see next section) or
`LinkAnalysisService`; nothing else in the app changes. Admin-managed
domain overrides (`Admin → Threat Intelligence`) are consulted first and
take priority over the built-in demo lists, which is the same seam a real
feed would use.

The app never states a link is "100% safe" — only "no known threats
detected", "suspicious", "dangerous", or "unable to determine".

## Threat intelligence limitations

`Admin → Settings → Real Threat Intelligence` is a real feature flag, but
it is **OFF by default and has no live backend behind it in this repo** —
this is a deliberate, documented limitation, not an oversight:

- **URLhaus (abuse.ch)** now requires an `Auth-Key` header on every API
  call (their 2024 "Community First" rollout) — there is no keyless
  lookup left to call directly from a mobile client. Their free tier is
  fair-use/non-commercial in spirit; abuse.ch directs commercial/for-profit
  use to their paid API instead. (https://urlhaus-api.abuse.ch/,
  https://abuse.ch/blog/community-first/)
- **VirusTotal Public API v3** requires a per-account API key, caps free
  usage at **500 requests/day and 4/minute**, and its Terms of Service
  **explicitly prohibit commercial use** of the Public API tier — it "must
  not be used in commercial products or services."
  (https://docs.virustotal.com/reference/public-vs-premium-api)
- Both require a secret that **must never be embedded in a mobile app** —
  a decompiled APK trivially leaks any key baked into it, which is exactly
  what the task's own constraint forbids.

So the architecture is: `BackendProxyThreatIntelligenceProvider`
(`lib/features/prevention/link_checker/backend_proxy_threat_intelligence_provider.dart`)
is real, working HTTP-client code, but it talks to **your own backend
proxy** (which would hold the URLhaus/VirusTotal key server-side), not to
those APIs directly:

```text
Flutter (DemoLinkAnalysisService)
   │  GET {THREAT_INTEL_BACKEND_URL}/v1/link-check?url=...
   ▼
Your backend proxy   — holds the URLhaus Auth-Key / VirusTotal API key,
   │                    never shipped in the app
   ▼
URLhaus / VirusTotal / etc.
```

With `THREAT_INTEL_BACKEND_URL` unset (the default), this provider is
never even constructed —
`threatIntelligenceProviderProvider` falls back to
`DisabledThreatIntelligenceProvider`, a no-op. Set the flag AND the
`--dart-define=THREAT_INTEL_BACKEND_URL=...` build variable once a real
proxy exists; nothing else in the app needs to change. Never present any
of this as a "definitive safe verdict" — see the risk-level copy rules
above.

## Android link interception

Rakshak can be selected as an Android http/https link handler, so tapping
a link in WhatsApp/SMS/Gmail/Telegram/etc. can route it through Rakshak's
**Link Security Gateway** before anything opens:

```text
Other app → user taps a link → Android ACTION_VIEW intent
   → Rakshak (MainActivity.kt) → LinkGatewayScreen
        "Check this link before opening?"
        [ Check Link ]  [ Open Directly ]  [ Cancel ]
```

Implementation (`android/app/src/main/kotlin/.../MainActivity.kt` +
`lib/core/services/incoming_link_service.dart`):

- A manifest `<intent-filter>` for `ACTION_VIEW` + `BROWSABLE` on
  `http`/`https` registers Rakshak as an available handler. It is
  deliberately **not** `android:autoVerify="true"` — that requires
  publishing a Digital Asset Links (`assetlinks.json`) file on a real
  verified domain, which this demo doesn't have.
- Both `ACTION_VIEW` (tapped link) and `ACTION_SEND` (shared text/URL) are
  captured — cold start (`onCreate`), already-running/backgrounded
  (`onNewIntent`), and repeated intents during the app's lifetime are all
  handled, surfaced to Flutter as the same `IncomingLinkEvent` shape over
  one `MethodChannel`/`EventChannel` pair.
- The original URL string is never altered before being shown to the
  user; only a normalized copy is used for analysis (see
  `UrlUtils.normalize`).
- **Anti-loop guarantee**: choosing "Open Directly" (or "Open in Default
  Browser" from a result screen) calls the native
  `openExternalBrowser` method, which resolves the device's actual
  default handler and launches it explicitly — and if no single default
  exists, builds the chooser itself with
  `Intent.EXTRA_EXCLUDE_COMPONENTS` set to Rakshak's own component, so
  Rakshak can never reappear as a choice and re-trigger the gateway.

**Real Android limitation, stated plainly**: Android controls default-app
selection. Without a verified App Link (which requires a real domain),
Rakshak cannot force itself to silently receive every http/https link —
the user must either pick "Rakshak" from the disambiguation chooser each
time, or explicitly set it as the preferred handler via
**Settings → Apps → Rakshak → Open by default**. `Settings → Link
Protection → Enable Link Protection → Open Android Settings` explains
this and deep-links straight into that screen
(`SystemActionsService.openLinkHandlerSettings`, using
`Settings.ACTION_APP_OPEN_BY_DEFAULT_SETTINGS` on Android 12+ with a
fallback to the app-info screen on older versions). Rakshak does **not**
use Accessibility Services and does **not** monitor other apps, clipboard,
or browsing history — only Android's standard intent/default-handler
mechanism.

## Safe Viewer architecture

The Safe Viewer loads a page inside an in-app `webview_flutter` view,
behind an explicit risk gate for anything not already classified "safe".
It is clearly labelled **"Demo Safe Viewer"** everywhere in the UI and
explicitly does **not** claim full remote browser isolation — it still
uses the device's normal WebView, unlike a disposable remote browser with
no access to the user's real session/cookies/credentials.

The screen is structured so that a future version could swap the WebView
for a call into a real remote-isolation backend (loading a video/DOM
stream of a disposable remote session instead) without changing how the
rest of the app navigates to or interacts with this screen.

## Location

The Home dashboard's Location Card (`lib/features/location/`) shows the
device's **current, one-shot** location — deliberately never the same
thing as the citizen profile's registered address or suggested
jurisdiction (see `Profile`, which now says so explicitly).

- Never requested on first launch — the card starts as an explanation +
  "Allow Location" / "Not Now", and only calls into `geolocator` when the
  user taps "Allow Location".
- One-shot retrieval only (`Geolocator.getCurrentPosition`) — no
  background/continuous tracking, no location listener left running.
- Reverse-geocoded via the `geocoding` package into city/state/pincode
  where available; if geocoding fails, the coordinates alone are still
  shown rather than fabricating a place name.
- Denied vs. permanently-denied are handled differently: a plain denial
  can be retried in-app; a permanent denial (or location services being
  off) routes to the relevant Android Settings screen instead of
  re-prompting (`Geolocator.openAppSettings` /
  `Geolocator.openLocationSettings`) — Rakshak never nags after a
  permanent denial.
- The last retrieved location is cached locally (`SharedPreferences`) so
  it survives an app restart; `Settings → Location → Clear saved location`
  deletes it. It is never uploaded anywhere — the Admin "Location
  Statistics" card only ever aggregates by **state**, never exact
  coordinates, and is otherwise synthetic demo data.

## Mock government integration architecture

```text
Official Government API  (does not exist for this demo)
        │
        ▼
Integration interface     — CaseRepository / IdGenerator boundary
        │
        ▼
Mock/demo service         — in-app SharedPreferences-backed repository,
        │                    synthetic case/complaint IDs (RKS-######,
        │                    NCRP-DEMO-#####)
        ▼
Demo UI                   — always shows AppConstants.demoDisclaimer
                             wherever a real submission could be implied
```

Nothing in this codebase submits data to NCRP, contacts a real police
station, or contacts a real bank. Case status changes are driven by the
`Admin → Cases` screen (a stand-in "mock backend"), and this is stated
explicitly in the UI copy.

## Admin panel

Reached via **Profile → Admin access** (demo credentials above). Provides:
overview analytics, user directory (deactivate/reactivate demo accounts),
case status management (the mock backend), threat-intelligence domain
management (add/edit/remove, feeds directly into the citizen-facing risk
engine), content management (scam-awareness articles), and settings
(feature flags + link-checker risk thresholds). Admin routes are guarded by
`goRouterProvider`'s redirect logic based on `adminAuthProvider`.

## Future production integrations

Feature flags in `lib/core/constants/feature_flags.dart` (surfaced in
`Admin → Settings`) mark exactly which integrations are real vs. mocked
today:

| Flag | Default | Status |
|---|---|---|
| Safe Link Viewer | ON | Real (demo-labelled) in-app WebView |
| QR Scanner | ON | Real, via `mobile_scanner` |
| AI Assistant | ON | Real, but rule-based — not a generative model |
| DigiLocker | OFF | Not implemented — placeholder boundary only |
| Real Threat Intelligence | OFF | Wired end-to-end but needs `THREAT_INTEL_BACKEND_URL` pointed at a real backend proxy — see [Threat intelligence limitations](#threat-intelligence-limitations) |
| Government API Integration | OFF | Would replace the mock case repository |

## Security & scope limitations

- No passwords are stored in plaintext; the admin session uses
  `flutter_secure_storage` for an opaque demo token (not a signed
  production session).
- No secrets are committed — see `.env.example` and `.gitignore`.
- The admin login is a **demo** credential check, not a real identity
  provider integration.
- The Safe Viewer is a real in-app WebView, not remote browser isolation.
- The "AI-assisted" complaint summary and "Ask Rakshak" assistant are
  rule-based/template-based; they never invent facts and are always
  labelled "review required".
- Rakshak cannot force Android to route every http/https link to it — see
  [Android link interception](#android-link-interception) for the real
  platform limitation and how the app explains it to the user instead of
  overclaiming.
- Location is one-shot and local-only (see [Location](#location)) — never
  continuously tracked, never uploaded, and never conflated with the
  citizen profile's registered address/jurisdiction in the UI.
- This build has not been tested against a real Android SDK/toolchain in
  the environment that produced it (no Android SDK was available); CI
  (Codemagic) is expected to be the first environment that actually
  compiles the native Android build. `flutter analyze` and `flutter test`
  both pass locally.
