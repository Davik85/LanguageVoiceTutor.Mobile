# Android-First Plan

## Approach

The mobile app will be built with Flutter using an Android-first delivery path. Android is the first target for implementation, QA, billing integration, and release preparation. iOS should remain a future-compatible consideration, but iOS project files should not be created during the docs-only foundation phase.

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

The current green baseline includes the production-verified Android text lesson loop, completed Hint and lesson abandonment, real Translation, real learner-message Feedback, manual tutor-message TTS playback, and learner microphone recording plus speech-to-text from functional commit `e2ec9d0cdb88b6eab8b1100d46188963e05f723b` (`Add mobile speech recording and transcription`). `flutter pub get` passed, Dart formatting passed, `flutter analyze` passed with zero issues, focused learner recording service tests passed with 3 tests, focused lesson-flow tests passed with 41 tests, the complete Flutter suite passed with 136 tests, the Android debug APK build passed, and physical Android-device verification confirmed repeated correct speech recognition while existing Summary, Feedback, Translation, Hint, TTS, abandonment, and Finish behavior remained operational. Settings/password recovery remains part of this verified baseline. Settings has stable **Account**, **Learning**, **Audio**, and **Connection status** advanced area, **Save settings** is visible and tested, and user level is not in Settings. Settings selected tutor persistence is complete through `/api/me/settings`: mobile reads and sends `selectedTutorId`, selection survives app/emulator restart, and tutor voice remains a separate setting. Tutor selection belongs in Settings, and Home no longer shows tutor diagnostics or an **Available tutors** card. Home now shows the provided Language Voice Tutor logo next to a more branded, accessible title, preloads the logo during startup before Home is displayed, shows learner-friendly signed-in, account, and plan status while keeping account/access decisions backend-owned, and uses **Start lesson** to open the lesson-start navigation flow. Choose Level uses soft level-specific cards, Choose Topic uses soft topic-specific cards, and Choose Situation uses the selected topic color family. The mobile logo source is `app/assets/brand/source/lvt-logo-source.png`; the app logo is `app/assets/brand/lvt-logo.png`; the loading screen shows only the centered logo; and Android launcher icons under `app/android/app/src/main/res/mipmap-*` are derived from the same provided source logo. Product-friendly situation labels are in place for all six topics, Travel includes Airport check-in, Hotel check-in, Asking for directions, Ordering transport, and Lost luggage, and situation labels no longer show `Placeholder:`. Real per-message Translation is complete in functional commit `9d2476b` (`Add mobile message translation`), real learner-message Feedback is complete in functional commit `f1e8f16` (`Add mobile learner message feedback`), and settings language persistence is fixed in `340c950` (`Fix mobile settings language persistence`). Manual tutor-message TTS playback is complete in functional commit `28356ff` (`Add mobile tutor voice playback`). Learner microphone recording plus speech-to-text is complete in functional commit `e2ec9d0cdb88b6eab8b1100d46188963e05f723b` (`Add mobile speech recording and transcription`). Conversation mode planning is the next isolated functional area. Automatic tutor playback, GIF avatar state integration, fullscreen Conversation mode, history/progress screen, mobile billing, analytics, crash reporting, and store release remain future work.

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

- Implement login/session flow against the existing backend account system.
- Implement secure token/session storage.
- Fetch `/api/me`, account settings, and backend-owned subscription/entitlement status.
- Add logout and expired-session handling.
- Display Premium/subscription status only from backend responses; do not compute entitlement locally.
- Continue from the green Settings baseline with small, mobile-only changes unless an API gap is explicitly approved.
- Completed within this phase: Settings selected tutor persistence, product-friendly catalog labels, friendly language labels, Home title/logo polish, and soft colored lesson-selection cards.

### Desktop parity guidance

The reviewed Windows desktop client walkthrough presentation is a product source model. Mobile should preserve product flow and behavior while using phone-first layouts. The desktop source flow is `Start -> Settings/preferences -> Choose level -> Pick topic -> Pick situation -> Practice`; level selection remains a lesson-start step before topic/situation selection, not a Settings field.

### Phase 3: Lessons and progress

- Complete: lesson-start skeleton from Home to soft colored Choose Level, Choose Topic, Choose Situation screens.
- Complete and production-verified: Android text lesson foundation, including authenticated session start, CMS/backend runtime opening, scenario selection, text conversation, message persistence, Finish, and backend-owned summary display.
- Complete and production-verified: Finish plus backend summary flow against production backend `0.1.35-backend.112` or later.
- Backend `.112` is the verified dependency because it supports nested Responses API output extraction for persisted learner summaries; `.111` is the previous rollback backend.
- Complete: real mobile Hint flow through `POST /api/lesson-chat/hint`, with backend-owned Hint behavior, local pre-context guidance, CMS-owned first roleplay example Hint support, inline non-transcript UI, existing auth refresh behavior, and no changes to lesson counters, Finish payload, or Summary.
- Complete in functional commit `1a392dc`: confirmed mobile lesson abandonment through `POST /api/lesson-sessions/{sessionId}/abandon` with no request body, shared visible Back/Android system Back leave confirmation, no silent Finish, no Summary generation, duplicate-abandon prevention, retryable network/backend failure behavior, and existing auth refresh behavior.
- Complete: real per-message learner Feedback through `POST /api/lesson-chat/feedback`, with the existing full LessonChatRequest contract, backend-owned correction behavior, persisted learner-message GUID requirement, expandable non-transcript per-message UI, per-message caching, study-language output, and no changes to counters, Finish, Summary, Hint, Translation, abandonment, progression, or entitlement.
- Complete: manual tutor-message TTS playback through `POST /api/audio/speech`, raw WAV binary handling, temporary per-screen caching, one active lesson `AudioPlayer`, learner-safe retryable errors, and no changes to counters, Finish, Summary, Hint, Translation, Feedback, abandonment, progression, or entitlement.
- Complete: learner microphone recording and speech-to-text through `POST /api/audio/transcribe`, authenticated multipart WAV upload, Android `RECORD_AUDIO` permission, local WAV/duration/silence validation, editable transcript insertion, no automatic send, and no changes to lesson counters or message creation.
- Keep pending: automatic tutor playback, GIF avatar state binding, fullscreen Conversation mode, realtime/continuous voice conversation, history/progress screen, mobile billing, analytics, crash reporting, and store release work.
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
- Complete: backend voice upload to `POST /api/audio/transcribe` using authenticated multipart WAV.
- Complete: manual tutor-message TTS playback.
- Keep automatic tutor playback, GIF avatar state integration, fullscreen Conversation mode, and realtime/continuous voice conversation as future isolated work.
- Conversation mode planning is the next isolated functional area, but implementation should not be mixed with this documentation update.

### Phase 5: Google Play Billing bridge — later, not the next safe phase

- Add Google Play Billing runtime integration.
- Send purchase tokens to backend for verification.
- Refresh entitlement status from backend.
- Validate restore/reconciliation flows.

## Android implementation considerations

- Confirm minimum SDK and target SDK before creating project files.
- Keep backend base URL configurable by build flavor or environment file without secrets.
- Use Android secure storage for session material.
- Request microphone permission only for learner-initiated recording; no background microphone permission is used.
- Ensure network security permits HTTPS to production backend.
- Avoid storing sensitive provider or backend secrets in the app bundle.

## iOS posture

The repository should avoid Android-only architectural decisions where reasonable, but iOS should not drive V1 implementation. Do not create iOS project files until the team explicitly approves an iOS phase.
