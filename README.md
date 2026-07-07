# Language Voice Tutor Mobile

Language Voice Tutor Mobile is the Android-first Flutter client for the existing Language Voice Tutor product. This repository is intentionally separate from the desktop application and backend services so mobile-specific UI, platform integration, release cadence, and store workflows can evolve independently.

## Current repository state

This repository contains the Android-first Flutter mobile client under `app/`. The current verified mobile baseline includes authenticated account/settings slices, backend health and subscription display foundations, tutor options loading, Settings parity work, and a phone-first lesson-start navigation skeleton. Mobile Settings reads and saves backend-owned settings through `/api/me/settings`, including `selectedTutorId`; selected tutor persistence survives app/emulator restart when the backend returns the saved ID. Tutor voice remains a separate setting and is not automatically changed by tutor selection. Home uses **Start lesson** as the primary lesson action and navigates through **Choose Level -> Choose Topic -> Choose Situation -> Lesson placeholder**. The placeholder displays the chosen level, topic, and situation. Real lesson runtime, lesson chat, voice recording, TTS playback, AI tutor calls, Conversation Mode runtime, billing, analytics, crash reporting, secrets, database migrations, store release setup, and backend runtime code remain intentionally out of scope.


## Current verified mobile baseline

The mobile Settings, selected tutor, lesson-start skeleton, catalog labels, and language selector parity baseline is verified from `app/`:

```bash
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
```

`flutter analyze` returned `No issues found`, and `flutter test` passed with 39 tests. Settings has stable visible **Account**, **Learning**, **Audio**, and **Backend diagnostics** sections, with **Save settings** visible and tested. User level is not in Settings. Settings reads `selectedTutorId` from `GET /api/me/settings` and sends it in `PUT /api/me/settings`; `/api/tutor-options` remains the source for available tutor choices. Selected tutor is editable in the **Learning** section, persists after app/emulator restart, and remains independent from the separate tutor voice setting. Language dropdowns display friendly names while storing and sending backend IDs. Study language remains limited to English, French, German, Portuguese, Spanish, and Italian. Home uses **Start lesson** to open the navigation skeleton: **Choose Level -> Choose Topic -> Choose Situation -> Lesson placeholder**. Situation labels are product-friendly, no longer use `Placeholder:`, and all six topics have options; Travel includes Airport check-in, Hotel check-in, Asking for directions, Ordering transport, and Lost luggage.

## Desktop parity source model

The reviewed Windows desktop client walkthrough presentation is a product reference source for mobile parity. Mobile should preserve desktop product flow and behavior while adapting screens into phone-first layouts instead of copying the Windows UI directly. The desktop source flow is:

```text
Start -> Settings/preferences -> Choose level -> Pick topic -> Pick situation -> Practice
```

Level selection must remain a separate lesson-start step before topic/situation selection, not a Settings field. Settings parity should gradually cover profile/learning goal, study language, native language, interface/explanation language, tutor avatar, tutor voice, account/subscription, audio, and progress while keeping account/subscription/progress backend-owned.

## Product direction

The mobile app will connect to the existing production backend at:

```text
https://api.languagevoicetutor.com
```

The mobile client must use the same backend account, subscription and entitlement state, usage limits, lesson history, progress records, and AI tutor behavior as the Windows desktop app. The mobile repository remains a separate client repository; it is not the desktop/backend repository and must not duplicate backend-owned product logic.

## Architecture principles

- Android-first Flutter app, with iOS considered after the Android path is validated.
- Mobile app is a client only; it must not include backend runtime code.
- Backend remains the source of truth for accounts, sessions, entitlements, usage limits, lessons, progress, AI tutor orchestration, billing verification, and secrets.
- Mobile may cache client state for UX, but it must not become the source of truth for subscriptions, usage, lessons, or progress.
- All backend communication must use HTTPS.

## Explicit rules

The mobile app must not:

- Create or embed a mobile backend.
- Create a mobile database as the source of truth.
- Call OpenAI directly from the client.
- Make client-side Premium or entitlement decisions.
- Store OpenAI, Paddle, Google Play, Apple, JWT signing, or backend secrets.
- Add Google Play Billing runtime code during this docs-only phase.
- Add store release metadata during this docs-only phase.

## Foundation documents

- [Mobile V1 Scope](docs/MOBILE_V1_SCOPE.md)
- [Desktop Parity Source Model](docs/DESKTOP_PARITY_SOURCE_MODEL.md)
- [API Contracts and Assumptions](docs/API_CONTRACTS_ASSUMPTIONS.md)
- [Android-First Plan](docs/ANDROID_FIRST_PLAN.md)
- [Google Play Billing Plan](docs/BILLING_GOOGLE_PLAY_PLAN.md)
- [Testing Checklist](docs/TESTING_CHECKLIST.md)

## Flutter app skeleton

The Flutter project lives in `app/` and is configured Android-first with package/application id:

```text
com.languagevoicetutor.mobile
```

The skeleton includes placeholder Splash, Login, Home, Lesson, and Settings screens with simple navigation. Runtime backend integration is intentionally limited to the public health check. `https://api.languagevoicetutor.com` is the production API base URL used by the mobile API foundation, and the only backend endpoint called by this slice is `GET /health`.

### Verified Android skeleton baseline

The Android Flutter skeleton is verified locally on Android Emulator with package/application id:

```text
com.languagevoicetutor.mobile
```

Verified Android build stack:

- Gradle 8.14
- Android Gradle Plugin 8.11.1
- Kotlin Gradle Plugin 2.2.20
- Java/Kotlin target 17

Verified commands from `app/`:

```bash
flutter clean
flutter pub get
flutter analyze
flutter test
flutter run -d emulator-5554
```

If a different emulator is running, replace `emulator-5554` with the active device id from `flutter devices`. Install Flutter and Android Studio/Android SDK first if those commands are unavailable.


## Backend health check slice

The first backend-connected mobile slice is intentionally small:

- API configuration points at `https://api.languagevoicetutor.com`.
- The mobile HTTP foundation supports minimal GET requests only.
- The Settings screen exposes a **Backend connection** card with `Not checked`, `Checking...`, `Connected`, and `Unavailable` states.
- The app calls only `GET /health` and parses the public response fields `status`, `environment`, and `checkedAtUtc`.
- Timeout, network, non-success, or invalid responses are shown to users only as `Unavailable`; raw exception details and backend internals are not displayed.

Auth, account loading, subscription/Premium decisions, billing, voice mode, TTS, lesson runtime, lesson history, progress, analytics, crash reporting, secrets, and backend runtime changes are intentionally out of scope for this PR. The mobile app still must not call OpenAI directly or store provider/backend secrets.

To verify this slice from `app/`:

```bash
flutter pub get
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
```

## Next safe implementation focus

The next safe implementation focus should be Home UX polish, Settings UX polish, or lesson runtime planning. Home can become less technical and closer to a real learner start screen. Settings can reduce debug wording, improve spacing, and later move Backend diagnostics out of the normal user flow. Lesson runtime planning should inspect backend lesson/session APIs before any real lesson start is implemented. Do not jump directly into voice recording, TTS playback, billing, Google Play Billing, Apple billing, analytics, or real AI lesson runtime without a separate plan.

The first runtime integration slice should preserve the product boundary:

- Mobile is another client for the same Language Voice Tutor product.
- Users sign in with the same backend account.
- Premium entitlement remains backend-owned and backend-verified.
- Mobile must not call OpenAI directly.
- Mobile must not contain mobile secrets or provider secrets.
- Mobile must not make client-side Premium decisions.

## Open decisions before real backend integration

Before implementing real backend integration, the team should confirm:

1. Final mobile auth flow and token/session storage requirements.
2. Exact backend endpoint paths, methods, request bodies, response bodies, and error codes.
3. Whether mobile needs refresh tokens, device registration, or session revocation behavior beyond the desktop model.
4. Minimum Android SDK, target Android SDK, Flutter channel/version, and supported device classes.
5. Audio recording format, upload size limits, timeout behavior, and retry policy.
6. TTS delivery mode: generated audio URL, streaming response, or binary payload.
7. Google Play Billing product IDs, backend verification endpoint contract, and entitlement reconciliation behavior.
8. Analytics, crash reporting, privacy consent, and logging requirements.

## PR 2 auth, account, and subscription-status slice

The second backend-connected mobile slice keeps the existing `GET /health` behavior and adds only authentication, current-account loading, and subscription-status display from the existing production backend at `https://api.languagevoicetutor.com`.

Backend endpoints used by this slice:

- `GET /health`
- `POST /api/auth/register`
- `POST /api/auth/login`
- `GET /api/auth/me`
- `POST /api/auth/refresh`
- `POST /api/auth/revoke`
- `GET /api/me/subscription-status`

Premium, Trial, and Free display in the mobile Settings screen is based only on the backend `GET /api/me/subscription-status` response. The mobile app does not make client-side Premium decisions and does not call `/api/me/lesson-access` in this slice.

Auth tokens are stored only via secure mobile storage. The app does not display or log raw access tokens or refresh tokens, and no OpenAI, Paddle, Google, Apple, JWT signing, backend, or other provider secrets are added.

Still intentionally out of scope:

- Billing implementation or payment UI.
- Google Play Billing, Apple billing, and Paddle runtime.
- Voice mode, TTS, lesson runtime, lesson access UI, lesson start, lesson history/progress.
- Client-side OpenAI calls.
- Analytics and crash reporting.
- Store release setup.
- Backend runtime code and database migrations.

Verification commands from `app/`:

```bash
flutter pub get
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
```

## PR 3 lesson access check slice

This slice adds only a small backend-connected lesson access check to the Flutter mobile client. The exact endpoint used is:

```http
GET /api/me/lesson-access
```

The Home screen displays the backend lesson access decision only. Mobile does not decide Premium, Trial, free usage, limits, or lesson access locally, and it does not start a real lesson from this card.

The response fields displayed by mobile are `canStartNewLesson`, `decision`, `reason`, `premiumActive`, `trialActive`, `freeLessonUsedToday`, `freeLessonRemainingToday`, `enforcementEnabled`, and `checkedAtUtc`. Extra backend response fields are tolerated.

Out of scope for this slice: lessons, lesson chat, voice mode, TTS, lesson history/progress, billing, Google Play Billing, Apple billing, Paddle runtime, analytics, crash reporting, backend runtime changes, and database migrations.

Verification commands from `app/`:

```bash
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
```

## PR 4 tutor options slice

This slice adds only read-only tutor options loading to the Flutter mobile client. The exact backend endpoint used by this slice is:

```text
GET /api/tutor-options
```

The Home screen now displays a small **Available tutors** card with loading, unavailable, empty, and loaded states for the current tutor options response. `GET /api/tutor-options` currently returns tutor options only: `tutorId`, `displayName`, and `isActive`. It does not load a full lesson catalog, study languages, levels, topics, scenarios, or contexts. Full lesson catalog and scenario selection remain future work.

Out of scope for this PR: lesson scenario loading, lesson start, lesson chat, lesson messages, voice mode, TTS, lesson history/progress, billing, Google Play Billing, Apple billing, Paddle runtime, payment UI, analytics, crash reporting, backend runtime changes, and database migrations. Mobile still does not call OpenAI directly, does not make client-side Premium or lesson-access decisions, does not expose tokens in UI or logs, and does not store provider or backend secrets.

Verification commands from `app/`:

```bash
flutter test
flutter analyze
```

## PR 5 settings parity foundation

This slice adds the mobile Settings parity foundation using existing backend APIs only. The exact endpoints used are:

```text
GET /api/me/settings
PUT /api/me/settings
GET /api/tutor-options
```

Settings now load and save backend-supported fields only: `nativeLanguage`, `studyLanguage`, `explanationLanguage`, `speechVoice`, `speechSpeed`, `conversationModeEnabled`, and `selectedTutorId`. Extra backend settings fields are tolerated by the mobile parser.

Level is explicitly not part of Settings. To match the desktop product flow, level selection belongs after **Start lesson** in the lesson-start skeleton, before topic/situation selection.

Tutor options are loaded from `GET /api/tutor-options`. The current settings API supports `selectedTutorId`, so selected tutor persistence is backend-owned through `/api/me/settings` instead of being faked with local-only persistence. Tutor voice remains separate from selected tutor.

Out of scope for this PR: backend changes, database migrations, lesson start, lesson chat, lesson runtime, topic/scenario selection, voice recording, voice runtime, TTS runtime/playback, billing, Google Play Billing, Apple billing, Paddle runtime, history/progress, analytics, crash reporting, and store release setup.

Verification commands from `app/`:

```bash
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
```
