# Testing Checklist

## Progress data foundation checks

Run from `app/`:

```bash
dart format --set-exit-if-changed lib test
flutter analyze
flutter test test/models/progress_test.dart test/services/progress_service_test.dart test/services/auth_service_test.dart test/services/lesson_history_service_test.dart
```

Verify `GET /api/me/progress` uses the shared authenticated refresh-on-401 path, preserves backend-provided official values, sends no user ID, never calls `/api/dev`, and performs no History aggregation. The learner-facing UI consumes those same backend values without local official calculations.

Progress UI verification covers the authenticated Home entry, duplicate-navigation protection, loading, backend-value success rendering, successful empty state, sign-in-required routing, unavailable/retry behavior, optional distributions, accessible backend daily-activity cells, small-screen scrolling, and no local History aggregation or chart dependency.

## Six-language lesson parity checks

- Verify the centralized study-language definitions exactly cover `en`, `fr`, `de`, `pt`, `es`, and `it`, resolve by ID/English/native name case-insensitively, and fall back to English.
- Verify study-language dropdown values derive from that catalog; native/translation and interface-language catalogs remain separate.
- For every language, verify localized setup, scenario titles, known-context confirmation/opening, pre-context Hint, and first local example Hint.
- Verify numeric, canonical English, localized French/Spanish, punctuation/case, alias, custom-context, and later-active-turn scenario resolution while preserving canonical CMS IDs/titles/variants/scenario keys.
- Verify reply, Hint, Feedback, transcription, Lesson Chat TTS, and Conversation TTS send the exact centralized ID, English name, native name, and language code; session start sends the backend-compatible English study-language name.
- Verify English behavior remains unchanged and non-English CMS English text is semantic metadata rather than tutor-facing setup output.
- Confirm no ARB files, `flutter_localizations`, general UI translation, client OpenAI call, backend endpoint, CMS prompt, or backend deployment was added.
- Automated checks do not replace physical Android coverage. Owner physical Android verification is complete for the six-language study-language slice: all six study languages can be selected and saved in Settings; lessons launch using the selected study language; speech recognition uses the selected study language; and Conversation mode works using the selected study language. Supported study-language entries are `en` — English — English, `fr` — French — Français, `de` — German — Deutsch, `pt` — Portuguese — Português, `es` — Spanish — Español, and `it` — Italian — Italiano. Implementation commit `f046f82` (`feat: add six-language mobile lesson parity`) delivered this slice. Automated verification for implementation commit `f046f82` had already completed before this documentation update: `flutter analyze` passed with no issues, focused language-parity tests passed with 95 tests, the full Flutter suite passed with 226 tests, implementation was committed and pushed, and no backend or CMS deployment was required. Broader repeated testing on different physical devices and network conditions may still be useful.

## Lesson History verification baseline

Run from `app/`:

```bash
dart format --set-exit-if-changed lib test
flutter analyze
flutter test test/models/lesson_history_test.dart test/services/lesson_history_service_test.dart test/home_screen_test.dart test/lesson_history_screen_test.dart
flutter test test/lesson_history_detail_screen_test.dart test/lesson_history_screen_test.dart
flutter test
```

Confirmed baseline after detail commit `a200641`: formatting passed; analysis reported **No issues found**; focused History model/service/Home/list tests passed; focused detail/navigation tests passed; and the complete Flutter suite passed **261 tests**. The package-resolution notice that newer mutually incompatible package versions exist is informational; this History work included no dependency upgrade. Existing automated evidence is sufficient for this documentation-only update, so the full suite need not be rerun unless source changes.

Coverage confirms authenticated routes, refresh behavior, no `/api/dev` use, blank-ID validation, safe auth/404/network/malformed/generic mapping, backend-order list rendering, loading/populated/empty/retry/auth states, learner-safe visible fields, hidden internals, no detail prefetch, detail loading/validation/not-found/retry/auth/success states, ordered learner/tutor transcript, connected feedback, Back navigation, and duplicate retry/navigation protection. A physical-device pass may still review small-screen spacing only; it is not a functional or backend blocker.

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
POST /api/lesson-chat/feedback
POST /api/me/lesson-sessions/{sessionId}/messages
POST /api/lesson-sessions/{sessionId}/abandon
PUT /api/me/lesson-sessions/{sessionId}/finish
GET /api/me/lesson-sessions/{sessionId}/summary
```

Current Feedback validation baseline: functional commit `f1e8f16` (`Add mobile learner message feedback`), dart formatting passed, `flutter analyze` passed with zero issues, focused AuthService tests passed with 32 tests, focused lesson-flow tests passed with 35 tests, the complete Flutter suite passed with 123 tests, the Android debug APK built successfully, and manual Android Emulator verification confirmed Feedback display under the learner message. Existing Translation, Hint, abandon, Finish, and Summary behavior remained operational.

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
- Per-message Translation, real per-message learner Feedback, manual tutor-message TTS playback, learner microphone recording plus speech-to-text, and mobile voice lesson and Conversation mode flows are complete. Manual tutor-message TTS playback is complete in functional commit `28356ff` (`Add mobile tutor voice playback`). Learner microphone recording plus speech-to-text is complete in functional commit `e2ec9d0cdb88b6eab8b1100d46188963e05f723b` (`Add mobile speech recording and transcription`). Mobile voice lesson and Conversation mode flows are complete in functional commit `f195dc2` (`feat: add mobile voice lesson and conversation flows`); see `docs/MOBILE_VOICE_LESSON_STATE.md` for the authoritative voice scenario flow. History and Progress are complete; Progress uses its separate backend-owned aggregate contract and must not be calculated from the recent History list. Mobile billing, analytics, crash reporting, and store release remain future work. Heartbeat or timeout reduction is optional future reliability work only if real user feedback requires it.

Before changing mobile lesson behavior, read the desktop/CMS/backend lesson flow docs and inspect the existing desktop flow. Do not create new backend endpoints just because the mobile client does not yet mirror the existing contract.



## Current authentication resilience and Feedback & reports checks

Authentication resilience verification recorded these focused results: AuthService tests passed with 44 tests, Splash tests passed with 2 tests, and `flutter analyze` reported no issues. Expected behavior is that refresh outcomes are classified as success, invalid session, or temporary failure; only proven invalid sessions clear stored tokens; temporary network, timeout, malformed-response, rate-limit, and backend failures preserve tokens; JSON, binary TTS, multipart transcription, and voice-scenario 401 handling share a single-flight refresh coordinator; stale 401 responses retry a newer stored access token first; and Splash sends the learner to Login only for a proven invalid session.

Feedback & reports verification recorded these focused results after support was added: AuthService tests passed with 45 tests, Settings tests passed with 27 tests, and `flutter analyze` reported no issues. Expected behavior is that Settings exposes a collapsed **Feedback & reports** card; requires description text; rejects blank descriptions locally; optionally accepts reported AI text for AI response reports; disables Send while active; preserves text on temporary failures; clears fields on success; and shows **Thank you. Your message has been received.**

Production integration and physical Android verification are recorded as complete for Feedback & reports: migration `20260717120148_AddUserFeedbackReports` was applied, backend release `0.1.35-backend.117` was deployed, initial HTTP 503 from table ownership was corrected by changing production ownership to `lvt_app`, and suggestion, app_issue, and ai_response submissions from the physical Android device produced three verified production records with status `new`, `ClientPlatform` `android`, and `ClientVersion` `0.1.0+1`. Remaining boundaries: no CMS review screen, no email workflow, no attachments/screenshots, no per-message report button, no automatic moderation/OpenAI forwarding, no Mobile database, and no release-work completion from this slice.

## Current Feedback validation baseline

Confirmed results for the completed learner-message Feedback baseline:

- Functional commit: `f1e8f16` (`Add mobile learner message feedback`).
- Dart formatting passed.
- `flutter analyze` passed with zero issues.
- Focused AuthService tests passed with 32 tests.
- Focused lesson-flow tests passed with 35 tests.
- The complete Flutter suite passed with 123 tests.
- Android debug APK built successfully.
- Manual Android Emulator verification confirmed Feedback display under the correct learner message.
- Existing Translation, Hint, abandon, Finish, and Summary behavior remained operational.

## Current manual tutor-message TTS validation baseline

Confirmed results for completed manual tutor-message TTS playback:

- Functional commit: `28356ff` (`Add mobile tutor voice playback`).
- `flutter pub get` passed.
- Dart formatting passed.
- `flutter analyze` passed with zero issues.
- Focused AuthService tests passed with 32 tests.
- Focused playback-service tests passed with 4 tests.
- Focused lesson-flow tests passed with 35 tests.
- The complete Flutter suite passed with 127 tests.
- Android debug APK built successfully.
- Manual Android Emulator verification passed without issues.
- Hint, Translation, Feedback, abandonment, Finish, and Summary remained operational.
- Manual tutor-message TTS uses `POST /api/audio/speech`, raw WAV bytes, temporary current-screen cache, and `just_audio` (`^0.9.42`, resolved `0.9.46`).
- Automatic playback, microphone recording, speech-to-text, audio streaming endpoint usage, background playback, media notifications, pause/resume controls, Conversation mode, and GIF avatar integration remain out of scope.

## Current learner microphone recording and speech-to-text validation baseline

Confirmed results for completed learner microphone recording and speech-to-text:

- Functional commit: `e2ec9d0cdb88b6eab8b1100d46188963e05f723b` (`Add mobile speech recording and transcription`).
- `flutter pub get` passed.
- Dart formatting passed.
- `flutter analyze` passed with zero issues.
- Focused learner recording service tests passed with 3 tests.
- Focused lesson-flow tests passed with 41 tests.
- The complete Flutter suite passed with 136 tests.
- Android debug APK built successfully.
- Physical Android-device tests confirmed repeated correct transcription.
- Existing Summary, Feedback, Translation, Hint, TTS, abandonment, and Finish behavior remained operational.
- Learner microphone transcription uses `POST /api/audio/transcribe`, authenticated multipart `audio/wav` upload with audio part `file`, Android `RECORD_AUDIO`, `record` `^7.1.1`, and `permission_handler` `^12.0.3`.
- Automatic sending, continuous listening, Conversation mode, realtime/streaming transcription, background recording, waveform visualization, learner playback, local device speech recognition, and iOS implementation remain out of scope.

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

## Account-deletion boundary checks

Before any Mobile account-deletion UX change, verify that submission remains a backend support request rather than local deletion. After backend anonymization, verify that a new login and refresh fail, while an already-issued access token is handled only until normal expiry; when refresh proves the session invalid, Mobile clears the session. This accepted expiry window does not itself require a Mobile or backend authentication change.

## Future local-notification and localization checks

Local Android practice reminders are implemented with `flutter_local_notifications`, `flutter_timezone`, and `timezone`. Automated verification runs `flutter test test/services/practice_reminder_service_test.dart test/services/practice_reminder_preferences_test.dart`, `flutter test test/home_screen_test.dart test/settings_screen_test.dart`, `flutter test`, and `flutter build apk --debug`. Physical Android checks remain: Android 13+ permission timing and denial/settings recovery, notification delivery at device-local times across timezone changes, and receiver-based restoration after reboot.

Implement and verify in the approved order: local Android practice reminders, complete Premium UI and purchase entry points, Google Play Billing with backend verification and restore/reconciliation, then complete 14-language static-interface localization.

- Verify Notifications V1 is local-only: no Firebase, remote/server push, push token, backend endpoint/state, remote provider, or background microphone behavior.
- Verify product settings default reminders to enabled, schedule cheerful learner-facing morning and evening reminders at device-local 09:00 and 20:00, allow both times to be changed, and allow all reminders to be disabled.
- Verify Android notification permission is required for delivery, is not requested on Splash or before the learner sees the product experience, follows a benefit explanation, does not reprompt on every launch after denial, and offers Android settings recovery where practical.
- Verify local schedules retain device-local 09:00/20:00 semantics across timezone changes and are restored after reboot where Android requires it. Do not require exact-alarm permission without evidence it is needed.
- Verify reminder wording does not imply continuous cross-device synchronization or guaranteed suppression after a Desktop or other-device lesson.
- Verify the 14 interface languages are exactly `en`, `es`, `fr`, `de`, `it`, `pt`, `ru`, `pl`, `ar`, `ja`, `ko`, `sr`, `hr`, and `bg`, separate from the six study languages.
- Verify first-use interface and explanation/translation language initialization normalizes supported regional locales to the base language, falls back to English for unsupported device languages, and yields to saved backend-owned settings after explicit save.
- Verify localization covers static UI, validation, notification, Premium, and billing content but does not translate AI replies, learner messages, backend-generated content, CMS identifiers, canonical scenario keys, internal IDs, or backend data. Verify Arabic right-to-left layout.

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

Before billing implementation, complete the separate learner-facing Premium UI and purchase-entry-point stage. Confirm that local buttons, purchase callbacks, and unverified store results never unlock Premium; billing requires purchase-token submission, backend verification, entitlement refresh, restore/reconciliation, relevant lifecycle states, and no Paddle change for website/desktop.

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

- The obsolete Choose Level screen, `/choose-level` route, and import are deleted; `ChooseLevelScreen` and `choose_level_screen.dart` no longer exist.

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

- The obsolete Choose Level screen, `/choose-level` route, and import are deleted; `ChooseLevelScreen` and `choose_level_screen.dart` no longer exist.

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

- The obsolete Choose Level screen, `/choose-level` route, and import are deleted; `ChooseLevelScreen` and `choose_level_screen.dart` no longer exist.

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
- **Current level** is shown before **Study language**, displays labels from `lessonLevels`, and saves canonical uppercase `A1`, `A2`, `B1`, or `B2` through `PUT /api/me/settings` only when **Save settings** is used.
- A failed settings save restores the last backend-confirmed level; the backend remains the account-level source of truth.
- `selectedTutorId` is sent to `PUT /api/me/settings` and remains separate from `speechVoice`.
- Language dropdowns display user-friendly names while saving and sending backend IDs.
- Selected tutor persists after app/emulator restart.
- **Start lesson** fetches backend `UserSettings.currentLevel`, resolves it through `lessonLevels`, and opens **Choose Topic** directly.
- Home keeps the logo next to an accessible branded **Language Voice Tutor** title.
- Topic cards use soft colors, and situation cards follow the selected topic color family.

Desktop parity checks:

- Mobile preserves desktop product flow and behavior without copying the Windows layout directly.
- Learner level changes are made in **Settings -> Learning**; Choose Level is removed from the normal Home flow.
- Settings uses backend-supported `/api/me/settings` fields only: `nativeLanguage`, `studyLanguage`, `explanationLanguage`, `speechVoice`, `speechSpeed`, `conversationModeEnabled`, `selectedTutorId`, and `currentLevel`.
- Selected tutor persistence remains backend-owned, and tutor voice remains separate from selected tutor.
- `lessonLevels` remains the centralized Mobile level display list, while CMS-published level profiles remain authoritative for lesson behavior and timing.
- Physical Android validation of the saved-level Settings control and normal lesson-start flow is complete for this learner-level/start-flow slice.

Still out of scope for the current documentation update: lesson runtime, voice recording, TTS playback, billing, analytics, Google Play Billing, Apple billing, backend changes, desktop changes, and store release metadata.

## Lesson-start navigation skeleton checks

The normal phone-first lesson-start flow is **Home -> Choose Topic -> Choose Situation -> Lesson**.

Expected behavior:

- The obsolete Choose Level screen, `/choose-level` route, and import are deleted; `ChooseLevelScreen` and `choose_level_screen.dart` no longer exist.

- Home shows **Start lesson** instead of using **Open Lesson** as the primary direct lesson jump.
- **Start lesson** loads backend `UserSettings.currentLevel` once, resolves it through `lessonLevels`, and opens **Choose Topic** directly with the matching display label.
- Repeated taps while settings load do not duplicate requests or navigation; authentication failure returns to Login, while ordinary failure keeps Home visible with a friendly retry message.
- **Choose Topic** shows soft topic-specific cards for Daily Life, Travel, Work & Business, Job Interview, Restaurant & Cafe, and Free Conversation.
- Selecting Travel opens **Choose Situation** with Travel-colored cards for Airport check-in, Hotel check-in, Asking for directions, Ordering transport, and Lost luggage.
- Selecting any non-Travel topic still opens **Choose Situation**, and those situation cards use the selected topic color family.
- Every current topic has at least one product-friendly situation option, and no Choose Situation label contains `Placeholder:`.
- Selecting a situation preserves the resolved level display label in `LessonStartSelection` and the existing lesson-session/runtime chain.
- CMS-published level profiles remain authoritative for language complexity, correction and hint behavior, answer length, wrap-up timing, and final-turn timing.
- No backend deployment was required because backend release `0.1.35-backend.116` already provided the required `CurrentLevel` settings contract.
- Physical Android owner verification for this slice confirmed: Choose Level no longer appears; learner level is available in Settings -> Learning; changing and saving the level works; Start lesson opens Choose Topic directly; the lesson starts correctly using the saved level; speech recognition works; Lesson Chat works; Conversation mode works; backend-owned lesson completion and summary generation work; and the summary is displayed successfully.
- Lesson runtime remains out of scope for this cleanup. No backend, Desktop, CMS, website, billing, voice-provider, transcription-provider, semantic resolver, TTS, or database migration changes were made. Billing, analytics, crash reporting, broader platform work, and missing Lesson Chat avatar assets remain separate where still unresolved.

Verification commands from `app/`:

```bash
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
```

## Home polish checks

This mobile slice keeps Home and Settings learner-facing while backend account/access decisions remain backend-owned; real lesson runtime, voice recording, TTS playback, billing, analytics, crash reporting, backend changes, desktop changes, and store release work remain out of scope.

Expected behavior:

- The obsolete Choose Level screen, `/choose-level` route, and import are deleted; `ChooseLevelScreen` and `choose_level_screen.dart` no longer exist.

- The mobile logo source exists at `app/assets/brand/source/lvt-logo-source.png`.
- The app logo asset exists at `app/assets/brand/lvt-logo.png` and is derived only from the provided source logo.
- Home shows the Language Voice Tutor logo next to a branded, accessible **Language Voice Tutor** title.
- The branded title remains text, is findable by tests, and is not converted into an image.
- The logo is registered as a Flutter asset and is preloaded during startup before Home is displayed.
- The in-app loading screen shows only the centered app logo, with no loading text, slogans, diagnostics, captions, or progress wording.
- Android launcher icons exist under `app/android/app/src/main/res/mipmap-mdpi`, `mipmap-hdpi`, `mipmap-xhdpi`, `mipmap-xxhdpi`, and `mipmap-xxxhdpi`, derived from the same provided source logo.
- Home does not show **Available tutors** or `Available tutors: Lana, Nelli, David`.
- Home shows friendly signed-in account status when account data is available.
- Home uses a learner-safe fallback when account data is unavailable; it never exposes backend or user-ID diagnostics.
- **Start lesson** loads the saved backend level and opens **Choose Topic** directly; Choose Level is not shown in the normal flow.
- **Open Settings** opens Settings.
- Settings uses bottom navigation for **Profile**, **Lessons**, and **App**. Lesson History and Progress open from **Lessons**, while Feedback & reports and Connection status live in **App**.
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

Expected current result for the saved-level lesson-start cleanup: `dart format --set-exit-if-changed lib test` passed with 72 files checked; `flutter analyze` passed with no issues; focused Home/start-flow tests passed with 70 tests; full Flutter suite passed with 208 tests; stale-reference searches found no `ChooseLevelScreen`, `choose_level_screen.dart`, or `/choose-level`; protected runtime files had no diff; and CMS runtime parsing, lesson limits, lesson timing, voice request behavior, transcription behavior, semantic resolution, and summary contracts were not changed.

Real Translation is complete in functional commit `9d2476b` (`Add mobile message translation`). Real per-message learner Feedback is complete in functional commit `f1e8f16` (`Add mobile learner message feedback`). Manual tutor-message TTS playback is complete in functional commit `28356ff` (`Add mobile tutor voice playback`). Learner microphone recording plus speech-to-text is complete in functional commit `e2ec9d0cdb88b6eab8b1100d46188963e05f723b` (`Add mobile speech recording and transcription`). Mobile voice lesson and Conversation mode flows are complete in functional commit `f195dc2` (`feat: add mobile voice lesson and conversation flows`). Desktop-parity transcription behavior is complete for the documented Mobile state: Lesson Chat and Conversation mode share the same transcription request builder, speech recognition always uses the selected study language definition, native/explanation language do not influence transcription, and the existing `POST /api/audio/transcribe` multipart contract remains unchanged with no backend deployment requirement. Completed verification: `dart format` succeeded; `flutter analyze` completed with no issues; `lesson_start_flow_test.dart` passed with 58 tests; `conversation_mode_screen_test.dart` passed with 5 tests; `transcript_script_normalizer_test.dart` passed with 3 tests; transcription-parity focused tests passed with 12 tests; full Flutter suite passed with 197 tests and 0 failures; debug Android APK build succeeded. The saved-level learner-level/start-flow slice has completed physical Android validation. Broader repeated testing on different physical devices and network conditions may still be useful; do not declare voice recognition fully stabilized yet. Missing Lesson Chat avatar assets remain separate. The optional Desktop Realtime transcription language issue is outside this Mobile change. History is implemented and verified. Still unimplemented: the separate backend-owned Progress aggregate contract, mobile billing, analytics, crash reporting, and store release.

## Current achievements and lesson-presentation regression checks

From `app/`, run:

```bash
flutter analyze --no-pub
flutter test test/lesson_start_flow_test.dart
```

The start-flow fixture must provide the Home requests it triggers: a permitted lesson-access result and unavailable Progress and Achievements results. It must not attempt to navigate to `/login`; that route is intentionally absent from this focused test app. The current `lesson_start_flow_test.dart` result is 60 passing tests, including the layout assertion that the larger microphone action is centered while keyboard and Hint are at the dock edges. `settings_screen_test.dart` covers the Rewards row opening the complete achievements screen, and `home_screen_test.dart` covers a selected daily bar displaying its backend-provided completed-lesson count. The lesson visual boundary is local to `LessonScreen`: Home and Settings retain product-blue typography, while feedback and summary retain their own neutral, sectioned presentation. Current combined focused result: 108 passing tests across Settings, Home, and lesson-start flow.
