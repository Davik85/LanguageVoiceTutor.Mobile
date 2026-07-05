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

Possible data fields:

- User ID.
- Email or display identifier.
- Account status.
- Locale or target language preferences.
- Tutor preferences shared with desktop.
- Subscription summary suitable for display.

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

Expected behavior:

- Lesson start creates or resumes a backend-owned lesson session.
- Tutor messages are sent to backend APIs.
- Backend orchestrates AI tutor behavior.
- Backend stores lesson history and progress.
- Mobile retrieves history and progress from backend APIs.

Possible operations:

- Start lesson.
- Send text message.
- Send voice message or reference an uploaded voice asset.
- Fetch lesson history.
- Fetch progress summary.
- Mark lesson milestones or completion when backend allows it.

The mobile app must not directly call OpenAI or embed tutor prompts/secrets that belong on the backend.

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
