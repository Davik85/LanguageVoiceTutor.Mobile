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

The current green baseline includes backend lesson session start from the lesson placeholder screen plus service/model-only support for the backend session-owned text reply placeholder endpoint. It has `git diff --check`, `dart format --set-exit-if-changed lib test`, `flutter analyze`, and `flutter test` passing: diff check passes, format reports 39 files and 0 changes, analyze reports `No issues found`, and tests report 90 passing tests. Settings/password recovery remains part of this verified baseline. Lesson runtime is still not implemented, and the lesson screen remains placeholder-only. Settings has stable **Account**, **Learning**, **Audio**, and **Connection status** advanced area, **Save settings** is visible and tested, and user level is not in Settings. Settings selected tutor persistence is complete through `/api/me/settings`: mobile reads and sends `selectedTutorId`, selection survives app/emulator restart, and tutor voice remains a separate setting. Tutor selection belongs in Settings, and Home no longer shows tutor diagnostics or an **Available tutors** card. Home now shows the provided Language Voice Tutor logo next to a more branded, accessible title, preloads the logo during startup before Home is displayed, shows learner-friendly signed-in, account, and plan status while keeping account/access decisions backend-owned, and uses **Start lesson** to open the completed lesson-start navigation skeleton before reaching the Lesson placeholder. Choose Level uses soft level-specific cards, Choose Topic uses soft topic-specific cards, and Choose Situation uses the selected topic color family. The mobile logo source is `app/assets/brand/source/lvt-logo-source.png`; the app logo is `app/assets/brand/lvt-logo.png`; the loading screen shows only the centered logo; and Android launcher icons under `app/android/app/src/main/res/mipmap-*` are derived from the same provided source logo. Product-friendly situation labels are in place for all six topics, Travel includes Airport check-in, Hotel check-in, Asking for directions, Ordering transport, and Lost luggage, and situation labels no longer show `Placeholder:`. Settings language dropdowns show friendly names while still storing and sending backend IDs. Real lesson runtime, voice recording, TTS playback, billing, analytics, crash reporting, and store release setup are not implemented by this documentation update.

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

- Completed as UI-only foundation: lesson-start skeleton from Home to soft colored Choose Level, Choose Topic, Choose Situation screens, and Lesson placeholder.
- The lesson session foundation attempt was reverted because it combined too much at once: models, AuthService, navigation, lesson UI, and tests. Do not repeat that pattern.
- Next safe phase: Settings UX polish or lesson runtime planning by inspecting backend lesson/session APIs before implementation.
- Future lesson runtime work must be split into small PRs: first read-only investigation or service-only, then UI-only using an already-tested service. Do not combine service, models, navigation, UI, and widget tests in one PR.
- Lesson runtime foundation must not add OpenAI calls from mobile and must not include voice, TTS, realtime, billing, analytics, history, or unrelated runtime features.
- Implement lesson access checks.
- Implement lesson start/resume only after the backend lesson/session contract is confirmed.
- Implement tutor message exchange through backend.
- Implement lesson history and progress screens.


### Current lesson-runtime boundary

Mobile starts backend lesson sessions from the lesson placeholder screen using the backend-compatible `POST /api/me/lesson-sessions` request shape. Real mobile AI chat is not implemented. The next lesson implementation must mirror the existing desktop/CMS/backend runtime instead of creating a separate mobile runtime.

Use this flow for mobile alignment:

```http
GET /api/me/lesson-access
GET /api/me/subscription-status
GET /api/me/lesson-content/scenarios/{scenarioKey}
POST /api/me/lesson-sessions
POST /api/lesson-chat/reply
POST /api/me/lesson-sessions/{sessionId}/messages
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

Next implementation step: Mobile text lesson Phase 1 should load backend/CMS runtime scenario content and call `POST /api/lesson-chat/reply`, then persist messages through `POST /api/me/lesson-sessions/{sessionId}/messages` according to the existing desktop/backend flow.

Explicit no-go items for that step: no temporary mobile-only backend endpoints, no new safe/catalog endpoints for intermediate convenience, no duplicate mobile prompt/runtime system, no backend changes unless a real final shared lesson-runtime design is approved, and no voice/TTS/realtime/hints/feedback/summary/history/billing.

Before changing mobile lesson behavior, read the desktop/CMS/backend lesson flow docs and inspect the existing desktop flow. Do not create new backend endpoints just because the mobile client does not yet mirror the existing contract.


### Phase 4: Voice and TTS — later, after lesson runtime planning

- Implement Android recording permissions.
- Implement backend voice upload.
- Implement TTS playback using backend-provided responses.
- Add timeout, retry, and error-state handling.

### Phase 5: Google Play Billing bridge — later, not the next safe phase

- Add Google Play Billing runtime integration.
- Send purchase tokens to backend for verification.
- Refresh entitlement status from backend.
- Validate restore/reconciliation flows.

## Android implementation considerations

- Confirm minimum SDK and target SDK before creating project files.
- Keep backend base URL configurable by build flavor or environment file without secrets.
- Use Android secure storage for session material.
- Request microphone permission only when voice features are implemented.
- Ensure network security permits HTTPS to production backend.
- Avoid storing sensitive provider or backend secrets in the app bundle.

## iOS posture

The repository should avoid Android-only architectural decisions where reasonable, but iOS should not drive V1 implementation. Do not create iOS project files until the team explicitly approves an iOS phase.
