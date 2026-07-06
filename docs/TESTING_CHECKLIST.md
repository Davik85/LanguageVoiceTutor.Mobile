# Testing Checklist

## Docs-only foundation checks

- Confirm no Flutter app files were created.
- Confirm no Android project files were created.
- Confirm no iOS project files were created.
- Confirm no runtime code was added.
- Confirm no secrets were added.
- Confirm repository documents state the backend source-of-truth model.

## Pre-skeleton checks

Before creating the Flutter skeleton, verify:

- Backend base URL strategy is approved.
- Auth/session contract is documented.
- `/api/me` and settings contracts are confirmed.
- Subscription-status contract is confirmed.
- Lesson-access contract is confirmed.
- Lesson start/message/history/progress contracts are confirmed.
- Voice upload and TTS contracts are confirmed.
- Android minimum SDK and target SDK are confirmed.
- Flutter version/channel is confirmed.

## Verified Android skeleton checks

The Android skeleton baseline has been verified locally on Android Emulator. Run these commands from `app/`:

```bash
flutter clean
flutter pub get
flutter analyze
flutter test
flutter run -d emulator-5554
```

Expected result: the placeholder Flutter app builds, installs, and runs on the emulator using package/application id `com.languagevoicetutor.mobile`. If the active emulator has a different id, replace `emulator-5554` with the id shown by `flutter devices`.

Current verified Android build stack:

- Gradle 8.14
- Android Gradle Plugin 8.11.1
- Kotlin Gradle Plugin 2.2.20
- Java/Kotlin target 17

## Current skeleton checks

For the current placeholder skeleton, keep verifying:

- Flutter package resolution.
- Static analysis.
- Unit/widget tests.
- Emulator launch with the placeholder Splash, Login, Home, Lesson, and Settings screens.
- No secrets in the repository or app bundle.
- No client-side OpenAI calls.
- No client-side Premium decisions.


## Backend health-check slice checks

This mobile slice verifies only basic backend reachability from the Flutter client. It uses the production API base URL and calls only:

```text
GET /health
```

Expected response fields parsed by the app:

- `status`
- `environment`
- `checkedAtUtc`

The Settings screen should show **Backend connection** with one of these friendly states: `Not checked`, `Checking...`, `Connected`, or `Unavailable`. Timeout, network failure, unsuccessful status codes, and invalid response bodies should show `Unavailable` without stack traces, database details, configurable release UI backend URLs, or raw exception text.

Intentionally out of scope for this PR:

- Auth, login, register, account loading, or token storage.
- Subscription/Premium logic and `/api/me/subscription-status`.
- Paddle, Google Play Billing, or Apple billing runtime.
- Voice mode, TTS, lesson runtime, lesson history, progress, analytics, crash reporting, backend runtime code, and database migrations.
- Client-side OpenAI calls or provider/backend secrets.

Run these commands from `app/` to verify the health-check slice:

```bash
flutter pub get
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
```

## Future Flutter checks

After additional runtime code exists, add checks for:

- Flutter formatting.
- Static analysis.
- Unit tests.
- Widget tests.
- Integration tests against mocked backend contracts.
- Backend auth/session flow.
- Secure storage behavior.
- Account and settings retrieval from backend.
- Subscription-status retrieval from backend-owned entitlement state.
- Expired session handling.
- Offline and retry states.
- Audio permission handling.
- Voice upload errors.
- TTS playback errors.

## Future billing checks

After Google Play Billing runtime code exists, add checks for:

- Sandbox purchase success.
- Pending purchase state.
- Purchase cancellation.
- Purchase token backend submission.
- Backend verification success.
- Backend verification failure.
- Entitlement refresh after purchase.
- Restore or reconciliation flow.
- Grace period, account hold, cancellation, and expiration states.

## Future release-readiness checks

Before any store release:

- Confirm privacy policy requirements.
- Confirm data safety disclosures.
- Confirm microphone permission rationale.
- Confirm account deletion requirements.
- Confirm crash reporting and analytics consent behavior.
- Confirm production backend environment configuration.
- Confirm no secrets are present in the app bundle or repository.

## PR 2 auth/account/subscription-status checks

This slice uses the production backend base URL and only these backend endpoints:

```text
GET /health
POST /api/auth/register
POST /api/auth/login
GET /api/auth/me
POST /api/auth/refresh
POST /api/auth/revoke
GET /api/me/subscription-status
```

Expected verification:

- Login and register use friendly validation and sanitized errors.
- Stored sessions attempt `GET /api/auth/me` at startup.
- Invalid sessions are cleared and return to Login.
- Access and refresh tokens are stored only in secure mobile storage.
- Tokens are not logged, printed, or shown in UI.
- Settings keeps the Backend connection card working.
- Settings shows account email/display name from backend account data.
- Settings shows Free, Trial, or Premium only from `GET /api/me/subscription-status`.
- Extra subscription-status backend fields are tolerated by parsing.
- No client-side Premium decision, payment UI, Google Play Billing, Apple billing, Paddle runtime, `/api/me/lesson-access` UI call, client-side OpenAI call, voice mode, TTS, lesson runtime, lesson history/progress, analytics, crash reporting, store release setup, backend runtime code, or database migration is implemented.

Run these commands from `app/`:

```bash
flutter pub get
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
```
