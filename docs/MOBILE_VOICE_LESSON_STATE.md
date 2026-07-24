# Mobile lesson, voice, Conversation mode, and voice scenario state

Authoritative source commit: `f195dc2` (`feat: add mobile voice lesson and conversation flows`). This document records the completed Mobile lesson, voice, Conversation mode, voice scenario-resolution state from that source commit, and the later documented Desktop-parity transcription behavior.

## Product boundary

Mobile is another client of the same Language Voice Tutor product. Backend and CMS remain the source of truth for lesson runtime content, topics and scenarios, tutor behavior, session ownership, AI calls, and subscription/account state. Mobile contains no OpenAI API key, provider prompt, or provider model ID. Mobile does not invent CMS scenario IDs or variants.

## Study language through voice and lesson surfaces

English, French, German, Portuguese, Spanish, and Italian resolve through the same centralized Mobile study-language definition. Lesson Chat and Conversation mode transcription and TTS send the same exact target-language metadata, independent of native/translation and interface languages. Initial setup, localized scenario labels, known CMS confirmation/opening text, pre-context Hint, and the first CMS example Hint are deterministic target-language text ported from Desktop behavior. Voice candidate requests retain canonical candidate IDs and canonical English titles and use localized titles only as learner-facing candidate context. Exact localized titles can resolve the same canonical runtime variant; published/free/clarify/unsafe/failure semantics are unchanged. The separate Stage 1 Flutter interface foundation covers `en`, `ru`, `es`, `fr`, and `de`, but Lesson Chat and Conversation mode still contain pending static interface strings. The obsolete voice-transcription disclosure has been removed. Backend/CMS ownership is unchanged, and no backend deployment was required.

## Lesson experience

The committed Mobile client includes a separate Conversation mode screen while normal Lesson Chat remains available. Entering Conversation mode uses the existing lesson session and does not start a second lesson session. Lesson Chat and Conversation mode share transcript safety handling and now use one shared Mobile transcription request builder, while Conversation mode adds independent **Auto-send voice** and **Auto-play tutor voice** controls.

The lesson experience separately handles published CMS scenarios and free custom scenarios. Known published scenarios can use a local CMS-derived opening after selection; free scenarios continue through the custom-context lesson reply path without invented CMS variants. Hint behavior remains backend-owned and uses the selected lesson context after a scenario has started. Audio playback handles completion and recovery so voice controls return to a usable state after playback ends or fails. Tutor avatar state is handled with preload fallback rather than assuming every possible lesson-chat avatar asset is present. Keyboard-open layout keeps the composer and **Send** button visible without `RenderFlex` overflow.

## Tutor avatar display and state synchronization

Lesson Chat avatar header now fills the complete 240-pixel header instead of the obsolete centered 160 x 190 constraint. It uses `BoxFit.cover` with `Alignment.topCenter`; Back, Finish, level/topic, tutor status, and Conversation mode controls remain above the avatar. The light radial overlay that caused a washed-out glare was removed, and the Conversation mode visual layout was not changed by this Lesson Chat header work.

Tutor state synchronization now follows the active audio operation: `idle` means no active tutor or learner audio operation; `listening` starts after recording successfully starts; `transcribing` starts when recording stops and transcription processing begins; `thinking` represents tutor reply, Hint, Feedback, or speech-generation processing where applicable; `speaking` starts when tutor audio playback actually starts and ends when playback completes, stops, fails, is cancelled, or the screen is left. Manual and automatic tutor playback both use the synchronized playback path. The previous root cause was that the audio-player play `Future` was awaited before the playback-start callback, so `speaking` could start only after playback was already complete. The playback-start callback now runs when playback is launched, while the completion stream remains the source of truth for playback completion. Stale callbacks are protected by operation-generation checks.

Physical Android validation confirmed that state transitions are substantially better synchronized on a device. Do not claim that every timing edge case is fully stabilized; broader repeated testing remains useful.

## Voice scenario selection

Voice scenario selection is a two-stage flow used only for the initial voice scenario-selection turn.

### Stage 1 — deterministic Mobile resolution

Before calling the backend semantic resolver, Mobile attempts deterministic resolution against the current runtime CMS candidate list by matching:

- displayed option number;
- ordinal;
- normalized exact CMS title;
- uniquely identifiable very small recognition error.

Mobile does not invent CMS scenario IDs or variants during this stage.

### Stage 2 — backend semantic resolution

If deterministic resolution does not safely select a scenario, Mobile calls:

```http
POST /api/me/lesson-sessions/{sessionId}/voice-scenario-resolution
```

This endpoint is called only during the initial voice scenario-selection turn. The request includes the current runtime CMS candidate list so the backend resolves against the same published options the learner can see. The backend response can be:

- `published_context`
- `free_context`
- `clarify`
- `unsafe`

Later voice turns bypass scenario resolution and proceed as normal lesson replies.

### `published_context`

For a published context, Mobile uses the canonical CMS ID, title, and variant returned by the resolver. It adds one canonical learner context bubble and one CMS-derived tutor opening, persists both once, and makes zero lesson-reply calls during scenario selection. Published scenarios retain `selectedContextVariant` after selection, and later voice replies continue as normal lesson replies without calling the resolver again.

### `free_context`

For a free custom context, Mobile preserves the learner's specific custom situation, uses no invented CMS variant, and continues through the existing custom-context lesson reply flow.

### `clarify`

For clarification, Mobile starts no scenario, persists no learner turn, makes no lesson-reply call, and offers likely CMS choices for the learner to choose from.

### `unsafe`

For unsafe resolver results, Mobile does not start a scenario or expose unsafe content as a committed lesson turn. The learner remains in a safe recovery path.

### Resolver failure

If resolver failure occurs, Mobile does not guess. Safe recognized text remains available for review in normal Lesson Chat, and voice controls are restored.

### After scenario selection

After a scenario is selected, later voice replies are normal lesson replies. Published scenarios retain the selected CMS variant through `selectedContextVariant`, and the scenario resolver is not called again.

## Desktop-parity transcription behavior

Mobile uses the existing authenticated `POST /api/audio/transcribe` endpoint and the existing multipart contract; no new backend endpoint, provider integration, or backend deployment requirement was added for the documented transcription-parity behavior. Mobile has an explicit study-language definition containing ID, English name, native name, and transcription language code. Supported study languages remain English, French, German, Portuguese, Spanish, Italian. Speech recognition always uses the selected study language; native language and explanation language do not influence transcription.

During the first unresolved scenario-selection turn, Mobile sends a short transcription context built from the currently visible runtime/CMS context candidates. Candidate titles come from current lesson runtime data and are not hardcoded. The context asks for exact transcription in the selected study language without translation or paraphrasing. During active roleplay, the selected lesson context is used as the transcription hint. Conversation mode uses the same study-language definition and available lesson context as Lesson Chat. When runtime context is unavailable, Mobile safely sends an empty or minimal context instead of inventing lesson data.

Semantic scenario resolution remains unchanged: deterministic numeric and exact-title matching still runs locally; unresolved first voice choices still use the existing backend semantic resolver; `published_context`, `free_context`, `clarify`, `unsafe`, and backend failure behavior remain unchanged; and the canonical CMS candidate returned by backend is still used. Translation remains a separate explicit `POST /api/translate` action.

## Backend dependency

The existing backend semantic voice scenario resolver remains in use for unresolved first voice choices. The Desktop-parity transcription update did not add a backend endpoint, provider integration, backend deployment requirement, or API contract change.

## Verification recorded for `f195dc2`

- `flutter analyze`: no issues.
- Full Flutter suite: 180 passed.
- `lesson_start_flow_test.dart`: 54 passed.
- `conversation_mode_screen_test.dart`: 5 passed.
- `transcript_script_normalizer_test.dart`: 3 passed.
- `voice_scenario_intent_resolver_test.dart`: 5 passed.
- Debug APK build succeeded.
- APK path: `app/build/app/outputs/flutter-apk/app-debug.apk`.

## Verification recorded for authentication resilience, avatar synchronization, and Feedback & reports

- AuthService focused tests for authentication resilience: 44 passed.
- Splash focused tests for authentication resilience: 2 passed.
- `flutter analyze`: no issues.
- AuthService focused tests after Feedback & reports support: 45 passed.
- Settings focused tests for Feedback & reports: 27 passed.
- `flutter analyze`: no issues.
- Physical Android validation confirmed substantially better tutor state synchronization without declaring all timing edge cases fully stabilized.

## Verification recorded for Desktop-parity transcription

- `dart format`: completed successfully.
- `flutter analyze`: completed with no issues.
- `lesson_start_flow_test.dart`: 58 passed.
- `conversation_mode_screen_test.dart`: 5 passed.
- `transcript_script_normalizer_test.dart`: 3 passed.
- Transcription-parity focused tests: 12 passed.
- Full Flutter suite: 197 passed, 0 failed.
- Debug Android APK build succeeded.

## Lesson feedback and summary presentation boundary

The global Mobile product typography remains in effect for Home and Settings. `LessonScreen` applies a local neutral text theme so an application-wide visual style cannot flatten the active lesson's content hierarchy. This boundary applies only to lesson presentation; it does not change lesson messages, feedback fields, summary data, accessibility labels, backend requests, or completion behavior.

Learner feedback uses a warm supporting container with separate white cards for quick summary, corrected version, grammar, vocabulary, culture, and more-natural phrasing. The completed lesson summary uses a distinct "What went well" panel, a warm "What to improve" panel, and separate phrase/section panels. These structures are visual adaptations of the Desktop feedback and summary hierarchy for the smaller Mobile viewport.

Automated regression coverage in `test/lesson_start_flow_test.dart` provides the Home dependencies used by the start-flow fixture: a permitted lesson-access decision plus unavailable Progress and Achievements responses. This keeps the fixture on its intended in-app route instead of allowing an inherited authenticated-service call to navigate to an unregistered `/login` route. The production authentication and Home behavior are not changed by this test-only fake.

## Remaining validation boundary

The saved-level learner-level/start-flow slice has completed owner physical Android validation, including saved-level lesson start, speech recognition, Lesson Chat, Conversation mode, backend-owned completion and summary generation, and summary display. The six-language study-language slice has also completed owner physical Android verification: all six study languages can be selected and saved in Settings; lessons launch using the selected study language; speech recognition uses the selected study language; and Conversation mode works using the selected study language. Broader repeated testing on different physical devices and network conditions may still be useful. Do not declare voice recognition or all tutor-state timing edge cases fully stabilized yet. Missing Lesson Chat avatar assets remain a separate issue. The optional Desktop Realtime transcription language issue is outside this Mobile change.

Further optional validation outside the completed saved-level/start-flow and six-language study-language slices is to run the committed Mobile client repeatedly on different physical Android devices and network conditions and verify:

- published scenario recognition with imperfect speech;
- free custom scenario selection;
- clarification behavior;
- later voice turns retain the selected CMS variant;
- keyboard-open layout;
- normal Lesson Chat and Conversation mode.
