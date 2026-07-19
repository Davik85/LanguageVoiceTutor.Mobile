# Mobile V1 Scope

## Goal

Mobile V1 establishes an Android-first Flutter client for Language Voice Tutor that uses the existing production backend and shared product model. The current Android skeleton baseline is verified locally on Android Emulator, but the app now includes working authenticated lesson and Lesson History flows. It lets an existing or new user access the same account, subscription entitlement, usage limits, lesson history, progress, and AI tutor behavior used by the Windows desktop app.

## Supported lesson languages

Mobile V1 lesson practice now supports `en`, `fr`, `de`, `pt`, `es`, and `it` through one authoritative study-language catalog. Tutor-facing local lesson setup, scenario labels, known-context roleplay openings, and local Hints follow the selected study language. Session start keeps the backend-compatible English language name; reply/Hint/Feedback requests, transcription, and TTS carry the centralized ID, English name, native name, and language code. Native/translation language and interface language do not select the practiced language. Stable CMS IDs, canonical English titles, runtime variants, and scenario keys remain canonical backend metadata. UI localization is explicitly outside this phase, no backend/CMS deployment was required, and owner physical Android verification is complete for the six-language study-language slice: all six study languages can be selected and saved in Settings; lessons launch using the selected study language; speech recognition uses the selected study language; and Conversation mode works using the selected study language.

## Current verified baseline

Latest known functional learner microphone recording and speech-to-text commit: `e2ec9d0cdb88b6eab8b1100d46188963e05f723b` (`Add mobile speech recording and transcription`). Latest known functional Feedback commit: `f1e8f16` (`Add mobile learner message feedback`). Latest known functional Translation commit: `9d2476b` (`Add mobile message translation`). Latest known settings language persistence fix: `340c950` (`Fix mobile settings language persistence`). The Flutter Android client under `app/` has a production-verified text lesson loop, completed mobile Hint flow, shared Lesson Chat/Conversation mode transcription request building for Desktop-parity transcription behavior, and green Settings parity/Home polish baseline. Settings has stable visible **Account**, **Learning**, **Audio**, and **Connection status** sections, and **Save settings** is visible and tested. **Learning** reads and saves the backend-owned account `CurrentLevel`; `lessonLevels` remains the centralized Mobile display and mapping collection. Home Start lesson loads that setting and opens Choose Topic directly, so Choose Level is no longer part of the normal flow. Selected tutor also persists through the backend settings API. CMS-published level profiles remain the source of lesson behavior and timing; Mobile does not own lesson complexity or duration rules. No backend deployment was required because backend release `0.1.35-backend.116` already provided the required `CurrentLevel` settings contract, and the owner physically verified this saved-level lesson-start slice on an Android phone.

Verified commands from `app/`:

```bash
flutter clean
flutter pub get
flutter analyze
flutter test
flutter run -d emulator-5554
```

Verified Android build stack:

- Gradle 8.14
- Android Gradle Plugin 8.11.1
- Kotlin Gradle Plugin 2.2.20
- Java/Kotlin target 17


## Lesson History current state

## Progress data foundation

Backend `0.1.35-backend.124` provides authenticated `GET /api/me/progress`. Mobile has immutable response models and `fetchProgress()` using the existing authenticated refresh flow, but no Progress screen, Home entry, chart, or local official aggregation. The backend remains the source of truth for UTC/calendar rules, completion rules, totals, windows, and streaks; History remains limited to its recent 50-item contract.

Lesson History is complete in three committed slices: data foundation `4d531e3`, recent-list UI and Home navigation `2c88944`, and detail UI `a200641`. Mobile is another client of the same Language Voice Tutor product: History belongs to the authenticated backend account shared with Desktop and Website. The backend is the source of truth; Mobile neither reads Desktop-local JSON nor calls `/api/dev`, stores an independent local copy of official History, makes ownership decisions, or decides Premium access. The only History routes are:

```http
GET /api/me/lesson-history
GET /api/me/lesson-history/{sessionId}
```

The data foundation provides list and detail models plus summary, transcript-message, and feedback models without duplicating backend business logic. `fetchLessonHistory()` and `fetchLessonHistoryDetail(sessionId)` use the shared authenticated GET and refresh-on-401 behavior. Result/status mapping safely separates success, validation, authentication-required, not-found, temporary network unavailability, malformed/generic failure, and other failures; blank detail IDs are rejected before a request, and detail IDs are safely path-encoded.

Home now exposes the learner-facing **Lesson history** entry. The History screen loads recent backend-provided sessions, preserves backend ordering, and handles initial loading, populated, empty, retry/error, and authentication-required states. Cards show learner-facing topic, subtopic, level, friendly date, selected context, lesson mode, completion state, valid turns/message count, and summary preview where available. They hide session/content IDs, estimated cost, raw timestamps, and backend internals. The list is not described as complete all-time History, and details are not prefetched. Duplicate list retries and duplicate card navigation are guarded.

Tapping a card opens **Lesson details** and then calls `fetchLessonHistoryDetail(sessionId)` once for the initial load. The screen handles loading, local ID validation, not-found, retryable network/generic failure, authentication-required, and success states; only retryable failures show Retry, and duplicate retries are guarded. Success shows a lesson overview, only non-empty backend summary sections, transcript messages in backend order with **You**/**Tutor** distinction, and feedback connected to its transcript message when available. It hides internal IDs, estimated cost, transcript confidence, audio duration, raw source/role codes, and raw timestamps. Back returns to the History list.

The backend list contract currently returns up to **50 recent sessions**. It must not be treated as the official source for all-time learning statistics: Mobile must not derive official totals, streaks, or other local aggregates from this bounded list. Future **Progress** requires a separate backend-owned aggregate endpoint and contract. History did not add Progress, streaks, all-time totals, pagination, local History storage, backend/Desktop changes, billing, voice/transcription/TTS changes, dependency upgrades, Android release configuration, APK/store release work, or deployment work. A physical-device check may still review small-screen spacing, but automated coverage establishes the functional flow and it is not a backend or functional blocker.

## Authentication and session resilience

Mobile authentication is hardened so temporary backend or network problems do not incorrectly log users out. Refresh outcomes are classified as `success`, `invalid session`, or `temporary failure`; only a proven invalid session clears stored tokens. Temporary network, timeout, malformed-response, rate-limit, and backend failures preserve stored tokens, and temporary Splash session-check failures remain retryable instead of automatically routing to Login. Concurrent HTTP 401 responses share one single-flight refresh operation across JSON, binary TTS, multipart transcription, and voice-scenario paths. A stale HTTP 401 first retries a newer stored access token before starting another refresh. Access tokens remain 60 minutes, refresh tokens remain 30 days, backend refresh tokens rotate, and reuse of a rotated refresh token revokes its token family. No backend change or deployment was required for this Mobile session-resilience fix. Focused verification recorded 44 AuthService tests passed, 2 Splash tests passed, and `flutter analyze` reported no issues.

## Feedback & reports

Settings contains a collapsed expandable **Feedback & reports** card with subtitle **Send a suggestion or report a problem**. The supported categories are Suggestion, App problem, and AI response. Description is required, blank descriptions are rejected locally, AI response reports show an optional field for pasting the AI response, Send is disabled while submission is active, temporary failures preserve entered text for retry, successful submission clears the fields, and success shows **Thank you. Your message has been received.**

Mobile submits `POST /api/me/feedback-reports` through the existing authenticated JSON client and shared single-flight token refresh behavior. The payload sends `category`, `message`, optional `reportedAiText`, `clientPlatform: android`, and `clientVersion: 0.1.0+1`. Mobile does not send `UserId`, access token as request data, refresh token, email, device identifier, attachments, screenshots, lesson transcript, or unrelated account data. Report text and AI response text are not written to Mobile logs. Focused verification after Feedback & reports support recorded 45 AuthService tests passed, 27 Settings tests passed, and `flutter analyze` reported no issues.

Production integration is verified: backend migration `20260717120148_AddUserFeedbackReports` was applied and backend release `0.1.35-backend.117` was deployed. The initial submission returned HTTP 503 because the new table was owned by `postgres` and `lvt_app` lacked permission; production table ownership was corrected to `lvt_app`. After correction, suggestion, app_issue, and ai_response reports were successfully submitted from a physical Android device. Three production records were verified with status `new`, `ClientPlatform` `android`, and `ClientVersion` `0.1.0+1`.

Boundaries remain: no CMS report-review screen exists yet, no email workflow exists, no attachments or screenshots are supported, no report button was added to individual chat messages, no automatic moderation or OpenAI forwarding exists, no new Mobile database was created, backend remains the owner of persistence and authenticated `UserId`, and a future CMS list with `new`, `reviewed`, and `resolved` states remains separate work. Flutter interface localization remains pending; billing, analytics, crash reporting, Progress, signing, Play Console, and store release work remain separate.

## Repository strategy

Language Voice Tutor Mobile is maintained as a separate repository from the desktop app and backend services.

This separation is intended to keep mobile concerns isolated:

- Flutter application structure and dependencies.
- Android platform configuration.
- Mobile UI and navigation.
- Audio capture and playback behavior.
- Store billing integration.
- Mobile QA and release workflows.

The repository must not duplicate backend business logic or become a fork of backend behavior.

## Desktop parity source model

The reviewed Windows desktop client walkthrough presentation is now a product reference source for mobile parity. Mobile must match desktop product logic, not desktop pixel layout, and should translate desktop screens into phone-first layouts. The desktop source flow was `Start -> Settings/preferences -> Choose level -> Pick topic -> Pick situation -> Practice`, but Mobile now uses the accepted saved-level flow. Learner level selection lives only in **Settings -> Learning** for the normal user flow, and lesson start proceeds through `Home -> Choose Topic -> Choose Situation -> Lesson`.

Study language, native language, and interface/explanation language are separate concepts. Mobile has an explicit study-language definition containing ID, English name, native name, and transcription language code. Supported study languages remain English, French, German, Portuguese, Spanish, Italian. Release-ready interface languages remain `en`, `es`, `fr`, `de`, `it`, `pt`, `ru`, `pl`, `ar`, `ja`, `ko`, `sr`, `hr`, and `bg`. The native/explanation language catalog is broader than both the study-language and interface-language catalogs. Mobile Settings shows user-friendly language names while storing and sending backend language IDs.

Tutor profiles currently represented by desktop are Lana, Nelli, and David. Tutor choice is product-significant because it affects display name, profile/persona, and preferred voice behavior in lessons.

## Current lesson-start skeleton

The normal Mobile lesson-start flow is `Home -> Choose Topic -> Choose Situation -> Lesson`. The obsolete Choose Level screen, `/choose-level` route, and import were deleted; `ChooseLevelScreen` and `choose_level_screen.dart` no longer exist. When Start lesson is tapped, Home fetches backend `UserSettings.currentLevel` and resolves the matching `LessonOption` through `lessonLevels`; it does not pass the raw setting string into the lesson runtime. Choose Level is no longer reachable from normal Home navigation. The existing downstream display-label chain remains intact through `LessonStartSelection`, the lesson session request, runtime level profiles, and active CMS level profile.

Home is intentionally learner-facing: it shows the app logo/title, short product promise, primary **Start lesson** action, friendly account/access status, and secondary Settings entrypoint. Tutor diagnostics are not shown on Home; selected tutor remains a Settings concern.


## Lesson runtime source of truth

Mobile must not invent a separate lesson runtime. It must follow the existing desktop/CMS/backend lesson flow as a second client while adapting the experience to phone-first UI. Desktop is a reference client for orchestration, not the owner of lesson behavior. CMS/backend published runtime content is the source of truth for tutor instructions, level behavior, prompt templates, scenario rules, wrap-up behavior, feedback guidance, and lesson methodology.

Mobile must not call OpenAI directly, hardcode CMS lesson behavior in Flutter, duplicate a mobile prompt/runtime system, or use `POST /api/me/lesson-sessions/{sessionId}/reply` for real lessons at this stage. The placeholder endpoint is not the real lesson reply path.

The existing desktop/CMS/backend lesson flow for mobile to mirror is:

```http
GET /api/me/lesson-access
GET /api/me/subscription-status
GET /api/me/lesson-content/scenarios/{scenarioKey}
POST /api/me/lesson-sessions
POST /api/lesson-chat/reply
POST /api/lesson-chat/feedback
POST /api/audio/speech
POST /api/audio/transcribe
POST /api/me/lesson-sessions/{sessionId}/messages
```

Current mobile `POST /api/me/lesson-sessions` request shape:

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

Current lesson lifecycle, Translation, learner-message Feedback, and shared Lesson Chat/Conversation mode transcription request construction are complete. Confirmed leave uses the existing backend abandon flow, Back navigation must not silently Finish a lesson, and ordinary leave must not generate a Summary. Do not add temporary mobile-only backend endpoints, new safe/catalog endpoints for convenience, backend changes without an approved final shared lesson-runtime design, realtime, history, or billing as part of lesson maintenance.

Before changing mobile lesson behavior, read the desktop/CMS/backend lesson flow docs and inspect the existing desktop flow. Do not create new backend endpoints just because the mobile client does not yet mirror the existing contract.

## Next implementation priority

The next safe implementation work should continue from the green Settings baseline, Home polish, completed lesson/conversation voice flows, completed Feedback & reports submission, and remaining validation boundaries. Keep slices small and mobile-only unless an API gap is explicitly approved. Recommended small next steps are Settings UX polish and lesson runtime planning by inspecting backend lesson/session APIs before implementation. Billing, automatic tutor playback, broader repeated testing on different physical devices and network conditions, analytics, crash reporting, Google Play Billing, Apple billing, and store release setup remain later phases and should not be started without a separate plan. Missing Lesson Chat avatar assets remain a separate issue.

This priority preserves the product boundary:

- Mobile is another client for the same Language Voice Tutor product.
- Mobile uses the same backend account as desktop.
- Premium entitlement remains backend-owned and backend-verified.
- Mobile does not call OpenAI directly.
- Mobile does not store secrets.
- Mobile does not decide Premium locally.

## In scope for Mobile V1

- Flutter Android-first client path.
- Authentication against the existing backend.
- Session persistence appropriate for mobile.
- Account profile and settings retrieval from backend APIs.
- Subscription and entitlement display based on backend state.
- Lesson access checks based on backend decisions.
- Lesson start, tutor message exchange, lesson history, and progress retrieval/update through backend APIs.
- Completed learner voice upload to backend transcription for speech-to-text.
- Completed manual TTS playback using backend-provided WAV responses; automatic tutor playback remains future work.
- Google Play Billing bridge where the mobile app receives a purchase token and sends it to the backend for verification.

## Out of scope for Mobile V1 foundation

- Implementing billing before backend auth/account/subscription-status integration is confirmed.
- Implementing automatic tutor playback, Conversation mode, analytics, crash reporting, or store release setup before the backend account path is validated.
- Creating a mobile backend.
- Creating a mobile database as the source of truth.
- Client-side OpenAI calls.
- Client-side Premium, subscription, or lesson-access decisions.
- Storing provider secrets or signing secrets in the mobile app.
- Adding Google Play Billing runtime code before the skeleton and API contracts are confirmed.
- Creating Google Play or Apple App Store release metadata.

## Source of truth

The backend is the source of truth for:

- User identity and account state.
- Subscription status and entitlement level.
- Usage limits and remaining quotas.
- Lesson access decisions.
- Lesson history and progress.
- AI tutor orchestration and behavior.
- Billing verification and entitlement updates.

The mobile app may keep short-lived local state for responsiveness, but any authoritative state must be fetched from or reconciled with the backend.

## Current text lesson milestone

The Android-first Flutter client now has a complete, production-verified text lesson loop:

1. Mobile starts an authenticated backend lesson session.
2. Mobile loads the CMS/backend runtime scenario.
3. Mobile renders the learner-facing lesson opening and scenario suggestions.
4. The learner selects a scenario through normal typed input.
5. Text replies use the existing backend lesson-chat route.
6. User and tutor messages are persisted under the backend lesson session.
7. Mobile waits up to 5 seconds for already-started message persistence before Finish.
8. Mobile calls authenticated Finish.
9. Backend generates and persists the learner summary.
10. Mobile reads and displays the authenticated backend-owned summary.

Text lesson foundation is complete. Finish plus backend-owned summary display is complete and production-verified against backend `0.1.35-backend.112` or later. The real mobile Hint flow is complete in functional commit `f9dbc06` (`Add mobile lesson hint flow`), real per-message Translation is complete in functional commit `9d2476b` (`Add mobile message translation`), and real learner-message Feedback is complete in functional commit `f1e8f16` (`Add mobile learner message feedback`), without backend changes or a backend deployment requirement. Mobile still does not call OpenAI directly, does not own tutor behavior, lesson methodology, Hint prompt logic, or summary generation, and never creates a local transcript-derived summary. CMS/backend runtime remains the lesson behavior source of truth; desktop remains a behavior/orchestration reference rather than a separate mobile runtime source.

Mobile Hint uses `POST /api/lesson-chat/hint` after context selection with the existing authenticated bearer-token and refresh-on-401 flow. Before context selection, Hint is local only and asks the learner to choose a visible situation or type a custom one; it does not call the backend or show the CMS example Hint early. Numeric choices resolve against CMS/runtime context variants, context titles resolve case-insensitively, and custom learner-entered situations are supported without inventing a CMS variant ID. The selected context is mutable lesson-screen state reused by both lesson replies and Hint requests.



Mobile Feedback uses `POST /api/lesson-chat/feedback` through the existing authenticated bearer-token and refresh-on-401 flow. It uses the existing full `LessonChatRequest` contract and sends the exact learner text, stable local source message ID, real persisted backend message ID, active lesson session ID, learner-message kind, selected lesson context, transcript, last tutor message, study/native language metadata, CMS/runtime scenario data, lesson goal/type, tutor profile, and active level-profile data. Backend owns Feedback prompts, correction rules, level adaptation, scenario context, provider calls, structured output, usage events, and persistence; Flutter does not call OpenAI directly and does not contain correction methodology or provider prompts. Feedback is learner-message only, user initiated, waits for the selected message's real persistence GUID when needed, and shows a retryable not-ready message instead of inventing IDs when persistence is unavailable.

Feedback renders as an expandable card below the related learner message, not as a transcript message, and never replaces the learner's original text. Results are cached per learner message, can be hidden and reshown without another backend request, keep independent state across messages, prevent duplicate loading requests, and can coexist with Translation. The backend returns `shortText`, `correctedVersion`, `grammarTip`, `vocabularyTip`, `cultureTip`, and `naturalVersion`; `shortText` is required and nonblank, other sections may be empty, and mobile displays only nonblank sections without inventing missing correction content. Feedback remains in the study language, is not automatically translated into the native language, and does not use explanation language as a client-side override. It does not create lesson messages, increment counters, alter Finish/Summary/Hint/Translation/abandonment/progression/entitlement, or appear on Summary.

Mobile Translation uses `POST /api/translate` through the existing authenticated bearer-token and refresh-on-401 flow. Backend owns provider calls, prompts, rate protection, session validation, and translation behavior; Flutter does not call OpenAI or another provider directly. Tutor and learner messages use the same endpoint for the exact visible message text, include the active backend lesson session ID, and do not require persisted lesson-message IDs. Translation targets the learner's backend-saved native language, converted from the saved native-language ID to the backend-compatible English language name, while source-language metadata comes from the selected study language. Inline per-message results are cached, can be hidden and reshown without another backend request, and do not persist lesson messages, increment counters, alter Finish/Summary/Hint/abandonment/progression/entitlement, or appear on Summary.

### Current learner microphone recording and speech-to-text milestone

Learner microphone recording and speech-to-text are complete in functional commit `e2ec9d0cdb88b6eab8b1100d46188963e05f723b` (`Add mobile speech recording and transcription`). Lesson Chat and Conversation mode now use one shared Mobile transcription request builder. Mobile uses authenticated `POST /api/audio/transcribe` as `multipart/form-data`, sends the audio part as `file` with `audio/wav`, and includes study-language ID, English name, native name, transcription language code, lesson phase, bounded transcription context, and the active backend lesson-session ID when available. Speech recognition always uses the selected study language; native language and explanation language do not influence transcription. Backend owns transcription provider selection, model behavior, language processing, usage protection, and session validation; Flutter does not call OpenAI or device-local speech recognition directly. No new backend endpoint or provider integration was added, and no backend deployment is required.

Android capture uses `record` `^7.1.1` to create genuine WAV audio: PCM 16-bit, mono, 16 kHz. Android `RECORD_AUDIO` is required, `permission_handler` `^12.0.3` handles permission and settings recovery, no storage or background-microphone permission was added, and the repository still has no iOS runner. Mobile validates RIFF/WAVE structure, PCM format, mono, 16 kHz, 16-bit data, duration from 500 ms through 30 seconds, nonempty data, and near-silence before upload; invalid or silent audio is rejected locally and temporary WAV files are cleaned after success, failure, cancellation, lifecycle exit, or navigation.

A valid transcript is inserted into the existing editable composer and is never sent automatically. If typed text already exists or changes during transcription, the learner chooses whether to replace it. Recording and transcription do not create lesson messages or change `learnerTurnCount` or `validTurnCount`. Permission denial is retryable, permanent denial offers Android settings recovery and rechecks on return, typed drafts remain preserved, the microphone button changes to Stop during recording, manual Stop starts validation/transcription, recording auto-stops at 30 seconds, tutor TTS stops before recording begins, and recording is cancelled before Leave, Finish, Summary, navigation, disposal, or app backgrounding without automatic resume.

Out of scope remains automatic sending after transcription, continuous listening, realtime or streaming transcription, background recording, waveform visualization, learner recording playback, local device speech recognition, and iOS implementation. The optional Desktop Realtime transcription language issue is outside this Mobile change.

Desktop-parity transcription behavior is current Mobile behavior. During the first unresolved scenario-selection turn, Mobile sends a short transcription context built from the currently visible runtime/CMS context candidates; candidate titles come from current lesson runtime data and are not hardcoded. The context asks for exact transcription in the selected study language without translation or paraphrasing. During active roleplay, the selected lesson context is used as the transcription hint. Conversation mode uses the same study-language definition and available lesson context as Lesson Chat. When runtime context is unavailable, Mobile safely sends an empty or minimal context instead of inventing lesson data.

Semantic scenario resolution remains unchanged: deterministic numeric and exact-title matching still runs locally; unresolved first voice choices still use the existing backend semantic resolver; `published_context`, `free_context`, `clarify`, `unsafe`, and backend failure behavior remain unchanged; the canonical CMS candidate returned by backend is still used; and translation remains a separate explicit `POST /api/translate` action.

Completed verification for this Mobile transcription-parity state: `dart format` completed successfully; `flutter analyze` completed with no issues; `lesson_start_flow_test.dart` passed with 58 tests; `conversation_mode_screen_test.dart` passed with 5 tests; `transcript_script_normalizer_test.dart` passed with 3 tests; transcription-parity focused tests passed with 12 tests; full Flutter suite passed with 197 tests and 0 failures; debug Android APK build succeeded. Owner physical Android verification is complete for the six-language study-language slice: all six study languages can be selected and saved in Settings; lessons launch using the selected study language; speech recognition uses the selected study language; and Conversation mode works using the selected study language. Supported study-language entries are `en` — English — English, `fr` — French — Français, `de` — German — Deutsch, `pt` — Portuguese — Português, `es` — Spanish — Español, and `it` — Italian — Italiano. Implementation commit `f046f82` (`feat: add six-language mobile lesson parity`) delivered this slice. Automated verification for implementation commit `f046f82` had already completed before this documentation update: `flutter analyze` passed with no issues, focused language-parity tests passed with 95 tests, the full Flutter suite passed with 226 tests, implementation was committed and pushed, and no backend or CMS deployment was required. Broader repeated testing on different physical devices and network conditions may still be useful; do not declare voice recognition fully stabilized yet.

The first active roleplay Hint may use the CMS-owned `hintRules.exampleHint`; later Hint requests send the full existing `LessonChatRequest` context, including active session ID, runtime scenario, current context, transcript, last tutor message, level, topic, situation, and language/settings data. Hint is a compact dismissible inline support card, not a chat message, and is not added to the transcript. It blocks duplicate simultaneous requests, is disabled during incompatible operations and after completion, and does not create lesson messages, increment `learnerTurnCount`, change `validTurnCount`, alter the Finish payload, or generate/change the Summary. HTTP 429 means temporary Hint unavailability; authentication, session-ended, network, backend, and malformed-response states remain learner-safe and consistent with the existing lesson flow.

Completed and remaining Mobile V1 or later phases:

- Real per-message Translation. **Complete** in functional commit `9d2476b` (`Add mobile message translation`).
- Real per-message learner Feedback. **Complete** in functional commit `f1e8f16` (`Add mobile learner message feedback`).
- Lesson History data foundation, Home navigation, recent-list UI, and detail UI. **Complete** in `4d531e3`, `2c88944`, and `a200641`.
- Progress. **Pending** a separate backend-owned aggregate endpoint and contract; do not calculate it from the recent History list.
- Tutor TTS playback. **Complete** in functional commit `28356ff` (`Add mobile tutor voice playback`).
- Learner microphone recording and speech-to-text. **Complete** in functional commit `e2ec9d0cdb88b6eab8b1100d46188963e05f723b` (`Add mobile speech recording and transcription`).
- Automatic tutor playback.
- Animated tutor GIF loading and state binding.
- Fullscreen Conversation mode. **Complete** for current Mobile voice flow; further realtime/continuous conversation remains future work.
- Google Play Billing.
- Apple billing.
- Analytics, crash reporting, and store release work.


## Next isolated engineering task

Manual tutor-message TTS playback is complete in functional commit `28356ff` (`Add mobile tutor voice playback`). Learner microphone recording plus speech-to-text is complete in functional commit `e2ec9d0cdb88b6eab8b1100d46188963e05f723b` (`Add mobile speech recording and transcription`). Mobile voice lesson and Conversation mode flows are complete in functional commit `f195dc2` (`feat: add mobile voice lesson and conversation flows`), and Desktop-parity transcription behavior is documented here with no backend deployment requirement; see `docs/MOBILE_VOICE_LESSON_STATE.md` for the broader voice scenario flow and validation record. Lesson History is complete. The next safe product step is to plan a separate backend-owned Progress aggregate endpoint and contract; do not implement local Progress from the recent History list. Mobile billing, analytics, crash reporting, and store release remain future work.
