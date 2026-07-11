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

## Current verified lesson-session placeholder baseline

The current mobile baseline includes backend lesson session start from the lesson placeholder screen and service/model-only support for the session-owned reply placeholder endpoint. Real mobile AI chat is not implemented, and the reply support is not UI-wired.

Run these commands from `app/` for the restored baseline:

```bash
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
```

Expected current results:

- `git diff --check` passes.
- `dart format --set-exit-if-changed lib test` reports 39 files and 0 changes.
- `flutter analyze` reports `No issues found`.
- `flutter test` reports 90 passing tests.
- Settings/password recovery remains part of the verified baseline.
- Lesson session start is integrated from the placeholder screen, but manual emulator verification currently shows it can fail with `Could not start the lesson. Please try again.`
- Lesson runtime remains placeholder-only; real mobile AI chat is not implemented.

Future lesson runtime implementation rule:

- Do not combine service, models, navigation, UI, and widget tests in one large PR.
- The first PR should be read-only investigation or service-only.
- The next PR should be UI-only using an already-tested service.
- Mobile must not call OpenAI directly.
- The lesson runtime foundation must not include voice, TTS, realtime, billing, analytics, history, or unrelated runtime features.



## Lesson runtime contract checks

Current mobile lesson-session start should use the existing backend session-start contract, including this request shape for `POST /api/me/lesson-sessions`:

```json
{
  "lessonContentId": "everyday_english_introductions",
  "studyLanguage": "Spanish",
  "topicId": "1",
  "topicTitle": "Daily Life",
  "subtopicId": "101",
  "subtopicTitle": "Introductions",
  "level": "A1 Beginner",
  "selectedContextId": null,
  "selectedContextTitle": null,
  "modeUsed": "text"
}
```

Current completed mobile lesson behavior mirrors the existing desktop/CMS/backend runtime as a second client while keeping backend as the source of truth:

```http
GET /api/me/lesson-access
GET /api/me/subscription-status
GET /api/me/lesson-content/scenarios/{scenarioKey}
POST /api/me/lesson-sessions
POST /api/lesson-chat/reply
POST /api/me/lesson-sessions/{sessionId}/messages
POST /api/lesson-sessions/{sessionId}/abandon
PUT /api/me/lesson-sessions/{sessionId}/finish
GET /api/me/lesson-sessions/{sessionId}/summary
```

Current lesson-abandon validation baseline: functional commit `1a392dc` (`Add mobile lesson abandon flow`), `flutter analyze` passed with zero issues, focused AuthService and lesson-screen tests passed, the complete Flutter suite passed with 107 tests, the Android debug APK build passed, and manual Android Emulator verification passed for Stay, Leave lesson, immediate new lesson start, Hint, Finish, and Summary behavior.

Expected boundary checks:

- Mobile does not invent a separate lesson runtime.
- Mobile does not call OpenAI directly.
- Mobile does not hardcode CMS tutor instructions, level behavior, prompt templates, scenario rules, wrap-up behavior, feedback guidance, or lesson methodology in Flutter.
- Mobile does not use `POST /api/me/lesson-sessions/{sessionId}/reply` for real lessons at this stage.
- Desktop is used as the orchestration reference client, while CMS/backend published runtime content remains the behavior source of truth.
- Confirmed visible Back and Android system Back use the same leave-confirmation flow. Stay makes no backend request; Leave lesson abandons the unfinished session through `POST /api/lesson-sessions/{sessionId}/abandon` with no body and then closes the lesson screen.
- Abandon does not call Finish, request or generate Summary, change `validTurnCount`, persist a learner/tutor message, or alter Hint/transcript data.
- Network/backend abandon failures keep the learner on the lesson screen and allow retry; authentication failures use the existing authentication-required behavior.
- The backend stale active-session interval remains two minutes, with no backend timeout change and no mobile heartbeat. Confirmed Back releases the session immediately; force-close or termination without confirmed leave falls back to the existing backend timeout.
- No temporary mobile-only backend endpoints, new safe/catalog endpoints, duplicate mobile prompt/runtime system, or backend changes are introduced without an approved final shared lesson-runtime design.
- Translation, per-message Feedback, TTS/tutor voice, microphone recording, speech-to-text, GIF avatar states, fullscreen Conversation mode, history/progress screen, mobile billing, analytics, crash reporting, and store release remain future work. Heartbeat or timeout reduction is optional future reliability work only if real user feedback requires it.

Before changing mobile lesson behavior, read the desktop/CMS/backend lesson flow docs and inspect the existing desktop flow. Do not create new backend endpoints just because the mobile client does not yet mirror the existing contract.


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
- Home keeps the logo next to an accessible branded **Language Voice Tutor** title.
- Lesson-start cards use soft level/topic colors, and situation cards follow the selected topic color family.

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
- **Start lesson** opens **Choose Level** with soft level-specific cards for A1 Beginner, A2 Elementary, B1 Intermediate, and B2 Upper-Intermediate.
- Selecting a level opens **Choose Topic** with soft topic-specific cards for Daily Life, Travel, Work & Business, Job Interview, Restaurant & Cafe, and Free Conversation.
- Selecting Travel opens **Choose Situation** with Travel-colored cards for Airport check-in, Hotel check-in, Asking for directions, Ordering transport, and Lost luggage.
- Selecting any non-Travel topic still opens **Choose Situation**, and those situation cards use the selected topic color family.
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
- Home shows the Language Voice Tutor logo next to a branded, accessible **Language Voice Tutor** title.
- The branded title remains text, is findable by tests, and is not converted into an image.
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

## Production Android text lesson completion check

The current production-verified Android text lesson flow uses backend `0.1.35-backend.112` or later. Version `.112` is required because it supports nested Responses API output extraction for backend-owned learner summaries. No database migration was required for `.112`; backend health and database health were green during verification.

Manual Android emulator verification should cover:

1. Start an authenticated lesson session.
2. Confirm mobile loads the CMS/backend runtime scenario and renders the learner-facing opening plus scenario suggestions.
3. Choose a scenario through normal typed input.
4. Send 3-4 learner practice messages and confirm tutor replies use `POST /api/lesson-chat/reply`.
5. Confirm user and tutor messages are persisted under the backend lesson session with `POST /api/me/lesson-sessions/{sessionId}/messages`.
6. Tap **Finish lesson**, confirm the dialog, and verify mobile calls `PUT /api/me/lesson-sessions/{sessionId}/finish` with a non-negative `validTurnCount` that excludes scenario selection and tutor messages.
7. Verify mobile waits for already-started message persistence before Finish as ordering protection, without blindly retrying or duplicating message writes.
8. Verify the backend-owned summary is read from `GET /api/me/lesson-sessions/{sessionId}/summary` and the summary screen is scrollable.
9. Verify summary sections are learner-safe backend fields: lesson context, summary, strengths, improvements, vocabulary, grammar, and next steps.
10. Verify no more lesson messages can be sent after completion.
11. Verify **Done** returns from the completed lesson.
12. Verify a legitimate `200` unavailable summary state has no **Retry** button and still treats the lesson as completed.
13. Verify retryable network/server/parse summary-load errors show **Retry summary**.
14. Verify authentication failure shows the separate sign-in-required state.
15. Verify no raw server messages, stack traces, backend IDs, or provider diagnostics are displayed to learners.

Current automated verification for the working text lesson completion flow:

```bash
dart format --set-exit-if-changed lib test
flutter analyze
flutter test test/features/lesson/lesson_screen_test.dart
flutter test test/services/auth_service_test.dart
flutter test
```

Expected current result for the completed Hint flow: `flutter analyze` passes with zero issues, focused lesson screen tests pass, focused AuthService tests pass, and the full Flutter suite passes with 101 tests. Android debug APK build passed. Manual Android Emulator verification passed for context selection, contextual Hint, Finish, and backend-owned Summary. Functional Hint commit: `f9dbc06` (`Add mobile lesson hint flow`). Production backend remains `0.1.35-backend.112`.


## Production Android Hint flow check

The current production-verified Android Hint flow uses `POST /api/lesson-chat/hint` after context selection and reuses the existing authenticated bearer-token plus refresh-on-401 behavior. Backend owns AI prompt behavior, teaching methodology, provider calls, usage protection, and learner-safe server responses; Flutter does not call OpenAI directly and does not contain Hint prompt logic.

Manual Android emulator verification should cover:

1. Before context selection, tapping Hint shows local guidance to choose a visible situation or type a custom one.
2. The pre-context Hint does not call the backend and does not show the CMS example Hint.
3. Numeric choices resolve against CMS/runtime context variants.
4. Context titles resolve case-insensitively.
5. Custom learner-entered situations are accepted without inventing a CMS variant ID.
6. The selected context is reused by both lesson reply and Hint requests.
7. The first active roleplay Hint may use CMS-owned `hintRules.exampleHint`.
8. Later Hint requests include the active backend session ID, runtime scenario, current context, transcript, last tutor message, level, topic, situation, and language/settings data.
9. Hint displays as a compact dismissible inline support card, not as a tutor or learner chat message.
10. Hint is not added to the transcript and does not create a persisted lesson message.
11. Duplicate simultaneous Hint requests are blocked.
12. Hint is disabled during incompatible lesson operations and after successful completion.
13. Hint does not increment `learnerTurnCount`, change `validTurnCount`, alter the Finish payload, or generate/change the Summary.
14. Authentication failures, session-ended responses, HTTP 429 temporary unavailability, network errors, backend errors, and malformed responses remain learner-safe and consistent with the lesson flow.

Current automated and build verification for the working Hint flow:

```bash
flutter analyze
flutter test test/services/auth_service_test.dart
flutter test test/features/lesson/lesson_screen_test.dart
flutter test
flutter build apk --debug
```

Expected current result: analyze reports zero issues, focused AuthService and lesson screen tests pass, the complete Flutter suite passes with 101 tests, and the Android debug APK build passes.

Still unimplemented unless a later repository change proves otherwise: real Translation, real per-message Feedback, TTS/tutor voice playback, microphone recording, speech-to-text, GIF avatar state integration, fullscreen Conversation mode, history/progress screen, mobile billing, analytics, crash reporting, and store release.

Next isolated engineering task: active lesson lifecycle on mobile. A confirmed leave should use the existing backend abandon flow, Back navigation must not silently Finish a lesson, and ordinary leave must not generate a Summary. This documentation task does not implement that functionality.
