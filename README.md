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
- [Safe Viewer architecture](#safe-viewer-architecture)
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
- Link Checker with a deterministic, explainable risk engine (not random).
- Share-to-Rakshak from any Android app (Chrome, WhatsApp, etc.) via a
  small native `MainActivity.kt` bridge — no third-party plugin needed.
- QR scanner (URL / plain text / UPI payment payloads).
- Demo Safe Viewer: an in-app WebView with an explicit risk gate, clearly
  labelled as a demo implementation, not full remote browser isolation.
- Link history, scam-awareness articles (admin-managed content).

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
- Dashboard with synthetic + live-blended analytics (`fl_chart`).
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
encrypted environment variables in Codemagic. Only one variable currently
has any effect: the demo admin credentials (see below).

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
User input (typed / pasted / shared / QR)
        │
        ▼
UrlUtils.normalize()        — parsing only, no scoring
        │
        ▼
LinkRiskEngine.assess()     — pure, deterministic scoring function
        │  (known-safe / known-malicious demo lists, IP hosts, punycode,
        │   suspicious TLDs, brand-impersonation keywords, HTTPS, …)
        ▼
LinkAnalysisService.checkUrl()  — the swappable seam: returns the exact
        │                          same LinkCheckResult shape a real
        │                          threat-intel API would
        ▼
LinkCheckResult (risk level, score, explained indicators)
```

`LinkRiskEngine` is pure and synchronous by design — the same input always
produces the same output, which is what makes it unit-testable and lets
every result show *why* it was flagged ("Why was this flagged?"). Replacing
the demo lists in `DemoThreatIntel` with a live feed means implementing a
new `LinkAnalysisService`; nothing else in the app changes. Admin-managed
domain overrides (`Admin → Threat Intelligence`) are consulted first and
take priority over the built-in demo lists, which is the same seam a real
feed would use.

The app never states a link is "100% safe" — only "no known threats
detected", "suspicious", "dangerous", or "unable to determine".

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
| Real Threat Intelligence | OFF | Would replace `DemoThreatIntel`'s lists |
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
- This build has not been tested against a real Android SDK/toolchain in
  the environment that produced it (no Android SDK was available); CI
  (Codemagic) is expected to be the first environment that actually
  compiles the native Android build. `flutter analyze` and `flutter test`
  both pass locally.
