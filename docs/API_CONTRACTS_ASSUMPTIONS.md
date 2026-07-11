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
- Mobile sends backend language IDs, not display labels, for `nativeLanguage`, `studyLanguage`, and `explanationLanguage` even when Settings displays user-friendly labels.
- `studyLanguage`, `nativeLanguage`, and `explanationLanguage` remain separate backend fields and must not be collapsed into one language preference.
- Mobile may send `selectedTutorId` to `/api/me/settings` when the user chooses a valid tutor from `GET /api/tutor-options`.
- Mobile must not document fake local selected-tutor persistence as the source of truth.
- `speechVoice` remains separate from `selectedTutorId`.

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

Desktop parity source flow: `Start -> Settings/preferences -> Choose level -> Pick topic -> Pick situation -> Practice`. Level selection is part of lesson start and must not be a Settings field.

Mobile must follow the existing desktop/CMS/backend lesson flow as a second client. It must not invent a separate lesson runtime, call OpenAI directly, hardcode CMS lesson behavior in Flutter, or duplicate backend-owned prompt/runtime logic. Desktop is a reference client for orchestration, not the owner of lesson behavior. CMS/backend published runtime content is the source of truth for tutor instructions, level behavior, prompt templates, scenario rules, wrap-up behavior, feedback guidance, and lesson methodology.

Confirmed lesson-flow endpoints for mobile alignment:

```http
GET /api/me/lesson-access
GET /api/me/subscription-status
GET /api/me/lesson-content/scenarios/{scenarioKey}
POST /api/me/lesson-sessions
POST /api/lesson-chat/reply
POST /api/me/lesson-sessions/{sessionId}/messages
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
POST /api/me/lesson-sessions/{sessionId}/messages
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

Explicit no-go items for the next text-chat step:

- No temporary mobile-only backend endpoints.
- No new safe/catalog endpoints for intermediate convenience.
- No duplicate mobile prompt/runtime system.
- No backend changes unless a real final shared lesson-runtime design is approved.
- No voice, TTS, realtime, feedback detail, history, or billing.

Before changing mobile lesson behavior, read the desktop/CMS/backend lesson flow docs and inspect the existing desktop flow. Do not create new backend endpoints just because the mobile client does not yet mirror the existing contract.


## Voice upload and TTS expectations

Voice upload expectations:

- Mobile records audio using platform APIs.
- Mobile uploads audio to backend over HTTPS.
- Backend validates file type, size, duration, user entitlement, and usage limits.
- Backend handles speech recognition or AI tutor processing.

TTS expectations:

- Backend determines whether TTS is available for the user and lesson context.
- Backend returns a TTS result suitable for mobile playback.
- The result may be an authenticated URL, short-lived signed URL, streaming response, or binary payload; this must be confirmed before implementation.

Open questions:

- Required audio format and codec.
- Maximum upload size and duration.
- Retry and resumable upload policy.
- Whether uploads need pre-signed URLs.
- TTS response format and caching rules.

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
