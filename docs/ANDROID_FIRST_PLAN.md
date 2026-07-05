# Android-First Plan

## Approach

The mobile app will be built with Flutter using an Android-first delivery path. Android is the first target for implementation, QA, billing integration, and release preparation. iOS should remain a future-compatible consideration, but iOS project files should not be created during the docs-only foundation phase.

## Why Android first

- Google Play Billing is the first mobile billing bridge to plan.
- Android device audio capture and playback behavior should be validated early.
- Android release, signing, permissions, and QA can be stabilized before expanding to iOS.

## Planned phases

### Phase 0: Docs-only foundation

- Define scope and out-of-scope items.
- Record backend API assumptions.
- Record billing verification model.
- Record testing expectations.
- Do not create Flutter, Android, iOS, or runtime code files.

### Phase 1: Flutter skeleton

Only after open decisions are resolved:

- Create Flutter project structure.
- Add Android target only if approved.
- Configure linting and formatting.
- Add environment configuration for backend base URL without secrets.
- Add placeholder navigation and dependency structure.

### Phase 2: Auth and account shell

- Implement login/session flow against backend.
- Implement secure token/session storage.
- Fetch `/api/me` and settings.
- Add logout and expired-session handling.

### Phase 3: Lessons and progress

- Implement lesson access checks.
- Implement lesson start/resume.
- Implement tutor message exchange through backend.
- Implement lesson history and progress screens.

### Phase 4: Voice and TTS

- Implement Android recording permissions.
- Implement backend voice upload.
- Implement TTS playback using backend-provided responses.
- Add timeout, retry, and error-state handling.

### Phase 5: Google Play Billing bridge

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
