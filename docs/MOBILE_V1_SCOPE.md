# Mobile V1 Scope

## Goal

Mobile V1 establishes an Android-first Flutter client for Language Voice Tutor that uses the existing production backend and shared product model. The current Android skeleton baseline is verified locally on Android Emulator, but the app remains placeholder UI only. It should let an existing or new user access the same account, subscription entitlement, usage limits, lesson history, progress, and AI tutor behavior used by the Windows desktop app.

## Current verified baseline

Latest known commit: `fcecef5` (`Fix mobile settings parity foundation`). The Flutter Android client under `app/` has a green Settings parity foundation baseline. Settings has stable visible **Account**, **Learning**, **Audio**, and **Backend diagnostics** sections, **Save settings** is visible and tested, user level is not in Settings, and **Open Lesson** remains a placeholder.

Verified commands from `app/`:

```bash
flutter clean
flutter pub get
flutter analyze
flutter test
flutter run -d emulator-5554
```

Verified Android build stack:

- Gradle 8.14
- Android Gradle Plugin 8.11.1
- Kotlin Gradle Plugin 2.2.20
- Java/Kotlin target 17

## Repository strategy

Language Voice Tutor Mobile is maintained as a separate repository from the desktop app and backend services.

This separation is intended to keep mobile concerns isolated:

- Flutter application structure and dependencies.
- Android platform configuration.
- Mobile UI and navigation.
- Audio capture and playback behavior.
- Store billing integration.
- Mobile QA and release workflows.

The repository must not duplicate backend business logic or become a fork of backend behavior.

## Desktop parity source model

The reviewed Windows desktop client walkthrough presentation is now a product reference source for mobile parity. Mobile must match desktop product logic, not desktop pixel layout, and should translate desktop screens into phone-first layouts. The desktop source flow is `Start -> Settings/preferences -> Choose level -> Pick topic -> Pick situation -> Practice`. Level selection must remain a separate lesson-start step before topic/situation selection, not a Settings field.

Study language, native language, and interface/explanation language are separate concepts. Supported study languages remain English, French, German, Portuguese, Spanish, Italian. Release-ready interface languages remain `en`, `es`, `fr`, `de`, `it`, `pt`, `ru`, `pl`, `ar`, `ja`, `ko`, `sr`, `hr`, and `bg`. The native/explanation language catalog is broader than both the study-language and interface-language catalogs.

Tutor profiles currently represented by desktop are Lana, Nelli, and David. Tutor choice is product-significant because it affects display name, profile/persona, and preferred voice behavior in lessons.

## Next implementation priority

The next safe implementation work should continue from the green Settings baseline. Keep slices small and mobile-only unless an API gap is explicitly approved. Billing, voice recording, TTS, analytics, crash reporting, Google Play Billing, Apple billing, and store release setup remain later phases.

This priority preserves the product boundary:

- Mobile is another client for the same Language Voice Tutor product.
- Mobile uses the same backend account as desktop.
- Premium entitlement remains backend-owned and backend-verified.
- Mobile does not call OpenAI directly.
- Mobile does not store secrets.
- Mobile does not decide Premium locally.

## In scope for Mobile V1

- Flutter Android-first client path.
- Authentication against the existing backend.
- Session persistence appropriate for mobile.
- Account profile and settings retrieval from backend APIs.
- Subscription and entitlement display based on backend state.
- Lesson access checks based on backend decisions.
- Lesson start, tutor message exchange, lesson history, and progress retrieval/update through backend APIs.
- Voice upload to backend for tutor processing.
- TTS playback using backend-provided responses or assets.
- Google Play Billing bridge where the mobile app receives a purchase token and sends it to the backend for verification.

## Out of scope for Mobile V1 foundation

- Implementing billing before backend auth/account/subscription-status integration is confirmed.
- Implementing voice, TTS, analytics, crash reporting, or store release setup before the backend account path is validated.
- Creating a mobile backend.
- Creating a mobile database as the source of truth.
- Client-side OpenAI calls.
- Client-side Premium, subscription, or lesson-access decisions.
- Storing provider secrets or signing secrets in the mobile app.
- Adding Google Play Billing runtime code before the skeleton and API contracts are confirmed.
- Creating Google Play or Apple App Store release metadata.

## Source of truth

The backend is the source of truth for:

- User identity and account state.
- Subscription status and entitlement level.
- Usage limits and remaining quotas.
- Lesson access decisions.
- Lesson history and progress.
- AI tutor orchestration and behavior.
- Billing verification and entitlement updates.

The mobile app may keep short-lived local state for responsiveness, but any authoritative state must be fetched from or reconciled with the backend.
