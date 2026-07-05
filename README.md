# Language Voice Tutor Mobile

Language Voice Tutor Mobile is the Android-first Flutter client for the existing Language Voice Tutor product. This repository is intentionally separate from the desktop application and backend services so mobile-specific UI, platform integration, release cadence, and store workflows can evolve independently.

## Current repository state

This repository is in a docs-only foundation phase.

No Flutter application skeleton, Android project, iOS project, runtime code, backend code, local database schema, billing implementation, or store metadata has been added yet.

## Product direction

The mobile app will connect to the existing production backend at:

```text
https://api.languagevoicetutor.com
```

The mobile client must use the same backend account, subscription and entitlement state, usage limits, lesson history, progress records, and AI tutor behavior as the Windows desktop app.

## Architecture principles

- Android-first Flutter app, with iOS considered after the Android path is validated.
- Mobile app is a client only; it must not include backend runtime code.
- Backend remains the source of truth for accounts, sessions, entitlements, usage limits, lessons, progress, AI tutor orchestration, billing verification, and secrets.
- Mobile may cache client state for UX, but it must not become the source of truth for subscriptions, usage, lessons, or progress.
- All backend communication must use HTTPS.

## Explicit rules

The mobile app must not:

- Create or embed a mobile backend.
- Create a mobile database as the source of truth.
- Call OpenAI directly from the client.
- Make client-side Premium or entitlement decisions.
- Store OpenAI, Paddle, Google Play, Apple, JWT signing, or backend secrets.
- Add Google Play Billing runtime code during this docs-only phase.
- Add store release metadata during this docs-only phase.

## Foundation documents

- [Mobile V1 Scope](docs/MOBILE_V1_SCOPE.md)
- [API Contracts and Assumptions](docs/API_CONTRACTS_ASSUMPTIONS.md)
- [Android-First Plan](docs/ANDROID_FIRST_PLAN.md)
- [Google Play Billing Plan](docs/BILLING_GOOGLE_PLAY_PLAN.md)
- [Testing Checklist](docs/TESTING_CHECKLIST.md)

## Open decisions before Flutter skeleton

Before creating the Flutter skeleton, the team should confirm:

1. Final mobile auth flow and token/session storage requirements.
2. Exact backend endpoint paths, methods, request bodies, response bodies, and error codes.
3. Whether mobile needs refresh tokens, device registration, or session revocation behavior beyond the desktop model.
4. Minimum Android SDK, target Android SDK, Flutter channel/version, and supported device classes.
5. Audio recording format, upload size limits, timeout behavior, and retry policy.
6. TTS delivery mode: generated audio URL, streaming response, or binary payload.
7. Google Play Billing product IDs, backend verification endpoint contract, and entitlement reconciliation behavior.
8. Analytics, crash reporting, privacy consent, and logging requirements.
