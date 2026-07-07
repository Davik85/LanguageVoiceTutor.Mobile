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
- Android NDK 28.2.13676358 for debug builds and Flutter plugin native builds
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
- Settings keeps connection checking working from the non-intrusive Connection status area.
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

## PR 3 lesson access check only

This slice verifies only the mobile lesson access check. The exact backend endpoint used by the mobile client is:

```http
GET /api/me/lesson-access
```

Expected behavior:

- Home shows a **Lesson access** card.
- Tapping **Check lesson access** calls `GET /api/me/lesson-access` only when the user has a stored authenticated session.
- The request uses the stored bearer access token and the existing refresh-on-401 behavior.
- If refresh fails, the existing session-clear and return-to-login behavior is used.
- Mobile displays the backend decision only: it does not make client-side Premium, Trial, free usage, limit, or lesson-access decisions.
- The UI shows whether the backend says the user can start a lesson, a friendly backend-derived reason, and free lessons remaining today when present.
- Raw exceptions and tokens must not be displayed or logged.

Still out of scope: lessons, lesson chat, voice mode, TTS, lesson history/progress, billing, Google Play Billing, Apple billing, Paddle runtime, analytics, crash reporting, backend runtime changes, and database migrations.

Verification commands from `app/`:

```bash
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
```

## PR 4 tutor-options loading only

This slice verifies only read-only mobile tutor options loading. The exact backend endpoint used by the mobile client is:

```text
GET /api/tutor-options
```

Expected behavior:

- Home does not show an **Available tutors** card.
- Home does not show tutor diagnostics such as `Available tutors: Lana, Nelli, David`.
- Tutor selection belongs in Settings.
- Settings uses `GET /api/tutor-options` for tutor choices.
- The parser tolerates extra backend fields and intentionally models only tutor options.
- The request does not require an auth token unless the backend contract later changes.
- `GET /api/tutor-options` does not currently load a full lesson catalog, study languages, levels, topics, scenarios, or contexts; full lesson catalog and scenario selection remain future work.

Out of scope and intentionally not verified in this slice:

- Lesson scenario loading.
- Lesson start and `POST /api/me/lesson-sessions`.
- Lesson chat and lesson messages.
- Voice mode and TTS.
- Lesson history/progress.
- Billing, Google Play Billing, Apple billing, Paddle runtime, and payment UI.
- Analytics and crash reporting.
- Backend runtime code and database migrations.

Run these commands from `app/` to verify the slice:

```bash
flutter test
flutter analyze
```

## PR 5 settings parity foundation

This slice verifies mobile Settings parity foundation with the current desktop settings model, using existing backend APIs only:

```text
GET /api/me/settings
PUT /api/me/settings
GET /api/tutor-options
```

Expected behavior:

- Settings loads current backend settings when the screen opens.
- Settings saves backend-supported fields through `PUT /api/me/settings`.
- Supported settings fields are `nativeLanguage`, `studyLanguage`, `explanationLanguage`, `speechVoice`, `speechSpeed`, `conversationModeEnabled`, and `selectedTutorId`.
- Extra backend fields are tolerated.
- Account email/display name and subscription status continue to come from the existing authenticated account/subscription flow.
- Tutor options come from `GET /api/tutor-options`.
- Selected tutor is persisted through `/api/me/settings` when a valid `selectedTutorId` is supplied.
- Selected tutor persists after app/emulator restart because Settings reloads `selectedTutorId` from `GET /api/me/settings`.
- Study, native, and interface/explanation language dropdowns show user-friendly labels and save/send backend IDs rather than display labels.
- Study language choices remain limited to English, French, German, Portuguese, Spanish, and Italian.
- Native language and interface/explanation language remain separate settings with separate option catalogs.
- Level is not shown in Settings. Level selection belongs after **Start lesson** in the lesson-start skeleton.
- Friendly success/error messages are shown; raw backend exceptions, stack traces, and tokens are not displayed.

Still out of scope: backend changes, database migrations, lesson start, lesson chat, lesson runtime, topic/scenario selection, voice recording, voice runtime, TTS runtime/playback, billing, Google Play Billing, Apple billing, Paddle runtime, history/progress, analytics, crash reporting, and store release setup.

Run these commands from `app/`:

```bash
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
```

## Current green Settings parity baseline

Latest known commit: `fcecef5` (`Fix mobile settings parity foundation`). This baseline was verified from `app/` with:

```bash
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
```

Expected command results:

- `dart format --set-exit-if-changed lib test` passes.
- `flutter analyze` returns `No issues found`.
- `flutter test` returns `All tests passed`.

Settings checks for this baseline:

- **Account** section is visible.
- **Learning** section is visible.
- **Audio** section is visible.
- **Connection status** is available in a non-intrusive advanced area and can reveal **Check connection**.
- **Save settings** is visible.
- No level selector is shown in Settings.
- `selectedTutorId` is sent to `PUT /api/me/settings` and remains separate from `speechVoice`.
- Language dropdowns display user-friendly names while saving and sending backend IDs.
- Selected tutor persists after app/emulator restart.
- **Start lesson** opens the lesson-start skeleton and still ends at a placeholder Lesson screen.

Desktop parity checks:

- Mobile preserves desktop product flow and behavior without copying the Windows layout directly.
- Level selection remains a separate lesson-start step before topic/situation selection.
- Settings uses backend-supported `/api/me/settings` fields only: `nativeLanguage`, `studyLanguage`, `explanationLanguage`, `speechVoice`, `speechSpeed`, `conversationModeEnabled`, and `selectedTutorId`.
- Selected tutor persistence remains backend-owned, and tutor voice remains separate from selected tutor.

Still out of scope for the current documentation update: lesson runtime, voice recording, TTS playback, billing, analytics, Google Play Billing, Apple billing, backend changes, desktop changes, and store release metadata.

## Lesson-start navigation skeleton checks

This mobile slice adds a phone-first lesson-start navigation skeleton that follows the desktop product order: **Home -> Choose Level -> Choose Topic -> Choose Situation -> Lesson placeholder**.

Expected behavior:

- Home shows **Start lesson** instead of using **Open Lesson** as the primary direct lesson jump.
- **Start lesson** opens **Choose Level** with A1 Beginner, A2 Elementary, B1 Intermediate, and B2 Upper-Intermediate.
- Selecting a level opens **Choose Topic** with Daily Life, Travel, Work & Business, Job Interview, Restaurant & Cafe, and Free Conversation.
- Selecting Travel opens **Choose Situation** with Airport check-in, Hotel check-in, Asking for directions, Ordering transport, and Lost luggage.
- Every current topic has at least one product-friendly situation option, and no Choose Situation label contains `Placeholder:`.
- Selecting a situation opens the existing Lesson placeholder and displays the selected level, topic, and situation.
- Lesson runtime remains out of scope. Voice recording, TTS playback, AI tutor calls, Conversation Mode runtime, billing, analytics, crash reporting, backend changes, and desktop changes remain out of scope.

Verification commands from `app/`:

```bash
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
```

## Home polish checks

This mobile slice keeps Home and Settings learner-facing while backend account/access decisions remain backend-owned; real lesson runtime, voice recording, TTS playback, billing, analytics, crash reporting, backend changes, desktop changes, and store release work remain out of scope.

Expected behavior:

- The mobile logo source exists at `app/assets/brand/source/lvt-logo-source.png`.
- The app logo asset exists at `app/assets/brand/lvt-logo.png` and is derived only from the provided source logo.
- Home shows the Language Voice Tutor logo next to the **Language Voice Tutor** title.
- The logo is registered as a Flutter asset and is preloaded during startup before Home is displayed.
- The in-app loading screen shows only the centered app logo, with no loading text, slogans, diagnostics, captions, or progress wording.
- Android launcher icons exist under `app/android/app/src/main/res/mipmap-mdpi`, `mipmap-hdpi`, `mipmap-xhdpi`, `mipmap-xxhdpi`, and `mipmap-xxxhdpi`, derived from the same provided source logo.
- Home does not show **Available tutors** or `Available tutors: Lana, Nelli, David`.
- Home shows friendly signed-in account status when account data is available.
- Home shows a friendly sign-in/sync prompt when account data is unavailable.
- **Start lesson** opens **Choose Level**.
- **Open Settings** opens Settings.
- Lesson still ends at the placeholder screen; real lesson runtime remains out of scope.
- No backend, desktop, website, billing, voice, TTS, AI runtime, analytics, store metadata, signing, or package id changes are included in this branding slice.

Verification commands are the standard current baseline commands from `app/`: `dart format --set-exit-if-changed lib test`, `flutter analyze`, and `flutter test`.
