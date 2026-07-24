# Android-First Plan

## Approach

## Stage 1 interface localization checkpoint

The Android-first client now has a Flutter `gen-l10n`/ARB localization foundation for `en`, `ru`, `es`, `fr`, and `de`, with 277 matching messages in each catalog. `explanationLanguage` alone controls the Flutter interface locale; `studyLanguage` continues to control lesson/tutor/speech-recognition behavior and `nativeLanguage` continues to control requested lesson/dialogue translation. Unsupported interface values display English without replacing the saved backend value. Successful Settings saves apply the confirmed interface language immediately, while failed saves preserve the previous locale.

Localized scope currently includes Splash/authentication, Home, Settings and its three navigation sections, account/deletion/feedback/reminder/connection controls, fixed level display, and topic/situation selection with localized headings, helper text, validation, semantics, and tooltips. Premium, Progress, Lesson History details, remaining Achievement catalogue text, Lesson Chat, Conversation mode, and other static strings remain later Stage 1 work.

Lesson-selection display localization is isolated from the backend contract. Navigation uses stable topic IDs, unknown catalog IDs fall back to canonical text, and `LessonStartSelection` reconstructs canonical data from the authoritative catalog using stable IDs. Session payloads and runtime scenario keys remain identical across the five interface locales; `scenarioKey` remains `lessonContentId`, including Free Conversation. The accepted flow remains **Home -> Choose Topic -> Choose Situation -> Lesson**, with level selection only in **Settings -> Learning**.

## Progress data foundation

The Android-first client consumes backend `0.1.35-backend.124` Progress V1 through authenticated `GET /api/me/progress`. It does not calculate Progress from History; backend UTC and completion rules remain authoritative.

The Android client now exposes a Home Progress entry and scrollable learner-facing Progress screen using the existing theme and no chart package. Backend daily activity is rendered as accessible compact day cells; official calculations remain backend-owned. Broader visual polish is separate work.

The mobile app will be built with Flutter using an Android-first delivery path. Android is the first target for implementation, QA, billing integration, and release preparation. iOS should remain a future-compatible consideration, but iOS project files should not be created during the docs-only foundation phase.

## Study-language parity status

The lesson flow carries English, French, German, Portuguese, Spanish, and Italian through deterministic tutor setup text, canonical scenario selection, known-context openings, local Hints, backend lesson requests, transcription, and Lesson Chat/Conversation TTS. One Mobile study-language definition supplies the exact ID, English name, native name, BCP-47/transcription code, tutor instruction name, and language-lock name. Native/translation and interface languages stay separate. CMS canonical IDs and English semantic metadata are preserved, and CMS/backend still own tutor methodology and generated replies. The five-locale interface foundation described above does not change this six-language study-language behavior. This Mobile-only work required no backend deployment.

## Why Android first

- Google Play Billing is the first mobile billing bridge to plan.
- Android device audio capture and playback behavior should be validated early.
- Android release, signing, permissions, and QA can be stabilized before expanding to iOS.

## Verified Android skeleton baseline

The repository has moved beyond the original docs-only foundation and now contains a minimal Flutter Android skeleton under `app/`. This skeleton has been verified locally on Android Emulator: it builds, installs, and runs with package/application id `com.languagevoicetutor.mobile`.

Current verified Android build stack:

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

The current green baseline includes completed backend-owned Lesson History (data foundation, Home entry, recent list, and detail flow), the production-verified Android text lesson loop, completed Hint and lesson abandonment, Translation, learner Feedback, tutor-message TTS, learner speech-to-text, Mobile voice/Conversation mode flows, authentication/session resilience, Lesson Chat avatar synchronization, and authenticated Feedback & reports submission. Settings has stable **Account**, **Learning**, and **Audio** areas. **Settings -> Learning** reads and saves backend-owned account `CurrentLevel` through `/api/me/settings`, using `lessonLevels` for Mobile labels and mapping. Home **Start lesson** loads that setting and opens Choose Topic directly, followed by Choose Situation and Lesson; Choose Level is removed from the normal flow. CMS-published level profiles remain authoritative for lesson behavior and timing. No backend deployment was required for this Mobile navigation cleanup because backend release `0.1.35-backend.116` already provided the required `CurrentLevel` settings contract. The owner physically verified the saved-level lesson-start flow on an Android phone. History is complete. Progress remains separate and requires a backend-owned aggregate contract; the recent list of up to 50 sessions must not be used for official totals or streaks. Mobile billing, analytics, crash reporting, and store release remain future work.

## Planned phases

### Phase 0: Docs-only foundation — complete

- Define scope and out-of-scope items.
- Record backend API assumptions.
- Record billing verification model.
- Record testing expectations.

### Phase 1: Flutter Android skeleton — complete

- Flutter project structure exists under `app/`.
- Android target is present and verified on emulator.
- Linting, tests, and placeholder navigation are present.
- Backend base URL exists only as non-secret configuration placeholder.

### Phase 2: Auth, account, subscription-status, and settings baseline — in progress

- Complete: login/session flow against the existing backend account system.
- Complete: secure token/session storage with resilient refresh handling that preserves tokens on temporary failures and clears them only for proven invalid sessions.
- Fetch `/api/me`, account settings, and backend-owned subscription/entitlement status.
- Complete: logout and invalid-session handling; temporary Splash session-check failures remain retryable rather than automatically routing to Login.
- Display Premium/subscription status only from backend responses; do not compute entitlement locally.
- Continue from the green Settings baseline with small, mobile-only changes unless an API gap is explicitly approved.
- Completed within this phase: Settings selected tutor persistence, product-friendly catalog labels, friendly language labels, Home title/logo polish, soft colored lesson-selection cards, and the Settings **Feedback & reports** card using `POST /api/me/feedback-reports`.

### Desktop parity guidance

The reviewed Windows desktop client walkthrough presentation remains a product source model, while Mobile uses phone-first layouts and backend account settings. Mobile learner level is changed in **Settings -> Learning**. Normal lesson start loads backend `UserSettings.currentLevel`, resolves it through `lessonLevels`, and follows `Home -> Choose Topic -> Choose Situation -> Lesson`; Choose Level is no longer a normal-flow step.

### Phase 3: Lessons and progress

- Complete and physically verified on Android phone: Home Start lesson loads backend `UserSettings.currentLevel`, resolves it through the centralized `lessonLevels` collection, and follows **Home -> Choose Topic -> Choose Situation -> Lesson**. The obsolete Choose Level screen, `/choose-level` route, and import were deleted; `ChooseLevelScreen` and `choose_level_screen.dart` no longer exist.
- Complete and production-verified: Android text lesson foundation, including authenticated session start, CMS/backend runtime opening, scenario selection, text conversation, message persistence, Finish, and backend-owned summary display.
- Complete and production-verified: Finish plus backend summary flow against production backend `0.1.35-backend.112` or later.
- Backend `.112` is the verified dependency because it supports nested Responses API output extraction for persisted learner summaries; `.111` is the previous rollback backend.
- Complete: real mobile Hint flow through `POST /api/lesson-chat/hint`, with backend-owned Hint behavior, local pre-context guidance, CMS-owned first roleplay example Hint support, inline non-transcript UI, existing auth refresh behavior, and no changes to lesson counters, Finish payload, or Summary.
- Complete in functional commit `1a392dc`: confirmed mobile lesson abandonment through `POST /api/lesson-sessions/{sessionId}/abandon` with no request body, shared visible Back/Android system Back leave confirmation, no silent Finish, no Summary generation, duplicate-abandon prevention, retryable network/backend failure behavior, and existing auth refresh behavior.
- Complete: real per-message learner Feedback through `POST /api/lesson-chat/feedback`, with the existing full LessonChatRequest contract, backend-owned correction behavior, persisted learner-message GUID requirement, expandable non-transcript per-message UI, per-message caching, study-language output, and no changes to counters, Finish, Summary, Hint, Translation, abandonment, progression, or entitlement.
- Complete: manual tutor-message TTS playback through `POST /api/audio/speech`, raw WAV binary handling, temporary per-screen caching, one active lesson `AudioPlayer`, learner-safe retryable errors, and no changes to counters, Finish, Summary, Hint, Translation, Feedback, abandonment, progression, or entitlement.
- Complete: learner microphone recording and speech-to-text through `POST /api/audio/transcribe`, authenticated multipart WAV upload, Android `RECORD_AUDIO` permission, local WAV/duration/silence validation, editable transcript insertion, no automatic send, and no changes to lesson counters or message creation. Lesson Chat and Conversation mode share the same Mobile transcription request builder; transcription always uses the selected study language definition (ID, English name, native name, transcription language code), not native or explanation language.
- Complete: Lesson Chat avatar header fills the full 240-pixel header, uses top-centered cover layout, removes the washed-out radial overlay, and keeps Back, Finish, level/topic, tutor status, and Conversation mode controls above the avatar. Tutor playback state synchronization is substantially better on a physical Android device; broader repeated testing remains useful and all timing edge cases should not be declared fully stabilized.
- Complete: Lesson History models and authenticated service (`4d531e3`), Home entry and backend-ordered recent list (`2c88944`), and on-demand Lesson details (`a200641`), including focused and full automated verification.
- Keep pending: realtime/continuous voice conversation, broader repeated testing on different physical devices and network conditions, mobile billing, analytics, crash reporting, and store release work. Progress now uses the separate backend-owned aggregate endpoint; never derive official all-time totals or streaks from the History endpoint, which currently returns up to 50 recent sessions. No backend, Desktop, CMS, website, billing, voice-provider, transcription-provider, semantic resolver, TTS, or database migration changes were made for the saved-level Mobile cleanup.
- Lesson runtime foundation must not add OpenAI calls from mobile and must not include client-owned tutor methodology or local summary generation.


### Current lesson-runtime boundary

Mobile now completes the Android text lesson loop through backend-owned summary display. The current lesson implementation mirrors the existing desktop/CMS/backend runtime instead of creating a separate mobile runtime. Mobile starts authenticated backend lesson sessions, loads CMS/backend scenario content, renders the lesson opening and suggestions, sends text practice replies through the existing lesson-chat route, persists messages under the backend session, waits for in-flight persistence before Finish, calls authenticated Finish, and reads the backend-owned learner summary.

Use this flow for mobile alignment:

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
PUT /api/me/lesson-sessions/{sessionId}/finish
GET /api/me/lesson-sessions/{sessionId}/summary
POST /api/lesson-sessions/{sessionId}/abandon
```

Current mobile session-start request shape:

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

Do not use `POST /api/me/lesson-sessions/{sessionId}/reply` for real lessons at this stage; it is a premature placeholder, not the real desktop lesson reply path. Do not call OpenAI directly from mobile and do not hardcode CMS lesson behavior in Flutter. CMS/backend published runtime content is the source of truth for tutor instructions, level behavior, prompt templates, scenario rules, wrap-up behavior, feedback guidance, and lesson methodology. Desktop is the reference client for orchestration, not the owner of lesson behavior.

Confirmed mobile lesson abandonment is complete. The backend stale active-session interval remains two minutes, no backend timeout change was made, and no mobile heartbeat was added. Normal confirmed Back navigation releases the session immediately; if the app is force-closed or terminated without confirmed leave, the existing backend timeout remains the fallback. Heartbeat or timeout reduction is optional future reliability work only if real user feedback requires it.

Explicit no-go items for future lesson work: no temporary mobile-only backend endpoints, no new safe/catalog endpoints for intermediate convenience, no duplicate mobile prompt/runtime system, no backend changes unless a real final shared lesson-runtime design is approved, no silent Finish from Back navigation, no Summary generation from ordinary leave, and no realtime/history/billing.

Before changing mobile lesson behavior, read the desktop/CMS/backend lesson flow docs and inspect the existing desktop flow. Do not create new backend endpoints just because the mobile client does not yet mirror the existing contract.


### Phase 4: Voice and conversation — partially complete

- Complete: Android recording permission handling for learner microphone transcription.
- Complete: backend voice upload to `POST /api/audio/transcribe` using authenticated multipart WAV and the existing multipart contract; no new backend endpoint, provider integration, or deployment requirement was added.
- Complete: shared Lesson Chat and Conversation mode transcription request building. During the first unresolved scenario-selection voice turn, Mobile sends a short exact-transcription context from visible runtime/CMS candidates; candidate titles come from current lesson runtime data, not hardcoded lists. During active roleplay, the selected lesson context is used as the transcription hint. If runtime context is unavailable, Mobile sends empty or minimal context rather than inventing lesson data.
- Complete: semantic scenario resolution remains unchanged. Numeric and exact-title matching still runs locally, unresolved first voice choices still use the existing backend semantic resolver, existing `published_context`, `free_context`, `clarify`, `unsafe`, and backend failure behavior remains unchanged, and translation remains a separate explicit `POST /api/translate` action.
- Complete: Conversation mode uses the same study-language definition and available lesson context as Lesson Chat.
- Complete: manual tutor-message TTS playback.
- Keep automatic tutor playback, GIF avatar state integration, broader repeated testing on different physical devices and network conditions, and realtime/continuous voice conversation as future isolated work.

### Phase 5: Approved next implementation sequence

1. Update and align documentation.
2. Implement local Android practice reminders.
3. Add complete learner-facing Premium UI and purchase entry points.
4. Implement the Google Play Billing bridge with backend verification and restore/reconciliation.
5. Continue the Stage 1 interface work from its verified five-locale foundation to the remaining screens and approved languages.

Notifications V1 is local-only: no Firebase, remote/server push, backend endpoint, push-token registration, remote provider, backend notification state, or background microphone behavior. Product settings enable reminders by default at device-local 09:00 and 20:00; learners can edit both times or disable all reminders. Android notification permission is still required. Explain the benefit and ask only after the learner sees the product experience, do not reprompt on every launch after denial, and offer Android settings recovery where practical. Do not request exact-alarm permission unless later investigation proves it necessary. Preserve device-local schedule semantics across timezone changes and restore reminders after reboot when Android requires it; local reminders are not synchronized backend account state and cannot always be suppressed after a lesson on another device.

Premium UI precedes Google Play Billing. A local button, purchase callback, or Play Store result never grants Premium. Billing is complete only after purchase-token submission, backend verification, entitlement refresh, restore/reconciliation, and relevant subscription lifecycle states. Paddle remains unchanged for website/desktop; purchases map through the shared provider-neutral backend entitlement model.

Interface localization remains separate from the six study languages. The long-term approved interface languages are `en`, `es`, `fr`, `de`, `it`, `pt`, `ru`, `pl`, `ar`, `ja`, `ko`, `sr`, `hr`, and `bg`; the current Stage 1 implementation covers `en`, `ru`, `es`, `fr`, and `de`. Localization applies only to interface presentation and never to AI replies, learner messages, backend-generated content, CMS identifiers, canonical scenario keys, internal IDs, or backend data. Remaining languages, remaining screens, and Arabic right-to-left verification are later work.

## Android implementation considerations

- Confirm minimum SDK and target SDK before creating project files.
- Keep backend base URL configurable by build flavor or environment file without secrets.
- Use Android secure storage for session material.
- Request microphone permission only for learner-initiated recording; no background microphone permission is used.
- Ensure network security permits HTTPS to production backend.
- Avoid storing sensitive provider or backend secrets in the app bundle.

## iOS posture

The repository should avoid Android-only architectural decisions where reasonable, but iOS should not drive V1 implementation. Do not create iOS project files until the team explicitly approves an iOS phase.
