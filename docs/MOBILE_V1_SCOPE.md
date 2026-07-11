# Mobile V1 Scope

## Goal

Mobile V1 establishes an Android-first Flutter client for Language Voice Tutor that uses the existing production backend and shared product model. The current Android skeleton baseline is verified locally on Android Emulator, but the app remains placeholder UI only. It should let an existing or new user access the same account, subscription entitlement, usage limits, lesson history, progress, and AI tutor behavior used by the Windows desktop app.

## Current verified baseline

Latest known functional Translation commit: `9d2476b` (`Add mobile message translation`). Latest known settings language persistence fix: `340c950` (`Fix mobile settings language persistence`). The Flutter Android client under `app/` has a production-verified text lesson loop, completed mobile Hint flow, and green Settings parity/Home polish baseline. Settings has stable visible **Account**, **Learning**, **Audio**, and **Connection status** sections, **Save settings** is visible and tested, user level is not in Settings, and selected tutor persists through the backend settings API. Tutor selection belongs in Settings; Home no longer shows tutor diagnostics. Home shows the Language Voice Tutor logo/title with startup logo preloading, friendly account/access status, and starts a lesson-start navigation flow.

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

The reviewed Windows desktop client walkthrough presentation is now a product reference source for mobile parity. Mobile must match desktop product logic, not desktop pixel layout, and should translate desktop screens into phone-first layouts. The desktop source flow is `Start -> Settings/preferences -> Choose level -> Pick topic -> Pick situation -> Practice`. Level selection must remain a separate lesson-start step before topic/situation selection, not a Settings field.

Study language, native language, and interface/explanation language are separate concepts. Supported study languages remain English, French, German, Portuguese, Spanish, Italian. Release-ready interface languages remain `en`, `es`, `fr`, `de`, `it`, `pt`, `ru`, `pl`, `ar`, `ja`, `ko`, `sr`, `hr`, and `bg`. The native/explanation language catalog is broader than both the study-language and interface-language catalogs. Mobile Settings shows user-friendly language names while storing and sending backend language IDs.

Tutor profiles currently represented by desktop are Lana, Nelli, and David. Tutor choice is product-significant because it affects display name, profile/persona, and preferred voice behavior in lessons.

## Current lesson-start skeleton

Mobile now includes a UI-only lesson-start skeleton that follows the desktop product order: `Home -> Choose Level -> Choose Topic -> Choose Situation -> Lesson placeholder`. The screens are phone-first adaptations and do not copy the Windows layout pixel-by-pixel. Choose Situation uses product-friendly desktop-aligned labels instead of placeholder wording. The Lesson placeholder displays the selected level, topic, and situation. Real lesson runtime, lesson chat, voice recording, TTS playback, AI tutor calls, Conversation Mode runtime, and mobile-only backend lesson state remain out of scope for this skeleton.

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

Next isolated engineering task: active lesson lifecycle on mobile. A confirmed leave should use the existing backend abandon flow, Back navigation must not silently Finish a lesson, and ordinary leave must not generate a Summary. Do not add temporary mobile-only backend endpoints, new safe/catalog endpoints for convenience, backend changes without an approved final shared lesson-runtime design, voice, TTS, realtime, feedback detail, history, or billing as part of that task.

Before changing mobile lesson behavior, read the desktop/CMS/backend lesson flow docs and inspect the existing desktop flow. Do not create new backend endpoints just because the mobile client does not yet mirror the existing contract.

## Next implementation priority

The next safe implementation work should continue from the green Settings baseline, Home polish, and lesson-start navigation skeleton. Keep slices small and mobile-only unless an API gap is explicitly approved. Recommended small next steps are Settings UX polish and lesson runtime planning by inspecting backend lesson/session APIs before implementation. Billing, voice recording, TTS, analytics, crash reporting, Google Play Billing, Apple billing, and store release setup remain later phases and should not be started without a separate plan.

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
- Voice upload to backend for tutor processing.
- TTS playback using backend-provided responses or assets.
- Google Play Billing bridge where the mobile app receives a purchase token and sends it to the backend for verification.

## Out of scope for Mobile V1 foundation

- Implementing billing before backend auth/account/subscription-status integration is confirmed.
- Implementing voice, TTS, analytics, crash reporting, or store release setup before the backend account path is validated.
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

Text lesson foundation is complete. Finish plus backend-owned summary display is complete and production-verified against backend `0.1.35-backend.112` or later. The real mobile Hint flow is complete in functional commit `f9dbc06` (`Add mobile lesson hint flow`), and real per-message Translation is complete in functional commit `9d2476b` (`Add mobile message translation`), without backend changes or a backend deployment requirement. Mobile still does not call OpenAI directly, does not own tutor behavior, lesson methodology, Hint prompt logic, or summary generation, and never creates a local transcript-derived summary. CMS/backend runtime remains the lesson behavior source of truth; desktop remains a behavior/orchestration reference rather than a separate mobile runtime source.

Mobile Hint uses `POST /api/lesson-chat/hint` after context selection with the existing authenticated bearer-token and refresh-on-401 flow. Before context selection, Hint is local only and asks the learner to choose a visible situation or type a custom one; it does not call the backend or show the CMS example Hint early. Numeric choices resolve against CMS/runtime context variants, context titles resolve case-insensitively, and custom learner-entered situations are supported without inventing a CMS variant ID. The selected context is mutable lesson-screen state reused by both lesson replies and Hint requests.



Mobile Translation uses `POST /api/translate` through the existing authenticated bearer-token and refresh-on-401 flow. Backend owns provider calls, prompts, rate protection, session validation, and translation behavior; Flutter does not call OpenAI or another provider directly. Tutor and learner messages use the same endpoint for the exact visible message text, include the active backend lesson session ID, and do not require persisted lesson-message IDs. Translation targets the learner's backend-saved native language, converted from the saved native-language ID to the backend-compatible English language name, while source-language metadata comes from the selected study language. Inline per-message results are cached, can be hidden and reshown without another backend request, and do not persist lesson messages, increment counters, alter Finish/Summary/Hint/abandonment/progression/entitlement, or appear on Summary.

The first active roleplay Hint may use the CMS-owned `hintRules.exampleHint`; later Hint requests send the full existing `LessonChatRequest` context, including active session ID, runtime scenario, current context, transcript, last tutor message, level, topic, situation, and language/settings data. Hint is a compact dismissible inline support card, not a chat message, and is not added to the transcript. It blocks duplicate simultaneous requests, is disabled during incompatible operations and after completion, and does not create lesson messages, increment `learnerTurnCount`, change `validTurnCount`, alter the Finish payload, or generate/change the Summary. HTTP 429 means temporary Hint unavailability; authentication, session-ended, network, backend, and malformed-response states remain learner-safe and consistent with the existing lesson flow.

Completed and remaining Mobile V1 or later phases:

- Real per-message Translation. **Complete** in functional commit `9d2476b` (`Add mobile message translation`).
- Per-message Feedback. **Next isolated functional block**.
- Lesson history and progress screens.
- Tutor TTS playback.
- Microphone recording and speech-to-text.
- Animated tutor GIF loading and state binding.
- Fullscreen Conversation mode.
- Google Play Billing.
- Apple billing.
- Analytics, crash reporting, and store release work.


## Next isolated engineering task

Per-message Feedback is the next isolated functional block. Keep TTS/tutor voice playback, microphone recording, speech-to-text, GIF avatar state integration, fullscreen Conversation mode, history/progress screen, mobile billing, analytics, crash reporting, and store release as future work.
