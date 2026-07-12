# Language Voice Tutor Mobile

Language Voice Tutor Mobile is the Android-first Flutter client for the existing Language Voice Tutor product. This repository is intentionally separate from the desktop application and backend services so mobile-specific UI, platform integration, release cadence, and store workflows can evolve independently.

## Current repository state

This repository contains the Android-first Flutter mobile client under `app/`. The current verified mobile baseline includes authenticated account/settings slices, backend health and subscription display foundations, tutor options loading for Settings, Settings parity work, Home learner-facing polish, and a phone-first lesson-start navigation skeleton. Mobile Settings reads and saves backend-owned settings through `/api/me/settings`, including `selectedTutorId`; selected tutor persistence survives app/emulator restart when the backend returns the saved ID. Tutor voice remains a separate setting and is not automatically changed by tutor selection. Home shows the user-provided Language Voice Tutor logo next to an accessible branded title, a learner-friendly account and plan card, and **Start lesson** as the primary lesson action before navigating through soft colored **Choose Level -> Choose Topic -> Choose Situation -> Lesson placeholder** screens. The placeholder displays the chosen level, topic, and situation. Level and topic cards use soft product colors, and situation cards follow the selected topic color family while remaining a UI/navigation skeleton only. The mobile logo source is `app/assets/brand/source/lvt-logo-source.png`; the Flutter app uses `app/assets/brand/lvt-logo.png`, the in-app loading screen shows only the centered logo, and Android launcher icons are resized assets derived from the same provided source logo. Real lesson runtime, lesson chat, voice recording, TTS playback, AI tutor calls, Conversation Mode runtime, billing, analytics, crash reporting, secrets, database migrations, store release setup, and backend runtime code remain intentionally out of scope.


## Current verified mobile baseline

The current verified mobile baseline includes the production-verified Android text lesson loop, completed mobile Hint and lesson-abandon flows, real per-message Translation from functional commit `9d2476b` (`Add mobile message translation`), real learner-message Feedback from functional commit `f1e8f16` (`Add mobile learner message feedback`), manual tutor-message TTS playback from functional commit `28356ff` (`Add mobile tutor voice playback`), completed learner microphone recording and speech-to-text from functional commit `e2ec9d0cdb88b6eab8b1100d46188963e05f723b` (`Add mobile speech recording and transcription`), and the settings language persistence fix from `340c950` (`Fix mobile settings language persistence`). The baseline was verified from `app/` with:

```bash
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
```

Expected current results for the completed learner microphone recording and speech-to-text baseline are: `flutter pub get` passed; Dart formatting passed; `flutter analyze` passed with zero issues; focused learner recording service tests passed with 3 tests; focused lesson-flow tests passed with 41 tests; the complete Flutter suite passed with 136 tests; the Android debug APK built successfully; and physical Android-device verification confirmed repeated correct speech recognition while existing Summary, Feedback, Translation, Hint, TTS, abandonment, and Finish behavior remained operational. Settings/password recovery remains part of this verified baseline.

Settings has stable visible **Account**, **Learning**, **Audio**, and **Connection status** advanced area, with **Save settings** visible and tested. User level is not in Settings. Settings reads `selectedTutorId` from `GET /api/me/settings` and sends it in `PUT /api/me/settings`; `/api/tutor-options` remains the source for available tutor choices in Settings. Selected tutor is editable in the **Learning** section, persists after app/emulator restart, and remains independent from the separate tutor voice setting. Home no longer shows tutor diagnostics or the old **Available tutors** card; tutor selection belongs in Settings. Home shows the provided app logo next to a branded, accessible **Language Voice Tutor** title, preloads that logo during startup before Home is shown, and displays friendly signed-in or sign-in/sync account status without raw tokens, backend IDs, or technical auth details. The loading screen shows only the centered app logo. Language dropdowns display friendly names while keeping stable internal IDs such as `en`, `tr`, and `ru`. `PUT /api/me/settings` serializes `studyLanguage` as the backend-required English study-language name (`English`, `French`, `German`, `Portuguese`, `Spanish`, or `Italian`), while native and explanation language remain in their supported backend ID form. `GET /api/me/settings` accepts IDs or English names and normalizes them to internal dropdown IDs. The complete seven-field settings payload remains in use. Study language remains limited to English, French, German, Portuguese, Spanish, and Italian. Home uses **Start lesson** to open the navigation skeleton: **Choose Level -> Choose Topic -> Choose Situation -> Lesson placeholder**. Level cards use soft level-specific colors, topic cards use soft topic-specific colors, and situation cards use the selected topic color family. Situation labels are product-friendly, no longer use `Placeholder:`, and all six topics have options; Travel includes Airport check-in, Hotel check-in, Asking for directions, Ordering transport, and Lost luggage.


## Current mobile text lesson milestone

The Android mobile client now has a complete, production-verified text lesson loop: authenticated lesson start, CMS/backend runtime opening, scenario selection through typed input, text conversation through the existing backend lesson-chat route, backend session message persistence, authenticated Finish, and backend-owned learner summary display. This flow is verified against production backend `0.1.35-backend.112` or later; `.112` is required for the verified summary path because it supports nested Responses API output extraction.

Current lesson completion routes:

```http
GET /api/me/settings
GET /api/me/lesson-access
GET /api/me/subscription-status
POST /api/me/lesson-sessions
GET /api/me/lesson-content/scenarios/{scenarioKey}
POST /api/lesson-chat/reply
POST /api/lesson-chat/feedback
POST /api/audio/speech
POST /api/me/lesson-sessions/{sessionId}/messages
POST /api/lesson-sessions/{sessionId}/abandon
PUT /api/me/lesson-sessions/{sessionId}/finish
GET /api/me/lesson-sessions/{sessionId}/summary
POST /api/auth/refresh
```

Finish sends `{ "validTurnCount": <non-negative integer> }`. Mobile counts only learner practice messages after scenario selection, excludes tutor messages, and does not invent a completion threshold. Backend owns lesson completion and summary generation; CMS/backend runtime owns tutor behavior and lesson methodology; desktop remains an orchestration reference rather than a separate mobile runtime source. Mobile never calls OpenAI directly and never generates a local summary from the transcript.

Back navigation is intentionally distinct from Finish. Visible Back and Android system Back use the same leave-confirmation flow: **Stay** keeps the learner inside the lesson and makes no backend request, while **Leave lesson** sends `POST /api/lesson-sessions/{sessionId}/abandon` with no body, using the existing authenticated bearer-token and refresh-on-401 flow, then closes the lesson screen after the backend accepts the abandon. Duplicate abandon requests are prevented. Abandon never calls Finish, requests or generates Summary, changes `validTurnCount`, creates or persists learner/tutor messages, or alters Hint behavior or transcript data. Authentication failures use the existing authentication-required behavior; network/backend failures keep the learner on the lesson screen and allow retry. Active-lesson conflict wording is neutral and does not claim the session is necessarily on another physical device. The backend remains the source of truth for lesson-session state.

The backend stale active-session interval remains two minutes. No backend timeout change and no mobile heartbeat were added. Normal confirmed Back navigation releases the session immediately; if the app is force-closed or terminated without the confirmed leave flow, the existing backend timeout remains the fallback. The two-minute timeout is intentionally retained unless real user feedback proves it needs adjustment; heartbeat or timeout tuning is optional future reliability work, not the next required task.

Summary UI states are intentionally distinct: ready displays backend learner-safe sections, unavailable means the completed lesson has no summary and shows Done without Retry, retryable load errors may show Retry summary, and authentication failures use the separate sign-in-required state. Before Finish, mobile waits up to 5 seconds for already-started message persistence operations as ordering protection only; this is not a blind retry or duplicate-write mechanism.

Text lesson foundation, Finish plus backend summary, the real mobile Hint flow, confirmed mobile lesson abandonment, real per-message Translation, real learner-message Feedback, and manual tutor-message TTS playback are complete. Learner microphone recording plus speech-to-text is complete. Pending mobile scope still includes automatic tutor playback, GIF avatar state binding, fullscreen Conversation mode, realtime/continuous voice conversation, history/progress, billing, analytics/crash reporting, and store release work. Conversation mode planning is the next isolated functional area; it is planning only, not implementation.


## Current mobile manual tutor-message TTS milestone

Manual tutor-message TTS playback is complete as a second-client integration with the existing product runtime. Mobile uses authenticated `POST /api/audio/speech` with the existing bearer-token and refresh-on-401 flow. Backend returns raw WAV bytes with `audio/wav`; owns the speech provider, model, voice processing, WAV generation, rate protection, usage enforcement, and session validation; and remains the source of truth. Flutter never calls OpenAI or another speech provider directly and contains no provider credentials.

Manual tutor playback sends the exact visible tutor message text, `purpose: lesson_chat_tts`, `speechVoice` and `speechSpeed` from backend user settings, study-language ID/English/native/code metadata, and the active backend lesson session ID. It does not send tutor profile, persisted tutor-message ID, message kind, provider model, provider instructions, or requested output format. Mobile uses a separate binary response path so existing JSON API methods remain unchanged; successful WAV data stays as bytes rather than UTF-8 text, while empty audio and unsupported content types are rejected safely.

Playback uses `just_audio`; the pubspec constraint remains `^0.9.42`, and the verified resolved version is `0.9.46`. Playback is wrapped behind a focused service/adapter so tests do not require the platform plugin, and only one `AudioPlayer` is active for the lesson screen. Play voice is available only for tutor messages, including opening and older tutor messages; learner messages, Translation text, and Feedback sections do not receive TTS controls. First playback downloads WAV bytes and caches a temporary WAV file for the current lesson screen; replay uses that cached file without another backend request. Tapping the same playing message stops it, starting another tutor message stops the previous playback, and duplicate generation requests for the same loading message are prevented.

Loading is shown only for the selected tutor message, and the control changes to Stop while playback is active. Playback errors are learner-safe and retryable. `LessonTutorStatus.speaking` is driven by actual audio playback; no GIF asset switching was added. The temporary audio cache is scoped to the active lesson screen, temporary WAV files are cleaned during screen/session cleanup, and playback stops before confirmed abandonment, Finish, Summary navigation, screen disposal, and app backgrounding. Playback does not automatically resume. Choosing Stay in the leave confirmation does not abandon the lesson. No persistent audio cache, background playback, media notifications, pause/resume controls, streaming endpoint usage, automatic playback, microphone recording, speech-to-text, Conversation mode, or GIF avatar integration was added.

TTS does not create or persist lesson messages, require tutor-message persistence, increment `learnerTurnCount` or `validTurnCount`, change Hint, Translation, Feedback, abandonment semantics, Finish payload, Summary, lesson progression, or make Premium decisions locally. It remains available while the transcript is visible and is not added to the Summary screen. Authentication failures use the existing authentication-required flow, terminal-session responses use existing session-ended handling, HTTP 429 is temporary voice unavailability, and invalid request, provider, timeout, service, network, empty-audio, and unsupported-content failures are learner-safe and retryable without exposing raw response bodies, provider details, tokens, URLs, or stack traces.

## Current learner microphone recording and speech-to-text milestone

Learner microphone recording and speech-to-text are complete as an Android-first second-client integration with the existing product runtime. Mobile uses authenticated `POST /api/audio/transcribe` with the existing bearer-token and refresh-on-401 flow. The request is `multipart/form-data`; the audio part is named `file`; and mobile sends the WAV as `audio/wav` with study-language ID, English language name, native language name, ISO language code, lesson phase, bounded transcription context, and the active backend lesson-session ID. For an English lesson, confirmed values are `targetLanguageId=en`, `targetLanguageName=English`, `targetLanguageNativeName=English`, and `targetLanguageCode=en`. Backend owns the transcription provider, model, language processing, usage protection, and session validation. Flutter does not call OpenAI or device-local speech recognition directly.

Mobile uses `record` `^7.1.1` for genuine WAV capture: PCM 16-bit, mono, 16 kHz. Android requires `RECORD_AUDIO`; `permission_handler` `^12.0.3` handles permission status and Android settings recovery. No storage or background-microphone permission was added, and this repository still has no iOS runner.

Recordings must be at least 500 ms and at most 30 seconds. Mobile validates RIFF/WAVE structure, PCM format, mono, 16 kHz, 16-bit data, duration, nonempty data, and near-silence before upload. Invalid or silent audio is rejected locally and is never sent to the backend. Temporary WAV files are deleted after success, failure, cancellation, lifecycle exit, or navigation.

A valid transcript is inserted into the existing composer, remains editable, and never sends automatically; only the existing Send button creates the learner turn. If typed text already exists or changes during transcription, the learner chooses whether to replace it. Recording and transcription do not create lesson messages or change `learnerTurnCount` or `validTurnCount`. Normal permission denial returns the microphone to a retryable state; later taps perform a new permission check; permanent denial shows an explicit Open Android settings action; permission is rechecked after returning from settings; and typed drafts remain preserved without requiring a lesson restart.

The microphone button changes to Stop during recording. Manual Stop immediately starts validation and transcription, and recording stops automatically at 30 seconds. Tutor TTS stops before recording begins. Recording is cancelled and cleaned up before Leave, Finish, Summary, navigation, disposal, or app backgrounding, and it does not automatically resume. Authentication, session-ended, invalid recording, rate limit, service unavailable, timeout, network failure, and malformed response remain distinct internal result categories; learner-facing errors are short and safe; network failures are retryable; and raw provider responses, tokens, audio contents, and technical exceptions are not shown. Automatic sending, continuous listening, Conversation mode, realtime or streaming transcription, background recording, waveform visualization, learner recording playback, local device speech recognition, and iOS implementation remain out of scope.

## Current mobile Translation milestone

The completed mobile Translation flow is implemented as a second-client integration with the existing product runtime. Mobile uses `POST /api/translate` with the existing authenticated bearer-token and refresh-on-401 flow. Backend owns provider calls, prompts, rate protection, session validation, and translation behavior; Flutter does not call OpenAI or another provider directly and does not contain provider prompts or translation methodology.

Tutor and learner messages use the same endpoint and contract. Mobile requests Translation for the exact visible message text, includes the active backend lesson session ID, and does not require a persisted lesson-message ID. The Translation target is the learner's backend-saved native language: mobile converts the saved native-language ID to the backend-compatible English language name for the request. Translation does not use interface or explanation language as its target, and source-language metadata comes from the selected study language.

Translation appears inline with the original message rather than as a new tutor or learner message. Results are cached per message: a second tap hides the cached Translation, a later tap shows it without another backend request, different messages can be translated independently, and duplicate requests for the same loading message are prevented. Translation does not persist a lesson message, increment `learnerTurnCount` or `validTurnCount`, or change Hint, abandonment, Finish, Summary, lesson progression, or subscription entitlement. Translation is not shown on the Summary screen because the transcript is not shown there.

Authentication failures use the existing authentication-required flow, session-ended responses use existing terminal-session handling, HTTP 429 is temporary Translation unavailability, and network, backend, malformed-response, and unexpected failures remain learner-safe and retryable.

## Current mobile Feedback milestone

The completed mobile Feedback flow is implemented as a second-client integration with the existing product runtime. Mobile uses `POST /api/lesson-chat/feedback` with the existing full `LessonChatRequest` contract, authenticated bearer token, and refresh-on-401 flow. Backend owns Feedback prompts, correction rules, level adaptation, scenario context, provider calls, structured output, usage events, and persistence. Flutter does not call OpenAI directly and does not contain correction methodology or provider prompts.

Feedback is available only for learner messages. Tutor messages do not show Feedback controls, and Feedback is user initiated rather than automatic. Mobile retains the real backend GUID returned when a learner message is persisted, waits for that message's existing persistence operation when needed, and never invents a backend message ID or treats the local message ID as persisted. If persistence is not ready or has failed, Feedback is not requested and the learner receives a retryable not-ready message.

Feedback requests include the exact learner text, stable local source message ID, real persisted backend message ID, active backend lesson session ID, learner-message kind, level, topic, subtopic, selected context, current transcript, last tutor message, study/native language metadata, CMS/runtime scenario data, lesson goal/type, tutor profile, and active level-profile data. The backend result contains `shortText`, `correctedVersion`, `grammarTip`, `vocabularyTip`, `cultureTip`, and `naturalVersion`; `shortText` is required and nonblank, other sections may be empty, and mobile displays only nonblank sections without inventing missing correction content.

Feedback appears in an expandable card directly below the related learner message. It is not rendered as a tutor or learner transcript message and does not replace the learner's original text. Results are cached per message, can be hidden and shown again without another backend request, maintain independent state across learner messages, prevent duplicate requests for the same loading message, and can coexist with Translation on the same learner message. Feedback remains in the study language, is not automatically translated into the learner's native language, does not use explanation language as a client-side override, and does not implement Translation of Feedback sections in this milestone.

Feedback does not create an extra lesson message, increment `learnerTurnCount` or `validTurnCount`, change the Finish payload, generate or alter Summary, change Hint, change message Translation, change lesson abandonment, or alter lesson progression or subscription entitlement. It is available only while the lesson transcript is visible and is not added to the Summary screen. Authentication failures reuse the existing authentication-required flow, terminal-session responses reuse existing session-ended handling, HTTP 429 means temporary Feedback unavailability, and provider/backend/network/malformed response failures remain learner-safe and retryable without showing raw provider or HTTP details.

## Current mobile Hint milestone

The completed mobile Hint flow is implemented as a second-client integration with the existing product runtime. After context selection, mobile uses `POST /api/lesson-chat/hint` with the same authenticated bearer-token and refresh-on-401 behavior used by lesson replies. Backend owns Hint AI prompt behavior, teaching methodology, provider calls, usage protection, and learner-safe server responses. Flutter does not call OpenAI directly and does not contain Hint prompt logic.

Before a context/situation is selected, Hint is local only: it tells the learner to choose one of the visible situations or type a custom one, does not call the backend, and does not show the CMS example Hint early. Numeric choices resolve against CMS/runtime context variants, context titles resolve case-insensitively, and custom learner-entered situations are supported without inventing a CMS variant ID. The selected context is stored in mutable lesson-screen state and reused by both lesson reply and Hint requests.

After context selection, the first active roleplay Hint may use the CMS-owned `hintRules.exampleHint`; Flutter does not create replacement scenario-specific teaching text. Later active-lesson Hint requests use the existing `LessonChatRequest` contract with the active backend session ID, runtime scenario, current context, transcript, last tutor message, level, topic, situation, and language/settings data. Hint appears as a compact dismissible inline support card rather than as a tutor or learner chat message, is not added to the transcript, blocks duplicate simultaneous requests, and is disabled during incompatible lesson operations and after successful completion.

Hint does not create a lesson message, increment `learnerTurnCount`, change `validTurnCount`, change the Finish payload, or generate or alter the lesson Summary. Authentication failures reuse the existing lesson authentication-required behavior; session-ended responses disable further lesson interaction consistently; HTTP 429 is treated neutrally as temporary Hint unavailability; and network, backend, and malformed response errors remain learner-safe and retryable.

Validation baseline for the completed lesson-abandon flow: functional commit `1a392dc` (`Add mobile lesson abandon flow`), `flutter analyze` passed with zero issues, focused AuthService and lesson screen tests passed, the complete Flutter suite passed with 107 tests, the Android debug APK build passed, and manual Android Emulator verification covered Stay, Leave lesson, immediate new lesson start, Hint, Finish, and backend-owned Summary.

## Lesson runtime source of truth and desktop/backend flow

Mobile must not invent a separate lesson runtime. Lesson behavior is owned by CMS-authored and backend-published runtime content, with the desktop app serving as the existing working reference client for orchestration. Desktop is not the owner of lesson behavior; it demonstrates how a client consumes the shared CMS/backend runtime.

Before changing mobile lesson behavior, read the desktop/CMS/backend lesson flow docs and inspect the existing desktop flow. Do not create new backend endpoints just because the mobile client does not yet mirror the existing contract.

CMS/backend published runtime content is the source of truth for:

- Tutor instructions.
- Level behavior.
- Prompt templates.
- Scenario rules.
- Wrap-up behavior.
- Feedback guidance.
- Lesson methodology.

Mobile must not call OpenAI directly, must not hardcode CMS lesson behavior in Flutter, and must not duplicate prompts, tutor rules, level rules, wrap-up rules, feedback rules, or scenario progression in the client.

The existing desktop/CMS/backend lesson flow that mobile should mirror is:

```http
GET /api/me/lesson-access
GET /api/me/subscription-status
GET /api/me/lesson-content/scenarios/{scenarioKey}
POST /api/me/lesson-sessions
POST /api/lesson-chat/reply
POST /api/lesson-chat/feedback
POST /api/audio/speech
POST /api/me/lesson-sessions/{sessionId}/messages
```

Important endpoint boundary: `POST /api/me/lesson-sessions/{sessionId}/reply` is currently a premature placeholder and must not be used for real mobile lessons at this stage. Real lesson replies should use the existing desktop/backend reply path, `POST /api/lesson-chat/reply`, and persisted messages should use `POST /api/me/lesson-sessions/{sessionId}/messages`.

The current mobile session-start request shape is backend-compatible and should remain aligned with `POST /api/me/lesson-sessions`:

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

Confirmed mobile lesson abandonment is complete. Heartbeat or timeout reduction is optional future reliability work only if real user feedback requires it, not the next required task.

Explicit no-go items for the next text-chat step:

- No temporary mobile-only backend endpoints.
- No new safe/catalog endpoints for intermediate convenience.
- No duplicate mobile prompt/runtime system.
- No backend changes unless a real final shared lesson-runtime design is approved.
- No voice, TTS, realtime, history, or billing.


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
- The Settings screen exposes a non-intrusive **Connection status** area with `Not checked`, `Checking...`, `Connected`, and `Unavailable` states.
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

The next safe implementation focus is Conversation mode planning as a separate functional area, or smaller Home/Settings UX polish. Account, entitlement, access decisions, lesson runtime, transcription, TTS, and AI behavior remain backend-owned. Do not jump directly into automatic tutor playback, fullscreen Conversation mode implementation, realtime/continuous voice conversation, billing, Google Play Billing, Apple billing, analytics, or store release work without a separate plan.

Future lesson runtime implementation rule: do not combine service, models, navigation, UI, and widget tests in one large PR. The first PR after planning should be read-only investigation or service-only, and the following PR should be UI-only using an already-tested service. The lesson runtime foundation must not add OpenAI calls from mobile and must not include voice, TTS, realtime, billing, analytics, history, or unrelated runtime features.

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
5. Future Conversation mode scope, UX, and API boundaries.
6. Future automatic tutor playback behavior, if approved separately.
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
- Conversation mode, automatic tutor playback, lesson history/progress.
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

This slice adds only read-only tutor options loading to the Flutter mobile client for Settings tutor selection. The exact backend endpoint used by this slice is:

```text
GET /api/tutor-options
```

Home no longer displays tutor diagnostics or an **Available tutors** card. Tutor choice belongs in Settings, where `GET /api/tutor-options` supplies the available tutor choices. The endpoint currently returns tutor options only: `tutorId`, `displayName`, and `isActive`. It does not load a full lesson catalog, study languages, levels, topics, scenarios, or contexts. Full lesson catalog and scenario selection remain future work.

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

Out of scope for this PR: backend changes, database migrations, Conversation mode, automatic tutor playback, billing, Google Play Billing, Apple billing, Paddle runtime, history/progress, analytics, crash reporting, and store release setup.

Verification commands from `app/`:

```bash
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
```
