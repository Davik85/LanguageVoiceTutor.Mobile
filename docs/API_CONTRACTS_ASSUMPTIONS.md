# API Contracts and Assumptions

## Backend base URL

Production backend:

```text
https://api.languagevoicetutor.com
```

All mobile-to-backend communication must use HTTPS.

## Contract status

This document records expected contracts and assumptions before implementation. Endpoint names are placeholders unless already confirmed by backend documentation or backend code. Exact paths, methods, payloads, response shapes, authentication requirements, and error codes must be confirmed before Flutter runtime code is added.

## Authentication and session expectations

Expected behavior:

- Mobile authenticates against the existing backend account system.
- Mobile receives backend-issued session credentials or tokens.
- Mobile stores session credentials using platform-secure storage.
- Mobile sends credentials only to the Language Voice Tutor backend over HTTPS.
- Backend remains responsible for validating sessions and revoking access.

Open contract questions:

- Login method: email/password, magic link, OAuth, desktop-compatible flow, or another flow.
- Whether refresh tokens are issued.
- Token expiration and refresh behavior.
- Logout and session revocation endpoint.
- Device/session listing requirements.

## `/api/me` and settings expectations

Expected `/api/me` behavior:

- Return current authenticated user identity.
- Return account-level flags needed by mobile UI.
- Avoid returning secrets or provider credentials.

Expected settings behavior:

- Return user preferences needed by the mobile experience.
- Persist mobile-compatible settings through backend APIs.
- Keep settings consistent with desktop where the same preference exists.

Confirmed current settings contract:

- `GET /api/me/settings` and `PUT /api/me/settings` support backend-owned settings fields: `nativeLanguage`, `studyLanguage`, `explanationLanguage`, `speechVoice`, `speechSpeed`, `conversationModeEnabled`, and `selectedTutorId`.
- Mobile keeps stable internal dropdown IDs such as `en`, `tr`, and `ru`.
- `PUT /api/me/settings` serializes `studyLanguage` using the backend-required English study-language name: `English`, `French`, `German`, `Portuguese`, `Spanish`, or `Italian`.
- `nativeLanguage` and `explanationLanguage` remain in their supported backend ID form.
- `GET /api/me/settings` parsing accepts both IDs and English names and normalizes them to internal dropdown IDs.
- Mobile continues to send the complete seven-field settings payload.
- `studyLanguage`, `nativeLanguage`, and `explanationLanguage` remain separate backend fields and must not be collapsed into one language preference.
- Mobile may send `selectedTutorId` to `/api/me/settings` when the user chooses a valid tutor from `GET /api/tutor-options`.
- Mobile must not document fake local selected-tutor persistence as the source of truth.
- `speechVoice` remains separate from `selectedTutorId`.
- Safe backend HTTP 400 settings-save error text can be shown to the learner.
- HTTP 503 uses neutral temporary-unavailable wording.
- Authentication failure remains distinct.
- Failed settings saves restore the last backend-confirmed settings so unsaved values do not look persisted.
- Successful settings saves use the settings object returned by backend.

Possible `/api/me` data fields:

- User ID.
- Email or display identifier.
- Account status.
- Locale or target language preferences.
- Subscription summary suitable for display.

## Tutor options expectations

Confirmed current tutor options contract:

- `GET /api/tutor-options` remains the source for available tutor options.
- Current mobile documentation treats desktop tutor profiles as Lana, Nelli, and David.
- Tutor choice is product-significant because it affects display name, profile/persona, and preferred voice behavior in lessons.
- Available tutor options are not the same as persisted selected tutor state; selected tutor persistence remains backend-owned through `/api/me/settings`.

## Subscription-status expectations

Expected behavior:

- Mobile asks backend for subscription or entitlement status.
- Backend returns the authoritative entitlement state.
- Mobile displays the returned state but does not compute Premium locally.
- Backend handles provider reconciliation across Paddle, Google Play, Apple, or future providers.

Possible response concepts:

- Entitlement tier.
- Active/inactive state.
- Renewal or expiration timestamp when appropriate.
- Provider/source label when safe to expose.
- Grace period or billing issue state.
- Usage limits and remaining quota summary.

## Lesson-access expectations

Expected behavior:

- Mobile asks backend whether the user can start or continue a lesson.
- Backend evaluates subscription, usage limits, account status, and lesson policy.
- Mobile follows the backend decision.

Possible response concepts:

- `allowed` boolean.
- Denial reason code.
- User-facing message key or display message.
- Remaining lesson/message/voice quota.
- Upgrade or billing action hint.

## Lesson start, message, history, and progress expectations

## Confirmed Progress V1 contract

Production backend `0.1.35-backend.124` provides authenticated `GET /api/me/progress`. Mobile calls it through the shared bearer-token and refresh-on-401 flow. Official totals, 7-/30-day windows, UTC calendar boundaries, completion eligibility, and streaks are backend-owned; Mobile only parses the response and must not aggregate the bounded recent History list. The data foundation supplies models, safe result handling, and the service call for the UI.

Mobile now displays that backend contract through a Home Progress entry and dedicated screen. The UI formats backend values only, uses the backend-provided `dailyActivity` sequence without date shifting, and provides loading, empty, authentication-required, unavailable, and retry states. It does not expose technical contract fields or raw errors.

Desktop parity source flow: `Start -> Settings/preferences -> Choose level -> Pick topic -> Pick situation -> Practice`. Level selection is part of lesson start and must not be a Settings field.

Mobile must follow the existing desktop/CMS/backend lesson flow as a second client. It must not invent a separate lesson runtime, call OpenAI directly, hardcode CMS lesson behavior in Flutter, or duplicate backend-owned prompt/runtime logic. Desktop is a reference client for orchestration, not the owner of lesson behavior. CMS/backend published runtime content is the source of truth for tutor instructions, level behavior, prompt templates, scenario rules, wrap-up behavior, feedback guidance, and lesson methodology.

Confirmed lesson-flow endpoints for mobile alignment:

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
POST /api/lesson-sessions/{sessionId}/abandon
PUT /api/me/lesson-sessions/{sessionId}/finish
GET /api/me/lesson-sessions/{sessionId}/summary
```

Current mobile session-start request shape for `POST /api/me/lesson-sessions`:

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

Real desktop lesson replies use:

```http
POST /api/lesson-chat/reply
```

Persisted lesson messages use:

```http
POST /api/me/lesson-sessions/{sessionId}/messages
```

Do not use the premature placeholder endpoint below for real mobile lessons at this stage:

```http
POST /api/me/lesson-sessions/{sessionId}/reply
```

## Confirmed lesson Hint contract

The completed mobile Hint flow uses the existing shared backend lesson runtime; no backend changes or backend deployment are claimed by this documentation update. The mobile Hint endpoint is:

```http
POST /api/lesson-chat/hint
```

Mobile sends the same authenticated bearer token used by lesson APIs and reuses the existing refresh-on-401 flow. Backend owns AI prompt behavior, teaching methodology, provider calls, usage protection, and learner-safe Hint responses. Flutter does not call OpenAI directly, does not contain Hint prompt logic, and does not copy private prompt contents.

Before context/situation selection, Hint is local only: mobile asks the learner to choose one of the visible situations or type a custom one, does not call the backend, and does not show the CMS `hintRules.exampleHint`. Context selection resolves numeric choices against CMS/runtime context variants, resolves context titles case-insensitively, and supports custom learner-entered situations without inventing a CMS variant ID. The selected context is stored in mutable lesson-screen state and reused by both lesson reply and Hint requests.

After context selection, the first active roleplay Hint may use the CMS-owned `hintRules.exampleHint`; Flutter must not create replacement scenario-specific teaching text. Later active-lesson Hint requests use the full existing `LessonChatRequest` contract, including active backend session ID, runtime scenario, current context, transcript, last tutor message, level, topic, situation, and language/settings data.

Hint UI and persistence boundaries:

- Hint is a compact dismissible inline support card, not a tutor or learner chat message.
- Hint is not added to the transcript.
- Duplicate simultaneous Hint requests are blocked.
- Hint is disabled during incompatible lesson operations and after successful completion.
- Hint does not create a lesson message.
- Hint does not increment `learnerTurnCount`.
- Hint does not change `validTurnCount`.
- Hint does not change the Finish payload.
- Hint does not generate or alter the lesson Summary.

Hint error boundaries:

- Authentication failures reuse the existing lesson authentication-required behavior.
- Session-ended responses disable further lesson interaction consistently.
- HTTP 429 is temporary Hint unavailability; this document does not promise a product-level free daily Hint quota.
- Network, backend, and malformed-response errors remain learner-safe and retryable.



## Confirmed lesson Translation contract

The completed mobile Translation flow uses the existing shared backend lesson runtime; no backend deployment is claimed by this documentation update. The mobile Translation endpoint is:

```http
POST /api/translate
```

Mobile sends the same authenticated bearer token used by lesson APIs and reuses the existing refresh-on-401 flow. Backend owns provider calls, prompts, rate protection, session validation, and translation behavior. Flutter does not call OpenAI or another provider directly, does not contain provider prompts, and does not contain translation methodology.

Tutor and learner messages use the same endpoint and contract. Translation is requested for the exact visible message text, does not require a persisted lesson-message ID, and includes the active backend lesson session ID. The translation target is the learner's backend-saved native language: mobile converts the saved native-language ID to the backend-compatible English language name for the request. Translation does not use interface or explanation language as its target. Source-language metadata comes from the selected study language.

Translation UI and persistence boundaries:

- Translation appears inline with the original message and is not rendered as a new tutor or learner message.
- Results are cached per message. A second tap hides the cached translation, and a later tap shows the cached translation without another backend request.
- Different messages can be translated independently.
- Duplicate requests for the same loading message are prevented.
- Translation does not persist a lesson message.
- Translation does not increment `learnerTurnCount` or `validTurnCount`.
- Translation does not change Hint, abandonment, Finish, Summary, lesson progression, or subscription entitlement.
- Translation is not shown on the Summary screen because the transcript is not shown there.

Translation error boundaries:

- Authentication failures reuse the existing authentication-required behavior.
- Session-ended responses use the existing terminal-session handling.
- HTTP 429 is temporary Translation unavailability.
- Network, backend, malformed-response, and unexpected failures remain learner-safe and retryable.


## Confirmed lesson Feedback contract

The completed mobile Feedback flow uses the existing shared backend lesson runtime; no backend deployment is claimed by this documentation update. The mobile Feedback endpoint is:

```http
POST /api/lesson-chat/feedback
```

Mobile sends the same authenticated bearer token used by lesson APIs and reuses the existing refresh-on-401 flow. The request uses the existing full `LessonChatRequest` contract rather than a mobile-only schema. Backend owns Feedback prompts, correction rules, level adaptation, scenario context, provider calls, structured output, usage events, and persistence. Flutter does not call OpenAI directly, does not contain correction methodology, and does not copy provider prompts.

Eligibility and persisted-message boundaries:

- Feedback is available only for learner messages; tutor messages do not show Feedback controls.
- Feedback is user initiated and is not requested automatically.
- Mobile retains the real backend GUID returned when a learner message is persisted.
- Feedback waits for the selected learner message's existing persistence operation when necessary.
- Mobile does not invent a backend message ID and does not use the local message ID as a persisted backend ID.
- If persistence is not ready or has failed, Feedback is not requested and the learner receives a retryable not-ready message.

Feedback request context includes the exact learner message text, stable local source message ID, real persisted backend message ID, active backend lesson session ID, learner-message kind, level, topic, subtopic, selected context, current transcript, last tutor message, study/native language metadata, CMS/runtime scenario data, lesson goal/type, tutor profile, and active level-profile data. Do not duplicate the complete JSON schema in additional documents.

Feedback response fields are `shortText`, `correctedVersion`, `grammarTip`, `vocabularyTip`, `cultureTip`, and `naturalVersion`. `shortText` is required and nonblank. Other sections may be empty. Mobile displays only nonblank sections and does not invent missing correction content.

Feedback UI and lesson boundaries:

- Feedback appears in an expandable card directly below the related learner message.
- Feedback is not rendered as a tutor or learner transcript message and does not replace the learner's original text.
- Results are cached per message and can be hidden and shown again without another backend request.
- Different learner messages maintain independent Feedback state.
- Duplicate requests for the same loading message are prevented.
- Translation and Feedback can coexist independently on the same learner message.
- Feedback remains in the study language, is not automatically translated into the learner's native language, does not use explanation language as a client-side override, and does not implement Translation of Feedback sections in this milestone.
- Feedback does not create an extra lesson message, increment `learnerTurnCount`, increment `validTurnCount`, change the Finish payload, generate or alter Summary, change Hint, change message Translation, change lesson abandonment, or alter lesson progression or subscription entitlement.
- Feedback is available only while the lesson transcript is visible and is not added to the Summary screen.

Feedback error boundaries:

- Authentication failures reuse the existing authentication-required flow.
- Terminal-session responses reuse existing session-ended handling.
- HTTP 429 is temporary Feedback unavailability.
- Provider, backend, network, and malformed-response failures remain learner-safe and retryable.
- Raw provider or HTTP details are not shown.

## Confirmed lesson abandon contract

Mobile uses the existing backend abandon flow as a second client of the same product runtime:

```http
POST /api/lesson-sessions/{sessionId}/abandon
```

The request has no body. Mobile sends the same authenticated bearer token used by lesson APIs and reuses the existing refresh-on-401 flow. Backend remains the source of truth for lesson-session state. Visible Back and Android system Back use the same leave-confirmation flow: **Stay** keeps the learner inside the lesson and makes no backend request; **Leave lesson** abandons the unfinished backend session and then closes the lesson screen. Duplicate abandon requests are prevented.

Abandon boundaries:

- Abandon does not call Finish.
- Abandon does not generate or request Summary.
- Abandon does not change `validTurnCount`.
- Abandon does not create or persist a learner or tutor message.
- Abandon does not alter Hint behavior or lesson transcript data.

Failure and timeout boundaries:

- Authentication failures use the existing authentication-required behavior.
- Network/backend failures keep the learner on the lesson screen and allow retry.
- Active-lesson conflict wording is neutral and does not claim that the session is necessarily on another physical device.
- The backend stale active-session interval remains two minutes; no backend timeout change was made and no mobile heartbeat was added.
- Normal confirmed Back navigation releases the session immediately. If the app is force-closed or terminated without the confirmed leave flow, the existing backend timeout remains the fallback. The two-minute timeout is intentionally retained unless real user feedback proves it needs adjustment.

## Confirmed finish and summary contract

The Android mobile client now has a production-verified end-to-end text lesson completion path against backend `0.1.35-backend.112` or later. Version `.112` is required for the verified summary flow because it supports nested Responses API output extraction. Backend `0.1.35-backend.111` is the previous rollback version and should not be treated as the verified summary baseline.

Exact authenticated routes in the current text lesson loop:

```http
GET /api/me/settings
GET /api/me/lesson-access
GET /api/me/subscription-status
POST /api/me/lesson-sessions
GET /api/me/lesson-content/scenarios/{scenarioKey}
POST /api/lesson-chat/reply
POST /api/lesson-chat/feedback
POST /api/audio/speech
POST /api/audio/transcribe
POST /api/me/lesson-sessions/{sessionId}/messages
POST /api/lesson-sessions/{sessionId}/abandon
PUT /api/me/lesson-sessions/{sessionId}/finish
GET /api/me/lesson-sessions/{sessionId}/summary
POST /api/auth/refresh
```

Finish uses this request body:

```json
{
  "validTurnCount": 0
}
```

`validTurnCount` must be a non-negative integer. Mobile counts only learner practice messages sent after scenario/context selection. The scenario/context selection itself is not a practice turn, tutor/assistant messages are excluded, and mobile must not invent its own completion threshold. Backend owns completion acceptance and summary generation.

Summary loading boundaries:

- `ready`: mobile displays only backend-owned learner-safe fields: lesson context, `summary`, `strengths`, `improvements`, `vocabulary`, `grammar`, and `nextSteps`.
- `unavailable`: completion still succeeded; mobile shows a saved/no-summary message and **Done** only. It must not show **Retry** because `GET /api/me/lesson-sessions/{sessionId}/summary` does not regenerate a summary.
- Retryable load error: network, server, timeout, or parse failures while loading summary may show **Retry summary** because retrying repeats the read.
- Authentication failure: mobile shows the separate sign-in-required state and may use `POST /api/auth/refresh` for authenticated retry according to the existing auth flow.

Mobile must never generate a fake/local summary from the transcript, upload a client summary, call `/api/dev` summary routes, use diagnostic summary routes, call OpenAI directly, or display raw server exception text to learners.

Before calling Finish, mobile waits up to 5 seconds for already-started message persistence operations. This is an ordering barrier so the backend summary generator does not run before current writes have had a chance to settle. It is not a blind retry loop, duplicate-write mechanism, or replacement for normal best-effort message persistence.

Expected behavior:

- Lesson access, subscription status, scenario runtime content, session start, replies, and message persistence go through existing backend APIs.
- Backend/CMS runtime content owns tutor behavior, level behavior, prompt rules, lesson methodology, scenario progression, wrap-up rules, and feedback rules.
- Mobile retrieves and displays backend-owned lesson state, then sends user text or voice inputs to backend APIs when those phases are approved.
- Backend orchestrates AI tutor behavior and stores lesson history and progress.
- Mobile retrieves history and progress from backend APIs when those phases are approved.

Confirmed mobile lesson abandonment is complete. Heartbeat or timeout reduction is optional future reliability work only if real user feedback requires it, not the next required task.

Explicit no-go items for the next text-chat step:

- No temporary mobile-only backend endpoints.
- No new safe/catalog endpoints for intermediate convenience.
- No duplicate mobile prompt/runtime system.
- No backend changes unless a real final shared lesson-runtime design is approved.
- No voice, TTS, realtime, history, or billing.

Before changing mobile lesson behavior, read the desktop/CMS/backend lesson flow docs and inspect the existing desktop flow. Do not create new backend endpoints just because the mobile client does not yet mirror the existing contract.


## Confirmed manual tutor-message TTS contract

Manual tutor-message TTS playback is complete. Mobile uses the existing backend speech endpoint as a second client of the same product runtime:

```http
POST /api/audio/speech
```

The request is authenticated and reuses the existing bearer-token plus refresh-on-401 flow. Backend returns raw WAV bytes with `audio/wav` content type. Backend owns the speech provider, model, voice processing, WAV generation, rate protection, usage enforcement, and session validation. Flutter never calls OpenAI or another speech provider directly and contains no provider credentials. No backend deployment is claimed by this documentation update.

Manual tutor playback request context includes:

- Exact visible tutor message text.
- `purpose: lesson_chat_tts`.
- `speechVoice` from backend user settings.
- `speechSpeed` from backend user settings.
- Study-language ID, English name, native name, and code.
- Active backend lesson session ID.

The mobile TTS request does not send tutor profile, persisted tutor-message ID, message kind, provider model, provider instructions, or requested output format. Do not duplicate the full JSON schema in additional documents.

Binary response boundaries:

- Mobile uses a separate binary response path; existing JSON API methods remain unchanged.
- Successful WAV data is retained as bytes and is not decoded as UTF-8.
- Empty audio and unsupported response content types are rejected safely.

Playback and UI boundaries:

- Mobile uses `just_audio`; the pubspec constraint is `^0.9.42`, and the verified resolved version is `0.9.46`.
- Playback is wrapped behind a focused service/adapter so tests do not require the platform plugin.
- Only one `AudioPlayer` is active for the lesson screen.
- Play voice is available only for tutor messages, including opening and older tutor messages.
- Learner messages, Translation text, and Feedback sections do not receive TTS controls.
- First playback downloads WAV bytes and caches a temporary WAV file for the current lesson screen; replay uses the cached file without another backend request.
- Tapping the same playing message stops it, starting another tutor message stops previous playback, and duplicate generation requests for the same loading message are prevented.
- Loading is shown only for the selected tutor message, the control changes to Stop while playback is active, playback errors are learner-safe and retryable, and `LessonTutorStatus.speaking` is driven by actual audio playback.
- No GIF asset switching was added.

Temporary-file and lifecycle boundaries:

- The audio cache is temporary and scoped to the active lesson screen.
- Temporary WAV files are cleaned during screen/session cleanup.
- Playback stops before confirmed abandonment, Finish, Summary navigation, screen disposal, and app backgrounding.
- Playback does not automatically resume.
- Choosing Stay in the leave confirmation does not abandon the lesson.
- No persistent audio cache or background playback was added.

Lesson boundaries:

- TTS does not create or persist lesson messages and does not require tutor-message persistence.
- TTS does not increment `learnerTurnCount` or `validTurnCount`.
- TTS does not change Hint, Translation, Feedback, abandonment semantics, Finish payload, Summary, lesson progression, or Premium decisions.
- TTS remains available while the transcript is visible and is not added to the Summary screen.

TTS error boundaries:

- Authentication failures use the existing authentication-required flow.
- Terminal-session responses use existing session-ended handling.
- HTTP 429 is temporary voice unavailability.
- Invalid request, provider, timeout, service, network, empty-audio, and unsupported-content failures are learner-safe and retryable.
- Raw response bodies, provider details, tokens, URLs, and stack traces are not exposed.

## Confirmed learner microphone recording and speech-to-text contract

Learner microphone recording and speech-to-text are complete. Mobile uses the existing backend transcription endpoint as a second client of the same product runtime:

```http
POST /api/audio/transcribe
```

The request is authenticated and reuses the existing bearer-token plus refresh-on-401 flow. The request is `multipart/form-data`; the audio part name is `file`; and the WAV file is sent as `audio/wav`. Backend owns the transcription provider, model, language processing, usage protection, and session validation. Flutter does not call OpenAI or device-local speech recognition directly. No backend deployment is claimed by this documentation update.

Transcription request metadata includes:

- Study-language ID.
- English language name.
- Native language name.
- ISO language code.
- Lesson phase.
- Bounded transcription context.
- Active backend lesson-session ID.

For an English lesson, confirmed values are `targetLanguageId=en`, `targetLanguageName=English`, `targetLanguageNativeName=English`, and `targetLanguageCode=en`. Do not duplicate the complete multipart schema in additional documents.

Audio capture and Android permission boundaries:

- Mobile uses `record` `^7.1.1`.
- Recording format is genuine WAV: PCM 16-bit, mono, 16 kHz.
- Android `RECORD_AUDIO` permission is required.
- `permission_handler` `^12.0.3` handles microphone permission status and Android settings recovery.
- No storage or background-microphone permission was added.
- The repository still has no iOS runner.

Recording validation and cleanup boundaries:

- Minimum usable duration is 500 ms.
- Maximum duration is 30 seconds.
- Mobile validates RIFF/WAVE structure, PCM format, mono, 16 kHz, 16-bit data, duration, and nonempty data before upload.
- Near-silent recordings are rejected locally.
- Invalid or silent audio is never sent to the backend.
- Temporary WAV files are deleted after success, failure, cancellation, lifecycle exit, or navigation.

Transcript and lesson boundaries:

- A valid transcript is inserted into the existing composer and remains editable.
- Transcription never sends automatically; only the existing Send button creates the learner turn.
- If typed text already exists or changes during transcription, the learner chooses whether to replace it.
- Recording and transcription do not create lesson messages.
- Recording and transcription do not change `learnerTurnCount` or `validTurnCount`.

Permission, UI, and lifecycle boundaries:

- Normal denial returns the microphone to a retryable state, and a later tap performs a new permission check.
- Permanent denial shows an explicit Open Android settings action.
- Permission is rechecked after returning from Android settings, typed drafts remain preserved, and the learner does not need to restart the lesson.
- The microphone button changes to Stop during recording.
- Manual Stop immediately starts validation and transcription.
- Recording stops automatically at 30 seconds.
- Tutor TTS stops before recording begins.
- Recording is cancelled and cleaned up before Leave, Finish, Summary, navigation, disposal, or app backgrounding.
- Recording does not automatically resume.

Transcription error boundaries:

- Authentication, session-ended, invalid recording, rate limit, service unavailable, timeout, network failure, and malformed response remain distinct internal result categories.
- Learner-facing errors are short and safe.
- Network failures return the microphone to a retryable state.
- Raw provider responses, tokens, audio contents, and technical exceptions are not shown.

Explicit out-of-scope items for this milestone: automatic sending after transcription, continuous listening, Conversation mode, realtime or streaming transcription, background recording, waveform visualization, learner recording playback, local device speech recognition, and iOS implementation.

## Error handling expectations

Backend should provide stable error codes for:

- Unauthenticated session.
- Expired session.
- Account disabled.
- Subscription inactive.
- Usage limit exceeded.
- Lesson access denied.
- Unsupported audio format.
- Upload too large.
- Rate limit exceeded.
- Backend processing unavailable.

Mobile should map stable backend codes to user-friendly UI states.
# Achievements V1 data foundation

Production backend baseline: `0.1.35-backend.125`. Mobile reads `GET /api/me/achievements` through the existing authenticated session and refresh-on-401 flow. The backend owns achievement definitions, eligibility, unlock dates, progress, study-language scope, and the selected Home items. This Mobile slice provides models, safe parsing, and service access only: it adds no UI, Home badges, navigation, images, assets, or client-side achievement calculation/selection.
