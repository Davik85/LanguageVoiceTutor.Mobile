# Android-First Plan

## Approach

Planning checkpoint: 2026-08-31. The current Mobile source and Google Play Internal-testing build are `0.1.0+8` / versionCode 8 for package `com.languagevoicetutor.mobile`. Production backend `0.1.35-backend.145` has Restore Credentials enabled with its applied foundation migration and live Digital Asset Links association. Password authentication remains authoritative; Restore Credentials is an additive convenience path that never transfers an existing refresh token, creates only the normal new backend session after verification, is suppressed by logout, and is removed with its public-credential and ceremony state during account anonymization. FlutterSecureStorage session state is device-bound and excluded from Android cloud backup, device transfer, and legacy full backup.

Restore Credentials is complete for the tested Android/Google Play account-session path. A 2026-08-31 production-like transfer from a Play-installed v8 source with a registered credential to a clean Android target automatically authenticated Orralen/Language Voice Tutor without email/password entry and launched working lessons. This does not prove Google Play Billing purchase restoration, refunds, pending purchases, other billing lifecycles, a Production rollout, or general public Android availability.

## Interface localization and Android first-run defaults — implemented

The Android-first client selects fourteen Flutter interface locales: `en`, `ru`, `es`, `fr`, `de`, `it`, `pt-PT`, `bg`, `hr`, `sr-Latn`, `pl`, `ja`, `ko`, and `ar`. Each selectable catalog has 453 messages. Generic `pt` and `sr` are generated fallback variants, so `gen-l10n` contains 16 variants without expanding the selectable set. `e6b3b8c` added Croatian, Serbian, and Polish; `cd799c3` added Japanese, Korean, and Arabic.

`studyLanguage` controls lesson, transcription, and tutor-audio behavior; `nativeLanguage` controls translation; `explanationLanguage` controls the Flutter interface. The fixed-LTR shell is deliberate for all locales, including Arabic localized text. It keeps physical navigation and screen geometry consistent rather than globally mirroring the UI.

At startup, the ordered Android preferred-locale list supplies independent interface and native defaults, each falling back to English. Splash/Login use the device-derived interface before authentication. Backend `UserSettings` override it after authentication: existing sessions and existing-account login load saved `explanationLanguage` without a PUT. New registration fetches created settings once and updates only native and explanation language, preserving study language, speech voice/speed, conversation mode, tutor, and level. Follow-up settings failures do not fail login/registration or retry registration. No first-install marker, backend contract, migration, dependency, Gradle/Kotlin, or backend deployment was required. Google Play installation and system-language startup/default behavior passed physical Internal testing; the expanded locale-specific clean-install matrix remains listed separately in the testing checklist.

## Backend-owned localized lesson setup — complete

Commit `01d6226` (`Use backend localized lesson setup in Mobile`) consumes the nullable response-owned `localizedSetup` projection from lesson start; it does not consume authored CMS `setupLocalizations`. A non-English projection is accepted only with a matching language, nonblank template, exact complete stable-ID context-title coverage, and the exact expected placeholders. Valid setup renders only the user display name and preserves the backend template's formatting. Invalid or missing setup falls back to the packaged target-language copy, never canonical English. Context titles resolve through stable IDs for numeric, local, canonical, and alias selections, with no mixed-language confirmation. English remains independent and canonical. Owner manual Android verification of localized new-lesson opening and confirmation succeeded. No backend deployment, migration, Play store package, signing, upload, or release was part of this client rollout.

Lesson-selection display localization is isolated from the backend contract. Navigation uses stable topic IDs, unknown catalog IDs fall back to canonical text, and `LessonStartSelection` reconstructs canonical data from the authoritative catalog using stable IDs. Session payloads and runtime scenario keys remain identical across all selectable interface locales; `scenarioKey` remains `lessonContentId`, including Free Conversation. The accepted flow remains **Home -> Choose Topic -> Choose Situation -> Lesson**, with level selection only in **Settings -> Learning**.

## Progress data foundation

The Android-first client consumes backend `0.1.35-backend.124` Progress V1 through authenticated `GET /api/me/progress`. It does not calculate Progress from History; backend UTC and completion rules remain authoritative.

The Android client now exposes a Home Progress entry and scrollable learner-facing Progress screen using the existing theme and no chart package. Backend daily activity is rendered as accessible compact day cells; official calculations remain backend-owned. Broader visual polish is separate work.

The mobile app will be built with Flutter using an Android-first delivery path. Android is the first target for implementation, QA, billing integration, and release preparation. iOS should remain a future-compatible consideration, but iOS project files should not be created during the docs-only foundation phase.

## Study-language parity status

The lesson flow carries English, French, German, Portuguese, Spanish, and Italian through deterministic tutor setup text, canonical scenario selection, known-context openings, local Hints, backend lesson requests, transcription, and Lesson Chat/Conversation TTS. One Mobile study-language definition supplies the exact ID, English name, native name, BCP-47/transcription code, tutor instruction name, and language-lock name. Native/translation and interface languages stay separate. CMS canonical IDs and English semantic metadata are preserved, and CMS/backend still own tutor methodology and generated replies. The fourteen-locale interface implementation described above does not change this six-language study-language behavior. This Mobile-only work required no backend deployment.

## Why Android first

- The Google Play billing bridge is implemented and controlled Billing, RTDN, and reconciliation are enabled for the approved Internal-testing context; the next release action is the read-only public-runtime/test-only configuration gate.
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

The current green baseline includes completed backend-owned Lesson History (data foundation, Home entry, recent list, and detail flow), the production-verified Android text lesson loop, completed Hint and lesson abandonment, Translation, learner Feedback, tutor-message TTS, learner speech-to-text, Mobile voice/Conversation mode flows, authentication/session resilience, Lesson Chat avatar synchronization, authenticated Feedback & reports submission, local Practice reminders, fourteen selectable interface locales, a backend-owned Progress screen, and the controlled Google Play Premium flow. Settings has stable **Account**, **Learning**, and **Audio** areas. **Settings -> Learning** reads and saves backend-owned account `CurrentLevel` through `/api/me/settings`, using `lessonLevels` for Mobile labels and mapping. Home **Start lesson** loads that setting and opens Choose Topic directly, followed by Choose Situation and Lesson; Choose Level is removed from the normal flow. CMS-published level profiles remain authoritative for lesson behavior and timing. No backend deployment was required for this Mobile navigation cleanup because backend release `0.1.35-backend.116` already provided the required `CurrentLevel` settings contract. The owner physically verified the saved-level lesson-start flow on an Android phone. History and Progress are complete; the recent list of up to 50 sessions is never used for official totals or streaks. Controlled Google Play Billing, RTDN, and reconciliation are active only for the approved Internal-testing context and now require a read-only public-runtime/test-only configuration review before any public decision. Analytics, crash reporting, and final store release remain separate work.

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

- Complete: login/session flow against the existing backend account system.
- Complete: secure token/session storage with resilient refresh handling that preserves tokens on temporary failures and clears them only for proven invalid sessions.
- Fetch `/api/me`, account settings, and backend-owned subscription/entitlement status.
- Complete: logout and invalid-session handling; temporary Splash session-check failures remain retryable rather than automatically routing to Login.
- Display Premium/subscription status only from backend responses; do not compute entitlement locally.
- Continue from the green Settings baseline with small, mobile-only changes unless an API gap is explicitly approved.
- Completed within this phase: Settings selected tutor persistence, product-friendly catalog labels, friendly language labels, Home title/logo polish, soft colored lesson-selection cards, and the Settings **Feedback & reports** card using `POST /api/me/feedback-reports`.

### Desktop parity guidance

The reviewed Windows desktop client walkthrough presentation remains a product source model, while Mobile uses phone-first layouts and backend account settings. Mobile learner level is changed in **Settings -> Learning**. Normal lesson start loads backend `UserSettings.currentLevel`, resolves it through `lessonLevels`, and follows `Home -> Choose Topic -> Choose Situation -> Lesson`; Choose Level is no longer a normal-flow step.

### Phase 3: Lessons and progress

- Complete and physically verified on Android phone: Home Start lesson loads backend `UserSettings.currentLevel`, resolves it through the centralized `lessonLevels` collection, and follows **Home -> Choose Topic -> Choose Situation -> Lesson**. The obsolete Choose Level screen, `/choose-level` route, and import were deleted; `ChooseLevelScreen` and `choose_level_screen.dart` no longer exist.
- Complete and production-verified: Android text lesson foundation, including authenticated session start, CMS/backend runtime opening, scenario selection, text conversation, message persistence, Finish, and backend-owned summary display.
- Complete and production-verified: Finish plus backend summary flow against production backend `0.1.35-backend.112` or later.
- Backend `.112` is the verified dependency because it supports nested Responses API output extraction for persisted learner summaries; `.111` is the previous rollback backend.
- Complete: real mobile Hint flow through `POST /api/lesson-chat/hint`, with backend-owned Hint behavior, local pre-context guidance, CMS-owned first roleplay example Hint support, inline non-transcript UI, existing auth refresh behavior, and no changes to lesson counters, Finish payload, or Summary.
- Complete in functional commit `1a392dc`: confirmed mobile lesson abandonment through `POST /api/lesson-sessions/{sessionId}/abandon` with no request body, shared visible Back/Android system Back leave confirmation, no silent Finish, no Summary generation, duplicate-abandon prevention, retryable network/backend failure behavior, and existing auth refresh behavior.
- Complete: real per-message learner Feedback through `POST /api/lesson-chat/feedback`, with the existing full LessonChatRequest contract, backend-owned correction behavior, persisted learner-message GUID requirement, expandable non-transcript per-message UI, per-message caching, study-language output, and no changes to counters, Finish, Summary, Hint, Translation, abandonment, progression, or entitlement.
- Complete: manual tutor-message TTS playback through `POST /api/audio/speech`, raw WAV binary handling, temporary per-screen caching, one active lesson `AudioPlayer`, learner-safe retryable errors, and no changes to counters, Finish, Summary, Hint, Translation, Feedback, abandonment, progression, or entitlement.
- Complete: learner microphone recording and speech-to-text through `POST /api/audio/transcribe`, authenticated multipart WAV upload, Android `RECORD_AUDIO` permission, local WAV/duration/silence validation, editable transcript insertion, no automatic send, and no changes to lesson counters or message creation. Lesson Chat and Conversation mode share the same Mobile transcription request builder; transcription always uses the selected study language definition (ID, English name, native name, transcription language code), not native or explanation language.
- Complete: Lesson Chat avatar header fills the full 240-pixel header, uses top-centered cover layout, removes the washed-out radial overlay, and keeps Back, Finish, level/topic, tutor status, and Conversation mode controls above the avatar. Tutor playback state synchronization is substantially better on a physical Android device; broader repeated testing remains useful and all timing edge cases should not be declared fully stabilized.
- Complete: Lesson History models and authenticated service (`4d531e3`), Home entry and backend-ordered recent list (`2c88944`), and on-demand Lesson details (`a200641`), including focused and full automated verification.
- Keep pending: realtime/continuous voice conversation, the read-only public-runtime/test-only configuration gate and any concrete follow-up it identifies, analytics, crash reporting, and the separately approved final Production release decision. Physical Internal testing across five Samsung and Huawei devices, including lifecycle, temporary-network-loss, and microphone-permission recovery, is complete; further targeted device or network testing is needed only when a new concrete risk is identified. Progress uses the separate backend-owned aggregate endpoint; never derive official all-time totals or streaks from the History endpoint, which currently returns up to 50 recent sessions. No backend, Desktop, CMS, website, billing, voice-provider, transcription-provider, semantic resolver, TTS, or database migration changes were made for the saved-level Mobile cleanup.
- Lesson runtime foundation must not add OpenAI calls from mobile and must not include client-owned tutor methodology or local summary generation.


### Current lesson-runtime boundary

Mobile now completes the Android text lesson loop through backend-owned summary display. The current lesson implementation mirrors the existing desktop/CMS/backend runtime instead of creating a separate mobile runtime. Mobile starts authenticated backend lesson sessions, loads CMS/backend scenario content, renders the lesson opening and suggestions, sends text practice replies through the existing lesson-chat route, persists messages under the backend session, waits for in-flight persistence before Finish, calls authenticated Finish, and reads the backend-owned learner summary.

Use this flow for mobile alignment:

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
PUT /api/me/lesson-sessions/{sessionId}/finish
GET /api/me/lesson-sessions/{sessionId}/summary
POST /api/lesson-sessions/{sessionId}/abandon
```

Current mobile session-start request shape:

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

Do not use `POST /api/me/lesson-sessions/{sessionId}/reply` for real lessons at this stage; it is a premature placeholder, not the real desktop lesson reply path. Do not call OpenAI directly from mobile and do not hardcode CMS lesson behavior in Flutter. CMS/backend published runtime content is the source of truth for tutor instructions, level behavior, prompt templates, scenario rules, wrap-up behavior, feedback guidance, and lesson methodology. Desktop is the reference client for orchestration, not the owner of lesson behavior.

Confirmed mobile lesson abandonment is complete. The backend stale active-session interval remains two minutes, no backend timeout change was made, and no mobile heartbeat was added. Normal confirmed Back navigation releases the session immediately; if the app is force-closed or terminated without confirmed leave, the existing backend timeout remains the fallback. Heartbeat or timeout reduction is optional future reliability work only if real user feedback requires it.

Explicit no-go items for future lesson work: no temporary mobile-only backend endpoints, no new safe/catalog endpoints for intermediate convenience, no duplicate mobile prompt/runtime system, no backend changes unless a real final shared lesson-runtime design is approved, no silent Finish from Back navigation, no Summary generation from ordinary leave, and no realtime/history/billing.

Before changing mobile lesson behavior, read the desktop/CMS/backend lesson flow docs and inspect the existing desktop flow. Do not create new backend endpoints just because the mobile client does not yet mirror the existing contract.


### Phase 4: Voice and conversation — partially complete

- Complete: Android recording permission handling for learner microphone transcription.
- Complete: backend voice upload to `POST /api/audio/transcribe` using authenticated multipart WAV and the existing multipart contract; no new backend endpoint, provider integration, or deployment requirement was added.
- Complete: shared Lesson Chat and Conversation mode transcription request building. During the first unresolved scenario-selection voice turn, Mobile sends a short exact-transcription context from visible runtime/CMS candidates; candidate titles come from current lesson runtime data, not hardcoded lists. During active roleplay, the selected lesson context is used as the transcription hint. If runtime context is unavailable, Mobile sends empty or minimal context rather than inventing lesson data.
- Complete: semantic scenario resolution remains unchanged. Numeric and exact-title matching still runs locally, unresolved first voice choices still use the existing backend semantic resolver, existing `published_context`, `free_context`, `clarify`, `unsafe`, and backend failure behavior remains unchanged, and translation remains a separate explicit `POST /api/translate` action.
- Complete: Conversation mode uses the same study-language definition and available lesson context as Lesson Chat.
- Complete: manual tutor-message TTS playback.
- Keep realtime/continuous voice conversation as future isolated work. Automatic message sending after speech recognition, tutor voice playback, tutor avatar changes, Conversation Mode, and recovery from temporary network loss are physically verified across the current five-device Internal testing pass; further targeted device or network testing is needed only when a new concrete risk is identified.

### Phase 5: Current post-v8 Google Play release path

The historical versionCode 5 controlled billing E2E proved purchase-sheet launch, backend verification, backend-owned Premium, accelerated renewal reconciliation, final expiry, return to Free, and restored new-purchase eligibility. VersionCode 8 is the current Play-distributed Internal-testing build; it includes signed-out password recovery and Restore Credentials. Restore Credentials is production-enabled on backend `.145` and its cross-device E2E is complete for the tested account/session path. Public Privacy, Terms, Seller/Company, Refund, Cancellation, AI & Data Disclosure, Availability, Pricing, and Support pages are published. Google Play Data Safety was re-audited and changes were submitted on 2026-08-30; the last verified Play state is changes under review, not completed review.

1. Documentation synchronization — complete.
2. Public legal/privacy/support synchronization — complete.
3. Data Safety re-audit/submission — complete; Google review pending.
4. Restore Credentials implementation and cross-device E2E — complete.
5. NEXT: perform the read-only public-runtime/test-only configuration gate. Review `TestPurchasesEnabled`, exact test-account/allowlist/test-only gates, enabled Google Play Billing/RTDN/reconciliation states and relevant live parameters, development/debug purchase controls, pending-payment, refund/voided-purchase/revoke, cancellation/expiry, and pending-refund-review assumptions, monitoring/log visibility, health checks, current rollback target, and operational rollback path. Do not flip a setting blindly; configuration changes require separately reviewed action and explicit owner approval.
6. Resolve only concrete issues found by that gate or Google review.
7. Select the Production candidate. Do not assume a new AAB is mandatory: if no Mobile artifact change is required, versionCode 8 may be selected from the Play library. If a code or bundle change is required, produce versionCode 9 or later and follow the normal build/sign/hash/Internal-testing/targeted-smoke path before a Production decision.
8. Run only the targeted Play-installed smoke justified by changes since the verified v8 state.
9. Present the final Production release summary with the candidate, countries/regions, Data Safety/review state, open risks, backend and Google Play Billing/RTDN/reconciliation monitoring, and rollback/recovery.
10. Obtain explicit owner approval before the separate irreversible/public Start rollout to production action. The first Production publication has no normal staged-rollout percentage control.
11. After publication, perform targeted production monitoring.

Notifications V1 is local-only: no Firebase, remote/server push, backend endpoint, push-token registration, remote provider, backend notification state, or background microphone behavior. Product settings enable reminders by default at device-local 09:00 and 20:00; learners can edit both times or disable all reminders. Android notification permission is still required. Explain the benefit and ask only after the learner sees the product experience, do not reprompt on every launch after denial, and offer Android settings recovery where practical. Do not request exact-alarm permission unless later investigation proves it necessary. Preserve device-local schedule semantics across timezone changes and restore reminders after reboot when Android requires it; local reminders are not synchronized backend account state and cannot always be suppressed after a lesson on another device.

The Premium UI and Google Play billing bridge foundation are implemented, and controlled Internal-testing runtime is enabled for the approved license-test context. A local button, purchase callback, or verified Play result never grants Premium; Mobile displays backend `SubscriptionStatus`. Google Play maps to the same provider-neutral Premium as Paddle, trial, and manual-admin. Controlled purchase, reconciliation, and expiry are complete; broader lifecycle and public-rollout validation remain separate work.

Interface localization remains separate from the six study languages. Fourteen selectable interface locales are implemented: `en`, `ru`, `es`, `fr`, `de`, `it`, `pt-PT`, `bg`, `hr`, `sr-Latn`, `pl`, `ja`, `ko`, and `ar`. Localization applies only to interface presentation and never to AI replies, learner messages, backend-generated content, CMS identifiers, canonical scenario keys, internal IDs, or backend data. Arabic text is localized while the deliberate fixed-LTR shell remains unchanged; expanded locale-specific clean-install testing is separate quality evidence.

### Future coordinated ORRALEN rebrand

Language Voice Tutor remains the current Mobile product/application name; the public website's ORRALEN company/master branding does not mean this client is already rebranded. A future Mobile pass must first audit visible app branding, launcher and in-app logo assets, user-facing product/brand strings, Google Play presentation after the account/app transfer is stable, and future iOS presentation where applicable, then obtain separate approval before changing them.

That pass must preserve `com.languagevoicetutor.mobile`, backend API URLs, account/database identity, backend-owned Premium, signing and update continuity, subscriptions/base-plan IDs, and existing user History/Progress. Store-facing developer/product naming remains a separate reviewed step; visual branding must not create a new product/payment identity.

## Android implementation considerations

- Confirm minimum SDK and target SDK before creating project files.
- Keep backend base URL configurable by build flavor or environment file without secrets.
- Use Android secure storage for session material.
- Request microphone permission only for learner-initiated recording; no background microphone permission is used.
- Ensure network security permits HTTPS to production backend.
- Avoid storing sensitive provider or backend secrets in the app bundle.

## Local Android release signing

Android release signing has an external-keystore boundary: the upload keystore, its passwords, and its filesystem location stay outside Git and outside the app bundle. Copy `app/android/key.properties.example` to the ignored local-only `app/android/key.properties`, then set only these values: `storeFile`, `storePassword`, `keyAlias`, and `keyPassword`. Passwords are stored only in that ignored local file; never commit it, the keystore, or a private path.

Reproducible Android release signing is complete and verified. Release Gradle tasks fail closed when that file is missing, a required value is blank, or the configured keystore does not exist. Real `key.properties` and `local.properties` are ignored and untracked, private keystore files are not tracked, release builds explicitly use `signingConfigs.release`, and no debug-signing fallback was found. Debug and other non-release Gradle tasks do not require local release-signing configuration. Build the upload bundle with:

```bash
flutter build appbundle --release
```

Before upload, make two separate checks without exposing passwords.

1. Verify signature integrity:

```bash
jarsigner -verify -verbose:summary build/app/outputs/bundle/release/app-release.aab
```

Success requires `jar verified` in the output and must not contain `jar is unsigned` or `Not a signed jar file`.

2. Verify the embedded upload-certificate identity:

```bash
keytool -printcert -jarfile build/app/outputs/bundle/release/app-release.aab
```

The embedded certificate SHA-256 must be `36:40:5D:B4:56:47:B2:3C:68:EE:2D:AB:12:21:70:CA:DE:06:11:38:28:D9:9D:02:AB:62:54:33:E2:F5:0B:F7`. `jarsigner -strict` may report PKIX or self-signed-certificate errors for a valid self-signed Google Play upload certificate, so strict trust-chain output is not the project acceptance criterion and those warnings do not make the AAB invalid.

The existing verified output was exactly `app/build/app/outputs/bundle/release/app-release.aab` (191983753 bytes), SHA-256 `8C633D4689066BF0BE17B7B7AA266B4049750965092D5642C589DF5F6865A7ED`. It passes `jarsigner` verification. Its embedded upload certificate SHA-1 is `60:A8:13:5D:A6:B1:72:00:F2:6A:80:D2:F9:91:A9:01:CC:EB:F8:9B`, and its SHA-256 exactly matches the Google Play Console Upload key certificate. No new AAB was built during the release-signing audit. The current source and Play Internal-testing version are `0.1.0+8` / versionCode 8. A new upload is conditional on a real Mobile artifact change and must then use versionCode 9 or later; otherwise v8 may be selected from the Play library as the first Production candidate.

Google Play Console has `com.languagevoicetutor.mobile` registered, Android developer verification is confirmed, and no additional package or key registration is currently required. An older upload-key reset request may remain in console history, but it is not a current blocker because the working upload key matches the existing AAB certificate. Do not request another reset or cancellation without a new concrete reason.

The current Google Play Internal testing build passed physical testing on five Samsung and Huawei Android devices. Google Play installation, system-language startup and defaults, registration, restoration of backend-owned account settings/Progress/History, lesson scenario completion, Conversation Mode, speech recognition and automatic sending, tutor voice playback, Hints, Translation, Feedback, Summary, Progress, general and topic-specific achievements, study-language switching without mixed-language lesson openings, tutor avatar/voice changes, Settings History/Progress, password change/recovery, lifecycle recovery, temporary network loss/recovery, and microphone-permission denial/recovery worked as expected.

One bounded non-blocking pre-release polish item remains: after microphone permission is denied, Lesson Chat keeps the microphone-denied/open-settings warning visible. Before final public release, show it only when the learner attempts to use the microphone while permission remains denied. Do not treat this as a release-blocking functional defect.

## iOS posture

The repository should avoid Android-only architectural decisions where reasonable, but iOS should not drive V1 implementation. Do not create iOS project files until the team explicitly approves an iOS phase.
