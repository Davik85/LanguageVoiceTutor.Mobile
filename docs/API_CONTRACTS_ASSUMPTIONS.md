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
- No voice, TTS, realtime, hints, feedback, summary, history, or billing.

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
