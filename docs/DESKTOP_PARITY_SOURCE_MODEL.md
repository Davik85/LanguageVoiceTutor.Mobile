# Desktop Parity Source Model

## Status

The reviewed Windows desktop client walkthrough presentation is now a product reference source for mobile parity. Mobile parity means preserving the desktop product flow, product decisions, and backend-owned state boundaries; it does not mean copying the Windows pixel layout directly.

## Study-language parity model

Desktop confirms three independent concepts: study language selects the language practiced in lessons; native language selects translation output; interface/explanation language selects application chrome. Mobile preserves that separation. A single Mobile study-language definition supplies request, transcription, and TTS metadata, while Desktop-equivalent deterministic local lesson text builds target-language setup, scenario labels, known-context openings, and local Hints from English CMS semantics. Localized learner-facing scenario text always maps back to the canonical CMS ID, canonical English title, runtime variant, and scenario key. Backend `LessonPromptBuilder` and CMS runtime remain the owners of tutor replies, roleplay, Hint, Feedback, corrections, examples, wrap-up, and final replies.

The current Mobile Stage 1 interface foundation uses Flutter `gen-l10n`/ARB for `en`, `ru`, `es`, `fr`, and `de`, with 277 matching messages per catalog. `explanationLanguage` alone controls the interface locale; unsupported values display English without replacing the saved backend value. Completed scope covers Splash/authentication, Home, Settings and its three sections, account/deletion/feedback/reminder/connection UI, fixed levels, and topic/situation selection. Premium, Progress, Lesson History details, remaining Achievement catalogue text, Lesson Chat, Conversation mode, and other static strings remain later work.

Desktop parity at the lesson-selection boundary means canonical data is never translated. Stable topic IDs drive navigation; localized labels/descriptions are presentation-only; unknown IDs fall back to canonical text; and `LessonStartSelection` reconstructs canonical catalog values from stable IDs. Session requests and runtime scenario keys are invariant across the five interface locales, and Free Conversation retains its canonical `lessonContentId` runtime path.

Latest known mobile baseline after commit `fcecef5` (`Fix mobile settings parity foundation`):

- Mobile Settings parity foundation is fixed.
- `dart format --set-exit-if-changed lib test` passed.
- `flutter analyze` returned `No issues found`.
- `flutter test` returned `All tests passed`.
- Settings uses three stable navigation areas: **Profile**, **Lessons**, and **App**.
- **Save settings** is visible and tested.
- User level is selected only in Settings -> Learning.
- Home loads the saved level and follows Choose Topic -> Choose Situation -> Lesson.
- `selectedTutorId` is persisted through `GET /api/me/settings` and `PUT /api/me/settings`.
- Study, native, and interface/explanation language selectors show user-friendly names while storing backend IDs.

## Product parity rule

Mobile must match desktop product logic, not desktop pixel layout. Desktop screens should be translated into phone-first layouts that fit mobile navigation, scrolling, touch targets, platform permissions, and smaller displays.

The historical desktop source flow was:

```text
Start -> Settings/preferences -> Choose level -> Pick topic -> Pick situation -> Practice
```

Mobile now uses the accepted saved-level account flow: learner level is selected in **Settings -> Learning**, and normal lesson start proceeds through **Home -> Choose Topic -> Choose Situation -> Lesson**. Mobile should still preserve product behavior while adapting navigation for phone-first use.

## Settings parity target

Settings parity should gradually cover desktop-equivalent product concepts where the backend contract supports them:

- Profile / learning goal.
- Study language.
- Native language.
- Interface/explanation language.
- Tutor avatar.
- Tutor voice.
- Account/subscription.
- Audio.
- Progress.

Study language, native language, and interface/explanation language are separate concepts.

Current backend-supported mobile settings fields from `GET /api/me/settings` and `PUT /api/me/settings` are:

- `nativeLanguage`
- `studyLanguage`
- `explanationLanguage`
- `speechVoice`
- `speechSpeed`
- `conversationModeEnabled`
- `selectedTutorId`

Current visible mobile Settings navigation is:

- **Profile**: Account, Learning, Audio, and Save settings.
- **Lessons**: Lesson history, Progress, and Rewards.
- **App**: Password & recovery, Feedback & reports, and Practice reminders.

`selectedTutorId` is part of the current settings contract. `GET /api/tutor-options` provides available tutors, and `PUT /api/me/settings` persists a valid selected tutor ID. Tutor voice remains a separate `speechVoice` setting and must not be overwritten automatically when the selected tutor changes.

## Language catalogs

Supported study languages remain:

- English
- French
- German
- Portuguese
- Spanish
- Italian

The long-term approved interface-language list remains:

- `en`
- `es`
- `fr`
- `de`
- `it`
- `pt`
- `ru`
- `pl`
- `ar`
- `ja`
- `ko`
- `sr`
- `hr`
- `bg`

The native/explanation language catalog is broader than the study-language catalog and broader than the release-ready interface-language catalog. Mobile Settings must display friendly names for these choices while sending IDs such as `en`, `es`, or `pl` to the backend.

Stage 1 currently implements `en`, `ru`, `es`, `fr`, and `de`; the remaining approved languages and Arabic right-to-left verification are future work.

## Tutor model

Tutor profiles currently represented by desktop are:

- Lana
- Nelli
- David

Tutor choice is product-significant. It affects display name, profile/persona, and preferred voice behavior in lessons.

Selected tutor persistence is supported by `/api/me/settings`. Tutor voice remains separate from tutor selection.

## Lesson start

Mobile uses the backend-owned account level from `UserSettings.currentLevel`, mapped through the centralized `lessonLevels` collection. The current phone-first flow is **Home -> Choose Topic -> Choose Situation -> Lesson** after the learner taps **Start lesson**; level changes live in **Settings -> Learning**, and the normal flow has no separate level screen. The six current topics are Daily Life, Travel, Work & Business, Job Interview, Restaurant & Cafe, and Free Conversation. CMS-published level profiles remain authoritative for lesson behavior and timing; Mobile does not own lesson complexity or duration rules. No backend deployment was required for this Mobile cleanup because backend release `0.1.35-backend.116` already provided the required `CurrentLevel` settings contract, and the owner physically verified the saved-level lesson-start flow on an Android phone. No backend, Desktop, CMS, website, billing, voice-provider, transcription-provider, semantic resolver, TTS, or database migration changes were made.

## Backend-owned state boundaries

Account, subscription, and progress must remain backend-owned. Mobile must not create mobile-only Premium, limits, history, progress, or subscription state.


## CMS/backend lesson-runtime source of truth

Desktop is the existing working reference client for orchestration, not the owner of lesson behavior. Mobile should inspect and mirror the desktop/CMS/backend lesson flow as a second client, but lesson behavior itself belongs to CMS-authored and backend-published runtime content.

CMS/backend published runtime content is the source of truth for:

- Tutor instructions.
- Level behavior.
- Prompt templates.
- Scenario rules.
- Wrap-up behavior.
- Feedback guidance.
- Lesson methodology.

Mobile must not invent a separate lesson runtime, call OpenAI directly, hardcode CMS lesson behavior in Flutter, duplicate prompts or scenario progression, or use `POST /api/me/lesson-sessions/{sessionId}/reply` for real lessons at this stage.

Existing desktop/CMS/backend lesson flow for mobile to mirror:

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

Next implementation step: Mobile text lesson Phase 1 should load backend/CMS runtime scenario content and call the existing desktop/backend reply flow. Do not add temporary mobile-only backend endpoints, new safe/catalog endpoints for convenience, a duplicate mobile prompt/runtime system, backend changes without an approved final shared lesson-runtime design, or voice/TTS/realtime/hints/feedback/summary/history/billing in that next text-chat step.

Before changing mobile lesson behavior, read the desktop/CMS/backend lesson flow docs and inspect the existing desktop flow. Do not create new backend endpoints just because the mobile client does not yet mirror the existing contract.

## Lesson Chat parity target

Lesson Chat parity should include:

- Text input.
- Voice recording.
- Hints.
- Translation.
- TTS/play voice.
- Conversation mode.
- Finish lesson and summary/history flow.

Conversation mode should reuse the same lesson flow concept:

```text
record speech -> transcribe audio -> generate lesson reply -> display and speak the same text -> keep transcript for review
```

Lesson runtime, voice recording, TTS playback, billing, analytics, Google Play Billing, and Apple billing remain out of scope for the current documentation update.

## Current mobile text lesson parity milestone

Mobile now mirrors the shared desktop/CMS/backend text lesson path through completion and backend-owned summary display. The verified Android flow starts an authenticated session, loads CMS/backend runtime content, renders the opening and scenario suggestions, accepts scenario selection through typed input, sends text practice turns through `POST /api/lesson-chat/reply`, persists transcript messages under the backend session, finishes through `PUT /api/me/lesson-sessions/{sessionId}/finish`, and reads the learner summary through `GET /api/me/lesson-sessions/{sessionId}/summary`, and abandons unfinished sessions through `POST /api/lesson-sessions/{sessionId}/abandon` when the learner confirms leaving via visible Back or Android system Back.

Backend-owned boundaries remain unchanged: backend owns lesson-session state, lesson completion, and summary generation; CMS/backend runtime owns tutor behavior and lesson methodology; and mobile never generates summaries locally. Abandon does not call Finish, request Summary, change `validTurnCount`, persist transcript messages, or alter Hint behavior. Desktop remains a behavior and orchestration reference for the shared runtime; it is not a second source of lesson behavior for mobile to fork.
