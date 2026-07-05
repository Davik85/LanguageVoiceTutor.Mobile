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

The app remains a placeholder skeleton with Splash, Login, Home, Lesson, and Settings screens. No real backend auth, API integration, billing, voice, TTS, analytics, crash reporting, or store release setup has been implemented.

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

### Phase 2: Auth, account, and subscription-status shell — next

- Implement login/session flow against the existing backend account system.
- Implement secure token/session storage.
- Fetch `/api/me`, account settings, and backend-owned subscription/entitlement status.
- Add logout and expired-session handling.
- Display Premium/subscription status only from backend responses; do not compute entitlement locally.

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

### Phase 5: Google Play Billing bridge — later, after backend auth/account/subscription status

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
