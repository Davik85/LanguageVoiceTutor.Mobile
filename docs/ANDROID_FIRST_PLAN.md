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

The current green baseline has `dart format --set-exit-if-changed lib test`, `flutter analyze`, and `flutter test` passing. Settings has stable **Account**, **Learning**, **Audio**, and **Backend diagnostics** sections, **Save settings** is visible and tested, and user level is not in Settings. Settings selected tutor persistence is complete through `/api/me/settings`: mobile reads and sends `selectedTutorId`, selection survives app/emulator restart, and tutor voice remains a separate setting. Tutor selection belongs in Settings, and Home no longer shows tutor diagnostics or an **Available tutors** card. Home now shows the provided Language Voice Tutor logo/title, preloads the logo during startup before Home is displayed, shows friendly signed-in or sign-in/sync account status, and uses **Start lesson** to open the completed lesson-start navigation skeleton before reaching the Lesson placeholder. The mobile logo source is `app/assets/brand/source/lvt-logo-source.png`; the app logo is `app/assets/brand/lvt-logo.png`; the loading screen shows only the centered logo; and Android launcher icons under `app/android/app/src/main/res/mipmap-*` are derived from the same provided source logo. Product-friendly situation labels are in place for all six topics, Travel includes Airport check-in, Hotel check-in, Asking for directions, Ordering transport, and Lost luggage, and situation labels no longer show `Placeholder:`. Settings language dropdowns show friendly names while still storing and sending backend IDs. Lesson runtime, voice recording, TTS playback, billing, analytics, crash reporting, and store release setup are not implemented by this documentation update.

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

### Phase 2: Auth, account, subscription-status, and settings baseline — in progress

- Implement login/session flow against the existing backend account system.
- Implement secure token/session storage.
- Fetch `/api/me`, account settings, and backend-owned subscription/entitlement status.
- Add logout and expired-session handling.
- Display Premium/subscription status only from backend responses; do not compute entitlement locally.
- Continue from the green Settings baseline with small, mobile-only changes unless an API gap is explicitly approved.
- Completed within this phase: Settings selected tutor persistence, product-friendly catalog labels, and friendly language labels.

### Desktop parity guidance

The reviewed Windows desktop client walkthrough presentation is a product source model. Mobile should preserve product flow and behavior while using phone-first layouts. The desktop source flow is `Start -> Settings/preferences -> Choose level -> Pick topic -> Pick situation -> Practice`; level selection remains a lesson-start step before topic/situation selection, not a Settings field.

### Phase 3: Lessons and progress

- Completed as UI-only foundation: lesson-start skeleton from Home to Choose Level, Choose Topic, Choose Situation, and Lesson placeholder.
- Next safe phase: Settings UX polish or lesson runtime planning by inspecting backend lesson/session APIs before implementation.
- Implement lesson access checks.
- Implement lesson start/resume only after the backend lesson/session contract is confirmed.
- Implement tutor message exchange through backend.
- Implement lesson history and progress screens.

### Phase 4: Voice and TTS — later, after lesson runtime planning

- Implement Android recording permissions.
- Implement backend voice upload.
- Implement TTS playback using backend-provided responses.
- Add timeout, retry, and error-state handling.

### Phase 5: Google Play Billing bridge — later, not the next safe phase

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
