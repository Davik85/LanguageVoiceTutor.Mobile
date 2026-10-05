# Android-First Plan

## Approach

Planning checkpoint: 2026-10-05. Current Mobile source/release commit is `bbd9702d626a99f760dbf2484f827e9ddac5c73e` with `0.1.0+13` / versionCode 13 for package `com.languagevoicetutor.mobile`, published as **Orralen - Language Voice Tutor**; target SDK remains 36. Google Play Console on 2026-10-05 confirmed version 13 / 0.1.0 as the latest Production working release, with 100% rollout and no unpublished changes at that checkpoint. This does not imply every installed user already has v13. The next future uploaded artifact must use versionCode at least 14. Production backend remains separate from this Mobile release; the earlier backend-owned multilingual Lesson Hint correction and its Android v9 verification required no Mobile Hint contract change. Password authentication remains authoritative; Restore Credentials is an additive convenience path that never transfers an existing refresh token, creates only the normal new backend session after verification, is suppressed by logout, and is removed with its public-credential and ceremony state during account anonymization. FlutterSecureStorage session state is device-bound and excluded from Android cloud backup, device transfer, and legacy full backup.

The public-v10 practice-reminder scheduling issue is closed by v11. Commit `0b1cecd21dde3c11bf25c7421007a4ce76baad10` replaces stable alarm IDs `41001` and `41002` without proactively cancelling existing reminders; disabling reminders or unavailable notification permission still cancels both. A first successful notification-permission grant reconciles immediately. Preference, initialization, permission, cancellation, and morning/evening scheduling failures emit stage-specific safe diagnostics; a `PlatformException` may add a bounded safe code, never message, details, stack trace, or private data. The notification icon is a release-retained, brand-derived monochrome small icon. Two-device release-APK checks confirmed rescheduling, expected Android alarms, actual delivery, and accepted icon presentation without the old update error. One inexact 13:19 reminder arrived around 13:22; scheduling remains `AndroidScheduleMode.inexactAllowWhileIdle`, without exact-time guarantees or an exact-alarm permission. The old Play-v10 root cause is not proven. Physical reboot and timezone behavior was not tested in this v11 check.

Restore Credentials is complete for the tested Android/Google Play account-session path. A 2026-08-31 production-like transfer from a Play-installed v8 source with a registered credential to a clean Android target automatically authenticated Orralen/Language Voice Tutor without email/password entry and launched working lessons. This does not prove Google Play Billing purchase restoration, refunds, pending purchases, or other billing lifecycles; public Android availability was established separately on 2026-09-03.

## Current Android voice, Settings, and Home behavior (2026-10-05)

The canonical selectable Android speech voices are exactly `alloy`, `ash`, `ballad`, `coral`, `echo`, `sage`, `shimmer`, `verse`, `marin`, and `cedar`. Supported IDs normalize to lowercase. Legacy `nova`, `onyx`, and `fable`, blank values, and unknown `speechVoice` values normalize using the effective tutor: David -> `cedar`; other tutors -> `coral`. Unsupported stale values are never exposed as temporary dropdown choices.

Android product `speechSpeed` is fixed at `1.0`: the learner speed control is removed, parsing and serialization normalize the retained `UserSettings`/API JSON compatibility field to `1.0`, and tutor speech requests always use `1.0`. `ConversationModeEnabled` is fixed `true` and remains an API/UserSettings compatibility field; its learner enable/disable toggle is removed. The entire **Audio** card is removed from **Settings -> Profile**, which now presents **Account -> Learning -> Save settings**. Conversation Mode remains available from the lesson UI and is not gated by the removed settings flag.

Inside the existing Home account summary card, compact tappable **Current level** and **Study language** shortcuts display backend settings using the existing localized level and language names. Both open **Settings -> Profile**; returning refreshes the Home summary. Temporarily unavailable settings show neutral placeholders while the rest of Home remains usable. Lesson start still makes its own authoritative `fetchUserSettings` call; the cached Home summary is not lesson-start authority.

Functional commit `43743f45adc6408b8e74270b16cde937da70e776` (`Improve lesson tutor speech reliability`) gives `POST /api/audio/speech` one 25-second Mobile client budget, including response headers and WAV bytes. Ordinary JSON, other binary requests, and learner transcription retain the existing 10-second default timeout; no Mobile speech retry is added. The initial tutor setup message is silently preloaded into the normal temporary WAV cache, without autoplay or background-preload loading/error state. Manual Play reuses completed preload audio or awaits the same in-flight request without duplicating it; failed silent preload permits a fresh manual request. Known and custom scenario openings honor Lesson Chat Auto-play, with Conversation Mode caller suppression preventing duplicate automatic playback. Exact visible tutor text and `lesson_chat_tts` purpose are preserved.

Production backend is separately deployed as `0.1.35-backend.166`, with `0.1.35-backend.165` as rollback; backend `.166` source commit is `d49a8eb039f3ec556057226d957853bda77daf2f`. `.165` added bounded recovery from an Attempt-1 first-audio startup stall; `.166` added bounded recovery from a transient pre-audio `WebSocketException`. Non-streaming rendering allows at most 3 attempts sharing the same original 20-second overall speech budget, never reset; only Attempt 1 has the 8-second startup deadline. No server retry follows audio/PCM, client cancellation, or overall timeout, and streaming remains single-attempt. Server-side Lesson Chat TTS and Conversation Mode TTS remain `gpt-realtime-2.1-mini`. Provider/model/rendering behavior, configuration, and OpenAI credentials remain backend-owned and are not part of the Mobile artifact. Mobile adds no client-side provider retry, provider credentials, or model configuration. Full product Realtime mode is not restored.

After backend `.166` deployment, physical-device testing of the affected Android lesson/TTS flow confirmed the previously failing first-message playback and subsequent lesson/topic openings working. That check was not a Play-installed v13 smoke. One Play-installed v13 physical smoke remains pending after store propagation; post-release billing lifecycle monitoring remains separate.

## Interface localization and Android first-run defaults — implemented

The Android-first client selects fourteen Flutter interface locales: `en`, `ru`, `es`, `fr`, `de`, `it`, `pt-PT`, `bg`, `hr`, `sr-Latn`, `pl`, `ja`, `ko`, and `ar`. Each selectable catalog has 454 messages, including the localized authentication welcome message. Generic `pt` and `sr` are generated fallback variants, so `gen-l10n` contains 16 variants without expanding the selectable set. `e6b3b8c` added Croatian, Serbian, and Polish; `cd799c3` added Japanese, Korean, and Arabic.

`studyLanguage` controls lesson, transcription, and tutor-audio behavior; `nativeLanguage` controls translation; `explanationLanguage` controls the Flutter interface. The fixed-LTR shell is deliberate for all locales, including Arabic localized text. It keeps physical navigation and screen geometry consistent rather than globally mirroring the UI.

At startup, the ordered Android preferred-locale list supplies independent interface and native defaults, each falling back to English. Splash/Login use the device-derived interface before authentication. Backend `UserSettings` override it after authentication: existing sessions and existing-account login load saved `explanationLanguage` without a PUT. New registration fetches created settings once and updates only native and explanation language, preserving study language, normalized speech voice, tutor, and level; audio compatibility fields use the fixed Android defaults described above. Follow-up settings failures do not fail login/registration or retry registration. No first-install marker, backend contract, migration, dependency, Gradle/Kotlin, or backend deployment was required. Google Play installation and system-language startup/default behavior passed physical Internal testing; the expanded locale-specific clean-install matrix remains listed separately in the testing checklist.

## Backend-owned localized lesson setup — complete

Commit `01d6226` (`Use backend localized lesson setup in Mobile`) consumes the nullable response-owned `localizedSetup` projection from lesson start; it does not consume authored CMS `setupLocalizations`. A non-English projection is accepted only with a matching language, nonblank template, exact complete stable-ID context-title coverage, and the exact expected placeholders. Valid setup renders only the user display name and preserves the backend template's formatting. Invalid or missing setup falls back to the packaged target-language copy, never canonical English. Context titles resolve through stable IDs for numeric, local, canonical, and alias selections, with no mixed-language confirmation. English remains independent and canonical. Owner manual Android verification of localized new-lesson opening and confirmation succeeded. No backend deployment, migration, Play store package, signing, upload, or release was part of this client rollout.

Lesson-selection display localization is isolated from the backend contract. Navigation uses stable topic IDs, unknown catalog IDs fall back to canonical text, and `LessonStartSelection` reconstructs canonical data from the authoritative catalog using stable IDs. Session payloads and runtime scenario keys remain identical across all selectable interface locales; `scenarioKey` remains `lessonContentId`, including Free Conversation. The accepted flow remains **Home -> Choose Topic -> Choose Situation -> Lesson**, with level selection only in **Settings -> Learning**.

## Progress data foundation

The Android-first client consumes backend `0.1.35-backend.124` Progress V1 through authenticated `GET /api/me/progress`. It does not calculate Progress from History; backend UTC and completion rules remain authoritative.

The Android client now exposes a Home Progress entry and scrollable learner-facing Progress screen using the existing theme and no chart package. Backend daily activity is rendered as accessible compact day cells; official calculations remain backend-owned. Broader visual polish is separate work.

The mobile app will be built with Flutter using an Android-first delivery path. Android is the first target for implementation, QA, billing integration, and release preparation. iOS should remain a future-compatible consideration, but iOS project files should not be created during the docs-only foundation phase.

## Study-language parity status

The lesson flow carries English, French, German, Portuguese, Spanish, and Italian through deterministic tutor setup text, canonical scenario selection, known-context openings, local Hints, backend lesson requests, transcription, and Lesson Chat/Conversation TTS. One Mobile study-language definition supplies the exact ID, English name, native name, BCP-47/transcription code, tutor instruction name, and language-lock name. Native/translation and interface languages stay separate. CMS canonical IDs and English semantic metadata are preserved, and CMS/backend still own tutor methodology and generated replies. The fourteen-locale interface implementation described above does not change this six-language study-language behavior. This Mobile-only work required no backend deployment.

The later multilingual Lesson Hint correction is backend-owned and complete in production backend `.156`: Hint output follows the selected study language, deterministic fallback supports all six study languages, and missing or unknown ids retain the English default. Android v9 production smoke passed on several non-English languages, including repeated Hint requests. Mobile's six-language request contract was preserved unchanged.

## Why Android first

- The Google Play billing bridge is implemented; Billing, RTDN, and reconciliation remain enabled in public Production. Post-release work is lifecycle monitoring, not a pre-public configuration gate.
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

The current baseline includes completed backend-owned Lesson History, Android lesson/voice flows, authentication/session resilience, Feedback & reports, the Notifications V1 foundation, localization, and backend-owned Progress. Settings has stable **Profile**, **Lessons**, and **App** areas; Profile edits the backend-owned learner display name, and Home follows **Choose Topic -> Choose Situation -> Lesson** using the backend-owned selected level. The public-v10 reminder scheduling issue is closed by v11 with the bounded implementation and two-device delivery evidence above. Google Play Billing, RTDN, and reconciliation are active in public Production. Analytics, crash reporting, future artifact changes, and post-release lifecycle monitoring remain separate work.

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
- Complete in v11: optional Unicode-letters-only registration display name and editable learner display name in **Settings -> Profile**, persisted through the existing backend-owned `/api/me/settings` contract. A blank value clears the name; successful saves use returned backend settings and failed saves restore the last confirmed values. Email and account identity do not change.

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
- Keep pending: realtime/continuous voice conversation, analytics, crash reporting, future artifact changes, and remaining post-release Google Play lifecycle observations. Physical Internal testing across five Samsung and Huawei devices, including lifecycle, temporary-network-loss, and microphone-permission recovery, is complete historical pre-release evidence; further targeted device or network testing is needed only when a new concrete risk is identified. Progress uses the separate backend-owned aggregate endpoint; never derive official all-time totals or streaks from the History endpoint, which currently returns up to 50 recent sessions. No backend, Desktop, CMS, website, billing, voice-provider, transcription-provider, semantic resolver, TTS, or database migration changes were made for the saved-level Mobile cleanup.
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

### Phase 5: Current Google Play Production path

Current Mobile source/release commit is `bbd9702d626a99f760dbf2484f827e9ddac5c73e` with `0.1.0+13` / versionCode 13 for package `com.languagevoicetutor.mobile`, published as **Orralen - Language Voice Tutor**; target SDK remains 36. Google Play Console on 2026-10-05 confirmed version 13 / 0.1.0 as the latest Production working release, with 100% rollout and no unpublished changes at that checkpoint. This does not imply every installed user already has v13. The next future uploaded artifact must use versionCode at least 14.

The verified v13 AAB at `app/build/app/outputs/bundle/release/app-release.aab` is 196205009 bytes with SHA-256 `22779E8FAB838450A487B34B6C45C1A3108DCB11AC6DB75942672D7C1F4F8A8B`. `jarsigner` reported `jar verified`; signer: `CN=Language Voice Tutor, OU=Mobile, O=Language Voice Tutor`. The embedded upload certificate SHA-1 is `60:A8:13:5D:A6:B1:72:00:F2:6A:80:D2:F9:91:A9:01:CC:EB:F8:9B`, and SHA-256 is `36:40:5D:B4:56:47:B2:3C:68:EE:2D:AB:12:21:70:CA:DE:06:11:38:28:D9:9D:02:AB:62:54:33:E2:F5:0B:F7`, matching the known Google Play upload certificate.

Recorded v13 release preparation passed on clean, synchronized source: `flutter clean`, `flutter pub get`, `flutter gen-l10n`, `flutter analyze`, `flutter test --concurrency=1`, `flutter build appbundle --release`, AAB SHA-256 verification, `jarsigner` verification, upload-certificate verification, and final clean repository / `HEAD == origin/main` verification. No verified final full-suite test count is supplied, so none is asserted. These are recorded release results, not commands rerun by this documentation update.

After backend `.166` deployment, physical-device testing of the affected Android lesson/TTS flow confirmed the previously failing first-message playback and subsequent lesson/topic openings working. That check was not a Play-installed v13 smoke. One Play-installed v13 physical smoke remains pending after store propagation; post-release billing lifecycle monitoring remains separate.

### Historical Android v12 Production checkpoint

Historical Android `0.1.0+12` / versionCode 12 used source `a75f8b308c400b895a2a708bc9320f208ae033f7` and target SDK 36. Its AAB at `app/build/app/outputs/bundle/release/app-release.aab` was 196197868 bytes with SHA-256 `C93EFA93B205BC32E8CCFCA5F84494ABB1B235B9F410EECD3804F08D107CEDCB`; signing, version, hash, `jarsigner`, and upload-certificate verification passed. V12 was confirmed active in Production before the v13 release was created and is the Production predecessor to v13.

Recorded v12 release verification: before the AAB build, `flutter analyze` and the full Flutter test suite passed after the stale registration expected payload was corrected to include the already-existing `displayName` field. Release preparation used clean, synchronized source before build/upload, and the final repository source check was clean. No exact full-suite test count is asserted.

### Historical Android v11 and earlier Production checkpoints

At the historical v11 public Production checkpoint (2026-09-27), source was `0.1.0+11` / versionCode 11 at `1113a4c09ee75021a435f67dceee8b7b55ba1160`. Google Play accepted and approved versionCode 11 as the active Production release on 2026-09-27. The historical release `app/build/app/outputs/bundle/release/app-release.aab` was 196486143 bytes with SHA-256 `A47ED1DD989D1AF87B166C73103B508227698533675625F06FA736EF94E9FA98`; target SDK remains 36. Release preparation passed `flutter analyze` with no issues, 145 targeted tests, `flutter build appbundle --release`, and `git diff --check`, with a clean repository and `HEAD == origin/main` before publication. No separate v11 `jarsigner` or `keytool` verification is claimed.

At the historical 2026-09-20 v10 checkpoint, source was `0.1.0+10` / versionCode 10 at `3389786c16d676dae2a66a9cdf73367780babcad`. Google Play accepted and published version 10 on 2026-09-20. Its signed AAB was 196468474 bytes with SHA-256 `45B2552ACE707A94772AC0739BF7B6E8632A8C994A54D33C3759DDF79B842C0C`; `jarsigner` reported `jar verified`, its embedded upload-certificate SHA-256 was `36:40:5D:B4:56:47:B2:3C:68:EE:2D:AB:12:21:70:CA:DE:06:11:38:28:D9:9D:02:AB:62:54:33:E2:F5:0B:F7`, and target SDK was 36. Versions 8 and 9 remain historical public releases; their dated validation evidence is not relabeled as v10 evidence.

The final v10 artifact was built only after clean repository verification, `flutter clean`, `flutter pub get`, `flutter gen-l10n`, `flutter analyze`, the full Flutter suite with concurrency 1, a clean-source check, `flutter build appbundle --release`, Android versionName/versionCode verification, SHA-256 calculation, `jarsigner` verification, upload-certificate verification, and final clean repository / `HEAD == origin/main` verification. The release record does not assert an unverified total Flutter test count.

V10 includes the Mobile-only authentication onboarding update from `2457f25f2928b95edba5179aa26e4131db60de56` (`Improve auth onboarding screen`): Login/Register uses the new Orralen hero artwork over the existing application gradient with a soft fade, removes the redundant auth AppBar title and old separate Login Orralen logo/wordmark block, and retains the localized three-sentence welcome copy plus authentication, registration, password recovery, scrolling, and keyboard behavior. No authentication backend-contract change is implied.

The earlier `fefbac3f366920b980f831ddd55c18e2734471a0` correction remains authoritative for the phase boundary: only initial `setupContextSelection` uses scenario selection, while Free Conversation begins directly in `activeRoleplay` and its voice and Hint flows use the normal active-roleplay paths. Source `3389786c16d676dae2a66a9cdf73367780babcad` adds a narrow request-boundary correction: with no real committed context, ordinary Free Conversation learner text remains the normal `UserMessage` and is not also copied into `selectedContextTitle`. Its first normal turn has `lessonPhase=active_roleplay`, `learnerTurnCount=1`, `isContextSelectionTurn=false`, and empty `selectedContextVariantId` and `selectedContextTitle`. Real CMS scenario selection and real custom-context flows remain unchanged. Conversation Mode production rendering did not change; only its stale test assertion was corrected. Focused affected suites and physical Android smoke passed for Free Conversation normal conversation and an ordinary guided lesson with a selected situation; the complete v10 release gate then passed. No backend, API, or CMS change was required.

The Production page's edge-to-edge compatibility and R8 memory/performance optimization items remain separate non-blocking quality recommendations, not policy errors or release failures. Earlier physical checks found no visible edge-to-edge boundary problem on the tested Android 15/16 Samsung S25, Samsung A56, and Honor devices; that evidence is limited to those devices and is not a universal compatibility claim. Edge-to-edge and R8 changes require separate implementation and verification.

The historical versionCode 5 controlled billing E2E proved purchase-sheet launch, backend verification, backend-owned Premium, accelerated renewal reconciliation, final expiry, return to Free, and restored new-purchase eligibility. Existing versionCode 8 was selected as the Production candidate, submitted for review after owner approval, and became publicly installable as **Orralen - Language Voice Tutor** on 2026-09-03. It includes signed-out password recovery and Restore Credentials. Restore Credentials cross-device E2E is complete for the tested account/session path only. Public Privacy, Terms, Seller/Company, Refund, Cancellation, AI & Data Disclosure, Availability, Pricing, and Support pages are published; Data Safety, app-content/rating work, developer/package verification, target SDK 36, and final Policy-center review were completed during release preparation.

The 2026-09-01 purchase-gate investigation is complete: legacy pre-Live local Paddle rows whose stale `active` statuses blocked the backend's intentionally fail-closed new-purchase gate were repaired as a one-time guarded production-data cleanup. License testing is isolated to the dedicated `pay` list, and a non-license-test account then completed the real-money first purchase using normal payment methods. The existing backend-owned registration-trial/continuous-Premium tail was applied through the initial Google Play deferral mechanism; fresh provider-management state showed active auto-renew with next payment on 2026-10-08. Google Play itself still has no trial or introductory offer. No Mobile code, AAB, versionCode, backend runtime rule, configuration, migration, or deployment changed; the actual renewal charge remains pending.

The completed v8 Production path was: legal/support and Data Safety preparation; physical Internal-testing and Restore Credentials coverage; real-money first-purchase and `.148` initial-deferral precision validation; final review and explicit owner approval; existing v8 selected and submitted; then public install availability confirmed. At that 2026-09-03 checkpoint, production backend was `.151` with `.150` rollback. Continue targeted post-release monitoring only: actual normal renewal, pending payment, explicit cancellation, fresh-install billing restore, refund/voided-purchase, chargeback, and other lifecycle evidence remain unobserved rather than release blockers.

Notifications V1 is local-only: no Firebase, remote/server push, backend endpoint, push-token registration, remote provider, backend notification state, or background microphone behavior. Product settings enable reminders by default at device-local 09:00 and 20:00; learners can edit both times or disable all reminders. Android notification permission is still required. Explain the benefit and ask only after the learner sees the product experience, do not reprompt on every launch after denial, and offer Android settings recovery where practical. V11 reconciles immediately after first permission grant, replaces stable IDs without proactive cancellation, and cancels them when disabled or permission is unavailable. Stage-specific diagnostics and the release-retained icon are recorded above. Scheduling is intentionally inexact; no exact-alarm permission was added. Preserve device-local schedule semantics across timezone changes and restore reminders after reboot where Android requires it, while keeping those untested physical scenarios separate from the two-device v11 delivery evidence. Local reminders are not synchronized backend account state and cannot always be suppressed after a lesson on another device.

The Premium UI and Google Play billing bridge foundation are implemented in the public Production runtime, while controlled license testing remains isolated to the approved test context. A local button, purchase callback, or verified Play result never grants Premium; Mobile displays backend `SubscriptionStatus`. Google Play maps to the same provider-neutral Premium as Paddle, trial, and manual-admin. Controlled purchase, reconciliation, expiry, and public rollout are established; broader lifecycle monitoring remains separate work. V11 did not change or newly validate this billing architecture.

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

The historical v8 signing-audit output was exactly `app/build/app/outputs/bundle/release/app-release.aab` (191983753 bytes), SHA-256 `8C633D4689066BF0BE17B7B7AA266B4049750965092D5642C589DF5F6865A7ED`. It passes `jarsigner` verification. Its embedded upload certificate SHA-1 is `60:A8:13:5D:A6:B1:72:00:F2:6A:80:D2:F9:91:A9:01:CC:EB:F8:9B`, and its SHA-256 exactly matches the Google Play Console Upload key certificate.

The historical v9 output was `app/build/app/outputs/bundle/release/app-release.aab` (196311466 bytes), SHA-256 `C301B36333FB8B70AB8A7372D5E74BA62AC9810AD6704730234BCBBE951B703C`; `jarsigner` reported `jar verified`. It was built from `0af802958a6a42116ecc1d8084ebdecc12e11406` and became publicly available in Google Play Production on 2026-09-09. Its Free Conversation phase-boundary correction in `fefbac3f366920b980f831ddd55c18e2734471a0` remains historical evidence and is not relabeled as the later v10 request-boundary correction.

The historical v10 output was `app/build/app/outputs/bundle/release/app-release.aab` (196468474 bytes), SHA-256 `45B2552ACE707A94772AC0739BF7B6E8632A8C994A54D33C3759DDF79B842C0C`; `jarsigner` reported `jar verified`. It was built from `3389786c16d676dae2a66a9cdf73367780babcad`, carried the verified upload certificate SHA-256 recorded above, and was publicly active in Google Play Production as of 2026-09-20. The historical v11 output was the AAB at that path (196486143 bytes), SHA-256 `A47ED1DD989D1AF87B166C73103B508227698533675625F06FA736EF94E9FA98`, from `1113a4c09ee75021a435f67dceee8b7b55ba1160` and active in Production as of 2026-09-27; no separate v11 signing-tool result is recorded.

Current v13 signing and AAB facts are recorded in Phase 5 above. Historical Android `0.1.0+12` / versionCode 12 used source `a75f8b308c400b895a2a708bc9320f208ae033f7` and target SDK 36. Its AAB at `app/build/app/outputs/bundle/release/app-release.aab` was 196197868 bytes with SHA-256 `C93EFA93B205BC32E8CCFCA5F84494ABB1B235B9F410EECD3804F08D107CEDCB`; signing, version, hash, `jarsigner`, and upload-certificate verification passed. V12 was confirmed active in Production before the v13 release was created and is the Production predecessor to v13.

Google Play Console has `com.languagevoicetutor.mobile` registered, Android developer verification is confirmed, and no additional package or key registration is currently required. An older upload-key reset request may remain in console history, but it is not a current blocker because the working upload key matches the existing AAB certificate. Do not request another reset or cancellation without a new concrete reason.

During pre-release Internal testing, the v8 build passed physical testing on five Samsung and Huawei Android devices. Google Play installation, system-language startup and defaults, registration, restoration of backend-owned account settings/Progress/History, lesson scenario completion, Conversation Mode, speech recognition and automatic sending, tutor voice playback, Hints, Translation, Feedback, Summary, Progress, general and topic-specific achievements, study-language switching without mixed-language lesson openings, tutor avatar/voice changes, Settings History/Progress, password change/recovery, lifecycle recovery, temporary network loss/recovery, and microphone-permission denial/recovery worked as expected.

One bounded non-blocking post-release polish item remains: after microphone permission is denied, the desired future behavior is to show the microphone-denied/open-settings warning only when the learner attempts to use the microphone while permission remains denied. Do not treat this as a release-blocking functional defect.

## iOS posture

The repository should avoid Android-only architectural decisions where reasonable, but iOS should not drive V1 implementation. Do not create iOS project files until the team explicitly approves an iOS phase.
