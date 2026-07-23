# Language Voice Tutor Mobile

## Progress data foundation

Production backend `0.1.35-backend.124` provides authenticated `GET /api/me/progress`. Mobile uses its existing models and authenticated `fetchProgress()` service call; the backend remains the sole source of official totals, windows, streaks, UTC/calendar and completion rules. Mobile never calculates Progress from the recent History list.

Mobile has a dedicated learner-facing Progress screen, opened from **Settings -> Lessons -> Progress**. It displays backend totals, streaks, backend-provided recent activity, last lesson, and optional distributions with loading, empty, sign-in-required, unavailable, and retry states. No chart dependency or client-side official aggregation was added.

## Current mobile navigation and visual system

Mobile now includes a learner-facing Premium screen with backend-confirmed Free, Trial, and Premium status plus non-charging purchase and restore placeholders; Google Play Billing remains a later stage.

Home is a compact, vertically scrollable learner dashboard: current backend-owned streak, existing logo with the three-part Language Voice Tutor wordmark, **Start lesson**, account/plan summary, the final seven backend activity entries, and **Open Settings**. The wordmark uses blue, orange/red, and green vertical gradients; Home action buttons use the blue/white brand gradient. Account and activity surfaces are matte translucent cards over the shared light-blue-to-golden background.

Settings is divided by a three-item bottom navigation bar:

- **Profile**: account/subscription, learner level, language choices, tutor, audio, and Save settings.
- **Lessons**: Lesson history, Progress, and **Rewards**, which opens the complete achievement catalogue.
- **App**: password recovery, Feedback & reports, device-local Practice reminders, and Connection status. Practice reminders default to 09:00 and 20:00 device-local time, remain blocked until Android notification permission is granted after a learner-facing explanation, and can be edited or disabled entirely in Settings.

Settings, Progress, Lesson History, Choose Topic, and Choose Situation use the same light-blue-to-golden background. Cards are softly rounded translucent surfaces; settings fields and expansion panels use rounded filled controls. Backend contracts, entitlement ownership, and lesson behavior remain unchanged.

## Achievements

Home includes a single shared **Achievements** surface with the backend-selected unlocked items, and **View all** opens the complete achievement catalogue. The **Settings -> Lessons -> Rewards** row opens that same catalogue. Achievement artwork is transparent and is shown directly on the shared surface rather than inside an additional per-item card. Unlocked artwork can be opened over the current page, closed by tapping anywhere, and enlarged or moved with the standard two-finger gesture; locked artwork remains subdued and cannot be opened. The complete catalogue uses a two-column layout.

When Home discovers an unlocked achievement that has not yet been presented on the current device for the signed-in user, it opens it automatically once. Multiple new unlocks are shown in sequence; closing one shows the next, while the visible close-all control dismisses the remaining queue. This presentation history is local, user-scoped secure-storage state only and never changes backend achievement eligibility, progress, ordering, or unlock data. Full API and ownership details are in `docs/API_CONTRACTS_ASSUMPTIONS.md`.

## Lesson visual boundary

The blue product typography remains available to Home and Settings. Active lesson screens deliberately use a local neutral typography theme so lesson content, learner feedback, and the completion summary retain their own readable hierarchy. Feedback is rendered as a warm support panel with distinct white sections; the summary uses separate positive, improvement, and phrase panels inspired by the Desktop structure. The Lesson Chat dock keeps its microphone as the larger centered bottom action, with keyboard and Hint controls aligned to the left and right edges. This is presentation-only: lesson runtime, feedback payloads, summary contracts, and backend ownership are unchanged.

The Home weekly-activity bars remain backend-owned visualizations. Tapping a day selects and outlines that bar and displays its backend-provided completed-lesson count; Mobile does not calculate or infer totals locally.

Language Voice Tutor Mobile is the Android-first Flutter client for the existing Language Voice Tutor product. This repository is intentionally separate from the desktop application and backend services so mobile-specific UI, platform integration, release cadence, and store workflows can evolve independently.

## Six-language lesson parity

Mobile lessons now wire the six supported study languages end to end: English, French, German, Portuguese, Spanish, and Italian. Study language is resolved from one centralized definition and remains separate from native/translation language and interface language. Tutor-facing deterministic setup text, scenario choices, known-context openings, and local Hints use the selected study language; lesson requests, transcription, and both Lesson Chat and Conversation mode TTS use the same language metadata. Canonical CMS IDs, canonical English titles, and runtime scenario keys remain unchanged, while backend/CMS continue to own tutor behavior and generated replies. Flutter interface localization has not started and remains a separate phase. No backend deployment was required for this Mobile-only wiring. Owner physical Android verification is complete for the six-language study-language slice: all six study languages can be selected and saved in Settings; lessons launch using the selected study language; speech recognition uses the selected study language; and Conversation mode works using the selected study language. Supported study-language entries are `en` — English — English, `fr` — French — Français, `de` — German — Deutsch, `pt` — Portuguese — Português, `es` — Spanish — Español, and `it` — Italian — Italiano. Implementation commit `f046f82` (`feat: add six-language mobile lesson parity`) delivered this slice. Automated verification for implementation commit `f046f82` had already completed before this documentation update: `flutter analyze` passed with no issues, focused language-parity tests passed with 95 tests, the full Flutter suite passed with 226 tests, implementation was committed and pushed, and no backend or CMS deployment was required.

## Latest completed Mobile resilience and reporting state

Mobile authentication now classifies refresh outcomes as success, invalid session, or temporary failure. Only a proven invalid session clears stored tokens; temporary network, timeout, malformed-response, rate-limit, and backend failures preserve tokens. JSON, binary TTS, multipart transcription, and voice-scenario paths share the same single-flight refresh coordinator, stale 401 responses first retry a newer stored access token, and Splash routes to Login only for a proven invalid session. Access tokens remain 60 minutes, refresh tokens remain 30 days, backend refresh tokens rotate, rotated-token reuse revokes the token family, and no backend deployment was required for this Mobile fix.

Lesson Chat avatar behavior and tutor state synchronization are current in `docs/MOBILE_VOICE_LESSON_STATE.md`: the avatar fills the full 240-pixel header with top-centered cover layout, the washed-out radial glare was removed, controls remain above the avatar, and physical Android validation found tutor state transitions substantially better synchronized while broader repeated testing remains useful.

Settings now includes the authenticated **Feedback & reports** card for suggestions, app problems, and AI response reports. Mobile posts to `POST /api/me/feedback-reports` with category, message, optional reported AI text, `clientPlatform: android`, and `clientVersion: 0.1.0+1`, without sending tokens as data, email, device identifiers, attachments, screenshots, transcripts, or unrelated account data, and without logging report text. Production integration is verified after backend migration `20260717120148_AddUserFeedbackReports`, backend release `0.1.35-backend.117`, and the production ownership correction to `lvt_app`: suggestion, app_issue, and ai_response submissions from a physical Android device produced three verified production records with status `new`. CMS review UI, email workflow, attachments/screenshots, per-message report buttons, automatic moderation/OpenAI forwarding, a Mobile database, localization, billing, analytics, crash reporting, Progress, signing, Play Console, and store release remain separate work.

## Lesson History

Mobile Lesson History is complete: backend-owned models and authenticated services landed in `4d531e3`, the original Home entry and recent list in `2c88944`, and Lesson details in `a200641`. It uses the same authenticated backend account and official History as Desktop and Website through `GET /api/me/lesson-history` and `GET /api/me/lesson-history/{sessionId}`; it does not read Desktop-local JSON, call `/api/dev`, keep a separate official local copy, or make ownership/Premium decisions. The current navigation entry is **Settings -> Lessons -> Lesson history**. Cards open on-demand details with overview, non-empty summary sections, ordered learner/tutor transcript, and connected feedback. Internal IDs, cost, raw timestamps, confidence/audio metadata, and backend codes remain hidden.

The backend list contains up to 50 recent sessions, preserves backend ordering, and is not complete all-time History. Mobile must not calculate official totals, streaks, or Progress from it. Progress now uses the separate backend-owned aggregate endpoint documented above. Canonical implementation, UI-state, scope, and verification details live in `docs/MOBILE_V1_SCOPE.md` and `docs/TESTING_CHECKLIST.md`; only an optional physical-device visual-spacing review remains for History.

## Current repository state

This repository contains the Android-first Flutter mobile client under `app/`. The current verified mobile baseline includes authenticated account/settings slices, backend health and subscription display foundations, tutor options loading for Settings, Settings parity work, Home learner-facing polish, and the phone-first lesson-start flow. Mobile Settings reads and saves backend-owned settings through `/api/me/settings`, including `currentLevel` and `selectedTutorId`; account-level learner level changes are made in **Settings -> Learning**. Home shows the user-provided Language Voice Tutor logo next to an accessible branded title, a learner-friendly account and plan card, and **Start lesson** as the primary lesson action. Start lesson loads `UserSettings.currentLevel`, resolves it through the centralized `lessonLevels` mapping, and navigates through **Choose Topic -> Choose Situation -> Lesson**. The normal flow no longer opens Choose Level. Topic cards use soft product colors, and situation cards follow the selected topic color family. The mobile logo source is `app/assets/brand/source/lvt-logo-source.png`; the Flutter app uses `app/assets/brand/lvt-logo.png`, the in-app loading screen shows only the centered logo, and Android launcher icons are resized assets derived from the same provided source logo. Billing, analytics, crash reporting, secrets, database migrations, store release setup, and backend runtime code remain intentionally out of scope; current lesson, voice, and Conversation mode state is summarized below and detailed in `docs/MOBILE_VOICE_LESSON_STATE.md`.


## Current verified mobile baseline

The current verified mobile baseline includes the production-verified Android text lesson loop, completed mobile Hint and lesson-abandon flows, real per-message Translation from functional commit `9d2476b` (`Add mobile message translation`), real learner-message Feedback from functional commit `f1e8f16` (`Add mobile learner message feedback`), manual tutor-message TTS playback from functional commit `28356ff` (`Add mobile tutor voice playback`), completed learner microphone recording and speech-to-text from functional commit `e2ec9d0cdb88b6eab8b1100d46188963e05f723b` (`Add mobile speech recording and transcription`), completed mobile voice lesson and Conversation mode flows from functional commit `f195dc2` (`feat: add mobile voice lesson and conversation flows`), and the settings language persistence fix from `340c950` (`Fix mobile settings language persistence`). The baseline was verified from `app/` with:

```bash
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
```

Expected current results for the completed saved-level lesson-start cleanup are: `dart format --set-exit-if-changed lib test` passed with 72 files checked; `flutter analyze` completed with no issues; focused Home/start-flow tests passed with 70 tests; the full Flutter suite passed with 208 tests; stale-reference searches found no `ChooseLevelScreen`, `choose_level_screen.dart`, or `/choose-level`; protected runtime files had no diff; and CMS runtime parsing, lesson limits, lesson timing, voice request behavior, transcription behavior, semantic resolution, and summary contracts were not changed. The owner physically verified this learner-level/start-flow slice on an Android phone: Choose Level no longer appears, learner level is available in Settings -> Learning, changing and saving the level works, Start lesson opens Choose Topic directly, the lesson starts with the saved level, speech recognition works, Lesson Chat works, Conversation mode works, backend-owned lesson completion and summary generation work, and the summary displays successfully. Broader physical-device repetition for voice flows and release-readiness work remain separate; voice recognition should not yet be declared fully stabilized. Settings/password recovery remains part of this verified baseline.

Settings has Profile, Lessons, and App navigation areas, with **Save settings** visible in Profile. **Learning** reads and saves the backend-owned account `CurrentLevel`; supported account-level values are `A1`, `A2`, `B1`, and `B2`. The dropdown reuses the centralized Mobile `lessonLevels` labels and mapping, `canonicalLessonLevel()` normalizes backend values, and `lessonLevelFor()` resolves the matching `LessonOption`. Home **Start lesson** loads that backend setting, resolves the matching `LessonOption`, and opens **Choose Topic** directly. The final normal lesson-start flow is **Home -> Choose Topic -> Choose Situation -> Lesson**. The obsolete Choose Level screen, `/choose-level` route, and import were deleted; `ChooseLevelScreen` and `choose_level_screen.dart` no longer exist. Settings also reads and saves `selectedTutorId`; tutor voice remains separate. CMS-published level profiles remain the source of language complexity, correction and hint behavior, answer length, and lesson/final-turn timing. No backend deployment was required for this Mobile navigation cleanup because backend release `0.1.35-backend.116` already provided the required `CurrentLevel` settings contract. No backend, Desktop, CMS, website, billing, voice-provider, transcription-provider, semantic resolver, TTS, or database migration changes were made.


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

Text lesson foundation, Finish plus backend summary, the real mobile Hint flow, confirmed mobile lesson abandonment, real per-message Translation, real learner-message Feedback, manual tutor-message TTS playback, learner microphone recording plus speech-to-text, automatic tutor playback controls, and the separate Conversation mode screen are complete as documented in `docs/MOBILE_VOICE_LESSON_STATE.md`. Pending mobile scope still includes the separate backend-owned Progress contract, billing, analytics/crash reporting, store release work, broader repeated testing on different physical devices and network conditions, and the separate missing Lesson Chat avatar assets issue if still unresolved. No backend deployment is required for the completed Mobile transcription-parity documentation state.


## Current mobile manual tutor-message TTS milestone

Manual tutor-message TTS playback is complete as a second-client integration with the existing product runtime. Mobile uses authenticated `POST /api/audio/speech` with the existing bearer-token and refresh-on-401 flow. Backend returns raw WAV bytes with `audio/wav`; owns the speech provider, model, voice processing, WAV generation, rate protection, usage enforcement, and session validation; and remains the source of truth. Flutter never calls OpenAI or another speech provider directly and contains no provider credentials.

Manual tutor playback sends the exact visible tutor message text, `purpose: lesson_chat_tts`, `speechVoice` and `speechSpeed` from backend user settings, study-language ID/English/native/code metadata, and the active backend lesson session ID. It does not send tutor profile, persisted tutor-message ID, message kind, provider model, provider instructions, or requested output format. Mobile uses a separate binary response path so existing JSON API methods remain unchanged; successful WAV data stays as bytes rather than UTF-8 text, while empty audio and unsupported content types are rejected safely.

Playback uses `just_audio`; the pubspec constraint remains `^0.9.42`, and the verified resolved version is `0.9.46`. Playback is wrapped behind a focused service/adapter so tests do not require the platform plugin, and only one `AudioPlayer` is active for the lesson screen. Play voice is available only for tutor messages, including opening and older tutor messages; learner messages, Translation text, and Feedback sections do not receive TTS controls. First playback downloads WAV bytes and caches a temporary WAV file for the current lesson screen; replay uses that cached file without another backend request. Tapping the same playing message stops it, starting another tutor message stops the previous playback, and duplicate generation requests for the same loading message are prevented.

Loading is shown only for the selected tutor message, and the control changes to Stop while playback is active. Playback errors are learner-safe and retryable. `LessonTutorStatus.speaking` is driven by actual audio playback; no GIF asset switching was added. The temporary audio cache is scoped to the active lesson screen, temporary WAV files are cleaned during screen/session cleanup, and playback stops before confirmed abandonment, Finish, Summary navigation, screen disposal, and app backgrounding. Playback does not automatically resume. Choosing Stay in the leave confirmation does not abandon the lesson. No persistent audio cache, background playback, media notifications, pause/resume controls, streaming endpoint usage, automatic playback, microphone recording, speech-to-text, Conversation mode, or GIF avatar integration was added.

TTS does not create or persist lesson messages, require tutor-message persistence, increment `learnerTurnCount` or `validTurnCount`, change Hint, Translation, Feedback, abandonment semantics, Finish payload, Summary, lesson progression, or make Premium decisions locally. It remains available while the transcript is visible and is not added to the Summary screen. Authentication failures use the existing authentication-required flow, terminal-session responses use existing session-ended handling, HTTP 429 is temporary voice unavailability, and invalid request, provider, timeout, service, network, empty-audio, and unsupported-content failures are learner-safe and retryable without exposing raw response bodies, provider details, tokens, URLs, or stack traces.

## Current learner microphone recording and speech-to-text milestone

Learner microphone recording and speech-to-text are complete as an Android-first second-client integration with the existing product runtime. Lesson Chat and Conversation mode now use one shared Mobile transcription request builder. Mobile uses authenticated `POST /api/audio/transcribe` with the existing bearer-token and refresh-on-401 flow and existing multipart contract. The request is `multipart/form-data`; the audio part is named `file`; and mobile sends the WAV as `audio/wav` with study-language ID, English language name, native language name, transcription language code, lesson phase, bounded transcription context, and the active backend lesson-session ID when available. Mobile now has an explicit study-language definition containing ID, English name, native name, and transcription language code. Supported study languages remain English, French, German, Portuguese, Spanish, Italian. Speech recognition always uses the selected study language; native language and explanation language do not influence transcription. For an English lesson, confirmed values are `targetLanguageId=en`, `targetLanguageName=English`, `targetLanguageNativeName=English`, and `targetLanguageCode=en`. Backend owns the transcription provider, model, language processing, usage protection, and session validation. Flutter does not call OpenAI or device-local speech recognition directly, no new backend endpoint was added, and no new provider integration was added.

Mobile uses `record` `^7.1.1` for genuine WAV capture: PCM 16-bit, mono, 16 kHz. Android requires `RECORD_AUDIO`; `permission_handler` `^12.0.3` handles permission status and Android settings recovery. No storage or background-microphone permission was added, and this repository still has no iOS runner.

Recordings must be at least 500 ms and at most 30 seconds. Mobile validates RIFF/WAVE structure, PCM format, mono, 16 kHz, 16-bit data, duration, nonempty data, and near-silence before upload. Invalid or silent audio is rejected locally and is never sent to the backend. Temporary WAV files are deleted after success, failure, cancellation, lifecycle exit, or navigation.

A valid transcript is inserted into the existing composer, remains editable, and never sends automatically; only the existing Send button creates the learner turn. If typed text already exists or changes during transcription, the learner chooses whether to replace it. Recording and transcription do not create lesson messages or change `learnerTurnCount` or `validTurnCount`. Normal permission denial returns the microphone to a retryable state; later taps perform a new permission check; permanent denial shows an explicit Open Android settings action; permission is rechecked after returning from settings; and typed drafts remain preserved without requiring a lesson restart.

The microphone button changes to Stop during recording. Manual Stop immediately starts validation and transcription, and recording stops automatically at 30 seconds. Tutor TTS stops before recording begins. Recording is cancelled and cleaned up before Leave, Finish, Summary, navigation, disposal, or app backgrounding, and it does not automatically resume. Authentication, session-ended, invalid recording, rate limit, service unavailable, timeout, network failure, and malformed response remain distinct internal result categories; learner-facing errors are short and safe; network failures are retryable; and raw provider responses, tokens, audio contents, and technical exceptions are not shown. Automatic sending, continuous listening, realtime or streaming transcription, background recording, waveform visualization, learner recording playback, local device speech recognition, and iOS implementation remain out of scope. The optional Desktop Realtime transcription language issue is outside this Mobile change.

Desktop-parity transcription behavior is current Mobile behavior. During the first unresolved scenario-selection turn, Mobile sends a short transcription context built from currently visible runtime/CMS context candidates; candidate titles come from current lesson runtime data and are not hardcoded. That context asks for exact transcription in the selected study language without translation or paraphrasing. During active roleplay, the selected lesson context is used as the transcription hint. Conversation mode uses the same study-language definition and available lesson context as Lesson Chat. When runtime context is unavailable, Mobile safely sends an empty or minimal context instead of inventing lesson data.

Semantic scenario resolution remains unchanged. Deterministic numeric and exact-title matching still runs locally; unresolved first voice choices still use the existing backend semantic resolver. Existing `published_context`, `free_context`, `clarify`, `unsafe`, and backend failure behavior remains unchanged, and the canonical CMS candidate returned by the backend is still used. Translation remains a separate explicit `POST /api/translate` action.

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

Mobile now intentionally diverges from the old desktop step ordering for account-level selection: learner level changes live only in **Settings -> Learning** for the normal user flow, while lesson start proceeds directly to topic and situation selection. Settings parity should gradually cover profile/learning goal, study language, native language, interface/explanation language, tutor avatar, tutor voice, account/subscription, audio, and progress while keeping account/subscription/progress backend-owned.

## Product direction

The mobile app will connect to the existing production backend at:

```text
https://api.languagevoicetutor.com
```

The mobile client must use the same backend account, subscription and entitlement state, usage limits, lesson history, progress records, and AI tutor behavior as the Windows desktop app. The mobile repository remains a separate client repository; it is not the desktop/backend repository and must not duplicate backend-owned product logic.

## Current Mobile planning boundary

Account deletion is completed by the shared backend/Admin workflow. Mobile submission remains a support request, not immediate local deletion. After backend anonymization, new login and refresh fail; an already-issued access token may remain usable only until normal expiry, after which Mobile must clear the invalid session when refresh proves invalid. This is accepted current behavior and no Mobile code change is requested.

The approved next implementation order is: (1) align documentation; (2) implement local Android practice reminders; (3) add complete learner-facing Premium UI and purchase entry points; (4) implement the Google Play Billing bridge with backend verification and restore/reconciliation; and (5) localize the complete static Mobile interface. Notifications V1 is local-only, with product-settings reminders enabled by default at 09:00 and 20:00 in the device local timezone; both times are editable and all reminders can be disabled. It uses neither Firebase nor backend/push state. Android notification permission is still required, must be requested only after the learner sees product value, and denial must not cause a prompt on every launch. Device-local schedules must retain their local-time semantics across timezone changes and be restored after reboot where Android requires it; cross-device lesson completion cannot always suppress a local reminder.

Premium UI and Google Play Billing are separate stages. Premium remains backend-owned and backend-verified: a local button, purchase callback, or unverified Play result never unlocks Premium. Billing is complete only after purchase-token submission, backend verification, entitlement refresh, restore/reconciliation, and subscription lifecycle handling. Paddle remains unchanged for website/desktop, while shared backend entitlement makes valid provider purchases visible to other clients.

The approved interface languages are `en` English, `es` Spanish, `fr` French, `de` German, `it` Italian, `pt` Portuguese, `ru` Russian, `pl` Polish, `ar` Arabic, `ja` Japanese, `ko` Korean, `sr` Serbian, `hr` Croatian, and `bg` Bulgarian. This 14-language interface list is separate from the six study languages. On first use, interface and explanation/translation language initialize from the device language, normalizing supported regional variants such as `en-US`, `pt-BR`, and `sr-Latn-RS` to their base language; unsupported device languages fall back to English. Saved backend-owned language settings take precedence after explicit save. Localization covers static interface, validation, notification, Premium, and billing text only; it never translates AI replies, learner messages, backend-generated content, CMS identifiers, canonical scenario keys, internal IDs, or backend data. Arabic requires later right-to-left verification. ARB and `flutter_localizations` remain future implementation work, deliberately scheduled after the new reminder, Premium, and billing surfaces are present.

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

Follow the approved sequence: documentation alignment; local Android practice reminders; complete learner-facing Premium UI and purchase entry points; Google Play Billing with backend verification and restore/reconciliation; then one complete 14-language static-interface localization pass. Do not combine those implementation stages. Account, entitlement, access decisions, lesson runtime, transcription, TTS, and AI behavior remain backend-owned.

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

Level is now explicitly part of **Settings -> Learning** for the normal Mobile user flow. To match the accepted saved-level flow, **Start lesson** loads the saved backend `UserSettings.currentLevel` and proceeds directly to Choose Topic, then Choose Situation, then Lesson.

Tutor options are loaded from `GET /api/tutor-options`. The current settings API supports `selectedTutorId`, so selected tutor persistence is backend-owned through `/api/me/settings` instead of being faked with local-only persistence. Tutor voice remains separate from selected tutor.

Out of scope for this PR: backend changes, database migrations, Conversation mode, automatic tutor playback, billing, Google Play Billing, Apple billing, Paddle runtime, history/progress, analytics, crash reporting, and store release setup.

Verification commands from `app/`:

```bash
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
```
