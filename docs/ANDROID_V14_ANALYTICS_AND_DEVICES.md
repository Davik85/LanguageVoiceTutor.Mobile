# Android v14 analytics history and Android v15 deactivation follow-up

## Current Android v15 follow-up (2026-10-20)

V15 removes the optional analytics checkbox, explanation, separate analytics Privacy Policy link and analytics-specific errors from Registration, while retaining the normal Terms of Service and Privacy Policy links. App Settings no longer shows the analytics switch/card. Startup uses `NoopAnalyticsService` and the Android manifest sets `firebase_analytics_collection_deactivated=true`; previously persisted consent cannot activate native collection in v15. Firebase implementation, dependencies, event definitions, translations, reusable components and persisted consent records remain available for a separately approved future reactivation, which must not silently reuse old consent while controls are hidden.

Operational backend-owned device registration and Last App Active tracking remain independent and unchanged. Authentication, subscriptions, Google Play Billing, lessons and audio contracts did not change. Analytics deactivation does not stop authenticated operational user/device data collection.

Release source: `31fca12b970c76c9860229e9fa7dc93f8b58c2a6` on `main`, pushed to `origin/main`; Android `0.1.0+15` / versionCode **15**, package `com.languagevoicetutor.mobile`, target SDK **36**. Supplied verification records the full **902 passing Flutter tests**, clean `flutter analyze`, successful release APK and AAB builds, and AAB signature verification with `jarsigner`. AAB SHA-256: `87765773EB715301CC83130138CE0B0F8D00F4B5B95BBA6E6E7B20B1FAFCD8C0`; upload certificate SHA-256: `36405DB45647B23C68EE2DAB122170CADE06113828D99D02AB625433E2F50BF7`. These release checks are recorded evidence and were not rerun in this documentation-only task.

Google Play Production v15 was submitted for review with managed publishing disabled. The owner subsequently reported v15 available through Google Play on **2026-10-20**. No exact approval timestamp, 100% rollout percentage or automatic-update evidence is supplied. A physical Play-installed v15 upgrade/smoke and network capture were not independently verified in this task.

The owner has **not changed the Google Play Data safety declaration for v15**. The v14 declaration and GA4/Ads history below are preserved as dated evidence, not evidence of active v15 Analytics collection or attribution. No Play, Firebase, Ads or Data safety setting was changed by this documentation update.

## Separate open backend speech investigations

As of **2026-10-22**, owner-reported production backend is `0.1.35-backend.171`, shared by Android and Windows Desktop, with `0.1.35-backend.169` as rollback. Production release source: `0238380e735035156fe696f2a4cc1a00462bf0ef`. Backend `.170` was unsuccessful and rolled back; it is not an accepted speech fix.

User Analytics and the Admin MP4 background are deployed; lesson cleanup remains enabled. The **2026-11-08 Google Play renewal monitoring checkpoint remains OPEN**; billing lifecycle checks are not complete. No live backend or infrastructure check was performed in this documentation-only task.

Both server-side speech investigations remain **OPEN**: (A) missing words inside completed WAV files, with confirmed silent PCM regions; (B) cold OpenAI connection/session startup after inactivity, sometimes causing delays or HTTP 504. These are owner-supplied investigation findings; no specific Android version, device playback or audio cache is established as the cause. Android v15 fixes neither issue. The shared overall backend speech timeout remains **20 seconds**. A periodic 30-minute OpenAI warm-up was proposed but was not approved or deployed; investigation and any backend change remain separate from the Mobile release.

## Historical v14 release checkpoint (2026-10-19)

Historical checkpoint: 2026-10-19. The original 2026-10-18 preparation used base `07f7b82ffd2c1aa465780cb9483674b074e40d68` at `0.1.0+13`; it remains historical implementation evidence. The verified release source/state follows.

At the 2026-10-19 checkpoint, `main` release source was `b66c0efccd1fbceb1bde9f70f4ad529de30df2bd`, with `0.1.0+14` / versionCode **14**, package `com.languagevoicetutor.mobile`, and target SDK **36**. The supplied release verification records the v14 AAB build and signing-certificate verification, **897 passing Flutter tests**, and clean `flutter analyze`. These are recorded release results, not commands rerun for this documentation update.

At that v14 checkpoint, the owner-confirmed Google Play Console state was **uploaded to Production and submitted for review**. Managed publishing is disabled, so approved changes can publish automatically. Approval, public availability, publication time, and a Play-installed v14 smoke are not confirmed by the supplied evidence. The 2026-10-05 v13 Production record in the [README](../README.md) remains historical; it does not establish v14 publication.

## Historical 2026-10-20 deactivation preparation (before the v15 release)

At this preparation checkpoint, the source change was not published. The planned next Android build removed optional analytics controls from registration and App Settings and selected the existing `NoopAnalyticsService` at startup. Registration retains its Terms/Privacy legal notice and no longer reads or writes analytics consent. Operational device registration and Last App Active tracking remain independent and unchanged.

The application manifest adds `firebase_analytics_collection_deactivated=true`, the [documented Firebase version-level deactivation setting](https://firebase.google.com/docs/analytics/android/configure-data-collection#permanently_deactivate_collection), so prior native collection grants cannot enable Analytics in this build. Existing denied defaults and advertising restrictions remain. Firebase dependencies, configuration, implementations, reusable consent widget, event definitions, translations and persisted consent records are retained.

Future reactivation requires a separately approved consent-management decision; it must not silently reuse old consent while controls are hidden. The implementation, UI descriptions, QA steps and release evidence below describe the historical v14 behavior and do not establish publication of this follow-up. At this preparation checkpoint, app version/versionCode remained `0.1.0+14` / 14; the subsequent v15 release is recorded above.

Historical deactivation-preparation verification on 2026-10-20: **204 focused Flutter tests passed** (registration/legal links, Settings, retained consent/service behavior, disabled runtime and device activity), `flutter analyze --no-pub` reported no issues, and `flutter build apk --debug --no-pub` succeeded. The generated debug manifest and APK binary manifest both contain native deactivation; all seven existing denied defaults remain false and advertising permissions remain absent. Package/versionCode are unchanged. No physical-device upgrade or network-capture verification was performed; no commit, push or publication occurred.

## Retained Firebase configuration and historical v14 implementation

The event contracts, consent behavior and analytics validation procedures below describe the historical v14 opt-in implementation. They are inactive in v15 and must not be used as current v15 instructions to enable collection; operational device activity remains current and independent.

Firebase project: `orralen-lvt-production`; Android package: `com.languagevoicetutor.mobile`; Analytics account: Orralen; GA4 property ID: **543566893**; Android data stream ID: **16152315974**. Property/stream console facts are supplied by the owner and were not independently queried in this documentation update.

The existing ignored `app/android/app/google-services.json` was read only to confirm the project ID and Android package; no credentials are reproduced here. The Google services plugin validates those values and generates Android native resources. `FirebaseAnalyticsSink` uses the working `Firebase.initializeApp()` native-resource path and checks the project before enabling collection. `firebase_options.dart` is not required by this implementation, and installing Firebase CLI or FlutterFire CLI is not a current release blocker. The original unconfigured preparation state is superseded; no config, SDK initialization, Gradle or console setting was changed by this documentation update.

Current known production backend, as supplied by the owner on 2026-10-19, is `0.1.35-backend.169`; the unsuccessful `.170` change was rolled back. This backend is shared by Android and Windows Desktop. No live deployment or infrastructure check was performed for this documentation update.

## Dependencies and Android compatibility

Direct additions are `firebase_core` **4.0.0**, `firebase_analytics` **12.0.0**, and `package_info_plus` **9.0.1** (the last retains its compatible caret constraint). FlutterFire versions are pinned exactly; core selects Android Firebase BoM **34.0.0**. Native device identity tests add test-only JUnit **4.13.2**.

The installed Flutter is 3.44.4 / Dart 3.12.2, with AGP 8.11.1, Kotlin 2.2.20, Gradle 8.14 and Java 17 source targets. These existing toolchain settings are retained. Initially resolved core 5.0.0 / Analytics 13.0.0 selected BoM 35.0.0 and Analytics 24.0.0, whose Kotlin 2.4 metadata failed compilation with the existing Kotlin compiler. They were replaced with the pinned compatible pair rather than upgrading the toolchain or suppressing metadata checks. Reassess compatibility deliberately before future Firebase upgrades.

Only Firebase Core and Analytics are added. Account authentication and Premium remain backend-owned.

## Events and exact boundaries

All manual events go through injectable `AnalyticsService`. Tests and unavailable environments can use `NoopAnalyticsService`. The Firebase adapter is the only location calling Firebase. Initialization, storage, consent and event exceptions are isolated from core application outcomes. Startup does not await Firebase.

| Event | Source and successful trigger | Exclusions/deduplication |
| --- | --- | --- |
| `first_open` | Firebase automatic event, subject to collection/consent | Never manually emitted; SDK controls timing after opt-in, reset or reinstall. |
| `in_app_purchase` | Firebase/Google Play automatic reporting | No client purchase logging. No restoration, renewal, pending, failed, cancelled or entitlement-refresh callbacks are converted into manual purchases. SDK/Play automatic reporting must be tested separately. |
| `sign_up` | `AuthService.register`, after successful backend authentication/account creation and token save | A failed registration emits nothing; one event per successful call. |
| `login` | `AuthService.login`, after explicit successful backend login and token save | Startup session discovery, token refresh, foreground resume and Restore Credentials never call this event. |
| `lesson_start` | `AuthService.startLessonSession`, after successful backend creation with a valid returned lesson-session GUID | No screen/scenario-open, failed-start, active-session discovery or resumed-session events. Persistent local account/session claim prevents duplicate callbacks/restarts. |
| `first_lesson_started` | Same confirmed start, only after an immediately preceding authenticated history response proves `items` is an empty array and no local first-lesson claim exists | Any nonempty array (including Abandoned, Expired or Finished sessions), missing/malformed array, failure, unauthorized response, unknown account or timeout suppresses the conversion. |
| `lesson_complete` | Existing finish PUT returns this session's ID and `Status: Finished` | Claim is per local account/session. Summary generation/reading is separate; a successful finish counts even if the summary is unavailable. Abandonment, expiry, screen close and failed finish do not count. |
| `premium_view` | First rendered frame of a newly opened Premium screen | Rebuilds do not emit again. Opening the screen anew is another view. |

Permitted parameters are fixed-vocabulary `study_language`, CEFR `level`, and `method=password` on authentication. Backend English language names are normalized to known language codes. Unknown/free text is discarded. Category identifiers are omitted rather than sending user-provided context.

Emails, names, account IDs, session IDs, device UUIDs, purchase tokens, access/refresh tokens, prompts, scenario prose, lesson text, transcripts and audio are never parameters or Firebase user IDs/properties. Backend account/session identifiers are hashed **locally** to scope persistent deduplication markers; they are not sent to Firebase. Firebase's own app-instance/device metadata and automatic purchase data are separate SDK collection and must be disclosed.

## First-lesson accuracy and local deduplication limits

The backend history query is by authenticated user, includes **all statuses**, and takes the latest 50 sessions. A genuinely empty array proves no stored lesson sessions; a nonempty array is sufficient to suppress a first-lesson event without inspecting all historical records. Recent history is never treated as an authoritative count for Progress.

The optional evidence read happens before the candidate start, with a total two-second client budget. It uses the existing API client and a snapshot of the current access token, without refreshing/revoking/clearing credentials. A stale token therefore causes undercounting rather than an analytics-originated authentication change. The underlying HTTP request may finish after timeout; it has no callback that can emit the conversion later. Ordinary lesson creation retains its existing session recovery.

Events are not queued for later consent, initialization or network recovery. Deduplication claims are written before event submission, serialized within the single app service, and retained in secure storage across ordinary restarts/logout. Storage failure drops the event. Crash/transport failure after claiming can lose an event; this is intentional conservative at-most-once submission per local key, not a delivery guarantee. Clearing app data/reinstalling removes local claims; surviving server history remains the protection against false first-user conversions. Local claims are not a cross-device lock and are not uploaded.

There is **no cross-device exactly-once guarantee**. Two devices can both observe empty history; one can create and finish a lesson before the other's delayed creation succeeds. Local state cannot prevent both from emitting. Concurrent active starts are rejected by the current backend, but this does not close the completed-between-check-and-start race. Backend history deletion/reset and the check/create crash window are further limits. A future authoritative backend conversion marker/transaction would require separately approved backend work.

## Historical v14 consent behavior (not current v15 instructions)

The Android manifest disables collection and defaults analytics storage, advertising storage, advertising user data and advertising personalization to denied **before native SDK startup**. Advertising-ID collection is disabled; merged advertising-ID and AdServices permissions are explicitly removed. Automatic screen reporting is disabled. Android backup/transfer rules also exclude Analytics preferences/local queue and the secure-store preference file, so a restored native collection grant does not precede a new local choice.

Registration shows Email, Password, optional Display name, one initially unchecked optional usage-statistics checkbox, a clickable localized **Privacy Policy** link alongside that text, Register, and the existing Terms/Privacy account-creation notice below Register. Legal acceptance remains separate from optional analytics: the notice states that account creation agrees to Terms and links the Privacy Policy for review; the actual source has no separate mandatory legal checkbox. The analytics link uses the existing legal document launcher for `https://languagevoicetutor.com/privacy.html`; opening it does not toggle consent or submit the form. Register works with analytics unchecked. Immediately before the existing registration call, the form awaits persistence/application of the analytics draft choice so `sign_up` observes it. Analytics failures do not block account creation, denied events are not replayed, and failed registration emits no conversion. There is no global analytics panel or extra registration modal.

Settings → App has one “Usage statistics” switch with the description “Share app usage statistics to help improve the app.” inside a standard rounded Settings card. It inherits the shared card background, border and 14-pixel radius, uses matching 16-pixel inner padding and existing 12-pixel inter-card spacing, and keeps the trailing switch vertically centered. The same consent service retains persistence and withdrawal. The same labels are localized across fourteen selectable interface locales: `en`, `ru`, `es`, `fr`, `de`, `it`, `pt-PT`, `bg`, `hr`, `sr-Latn`, `pl`, `ja`, `ko`, `ar`. Generated generic `pt` and `sr` fallbacks make 16 generated locale variants; Serbian `sr`/`sr_Latn` remain Latin-only. The registration checkbox is a fresh unchecked draft each time registration is entered; Settings reflects the persisted choice. The persisted choice is separate from account tokens, installation-wide and retained across logout/account switching. Missing/unreadable preference is not consent. The shortened registration and Settings copy changes presentation only; Firebase collection/consent defaults, event boundaries and denied advertising purposes remain unchanged. The shortened wording has not received legal approval in this task.

On allowance, Firebase `setConsent` grants **only** analytics storage, with ad storage/user data/personalization explicitly denied; collection is then enabled. Withdrawal immediately closes the manual-event gate, disables SDK collection, denies all four consent types and resets local Analytics data. This reset is not a server-side erasure request for previously received events. No analytics-consent choice suppresses operational device activity.

The historical v14 client granted only analytics storage on optional opt-in; advertising storage, advertising user data and personalization remain denied worldwide. The owner-reported GA4/Ads conversion configuration below does not change those SDK flags, establish advertising consent, or prove successful attribution. This documentation records the existing implementation and supplied console state; it is not a legal compliance certification.

## Operational Android device and activity contract

`DeviceActivityTracker` is owned by the application root and observes app lifecycle separately from the lesson screen's existing audio lifecycle. `AuthService` exposes only backend-confirmed account changes, including the verified Restore Credentials assertion response. No new request is needed to discover the restored user.

The existing authenticated/session-recovering API client posts to `POST /api/me/devices` with camel-case JSON keys matching normal ASP.NET JSON handling:

```json
{"platform":"Android","deviceName":"Manufacturer Model [installation UUID]","appVersion":"installed version+build"}
```

The response is parsed as `registered` (boolean), `lastSeenAt` (date/time), and `trackingScope` (string). The server remains the authority for `LastSeenAt` and record scope.

The backend stores device `LastSeenAt` and returns it as `lastSeenAt`. The agreed account-level last-activity definition is the latest `lastSeenAt` across devices for the same user. This defines an aggregate interpretation, not a claim that a dedicated user `LastActiveAt` database field or an Admin last-activity view has been implemented; neither is established by this Mobile source/contract review.

Native code reads only `Build.MANUFACTURER` and `Build.MODEL`. A cryptographically random UUID plus the readable label is saved once in Android `noBackupFilesDir`, outside cloud backup and device transfer, and reused as the complete name. This distinguishes separate same-model installations without serials, IMEI, Android ID, user device names, advertising IDs or hardware fingerprints. Label + UUID is limited to 128 UTF-16 code units, preserving the complete UUID. The generic fallback is `Android device [UUID]`. Corrupt/unwritable identity persistence skips tracking rather than generating unstable rows or collapsing all devices into a shared fallback.

`package_info_plus` supplies the installed version and build, bounded to 64 characters; unavailable optional version metadata uses `Unknown`. No application version is hardcoded in production metadata code.

Updates occur after successful login, signup, startup session restoration and cross-device credential restoration, on foreground resume and every **15 minutes** of continued foreground use. Only authenticated foreground sessions run a timer. Rapid updates for the same account are coalesced for one minute, including failures; this avoids repeated rapid resume traffic. Backgrounding and logout cancel the timer; account switching resets the throttle. There is one in-flight operation, and stale account requests cannot refresh or clear a newly selected account. An already-sent HTTP request can finish after background/logout; there is no background service or aggressive retry loop. Operational network errors do not set Premium, change lesson limits, revoke credentials or block navigation.

Reinstall/app-data clearing creates a new installation record; old backend records are not deleted by this endpoint. The same physical installation used by different accounts creates one row per account under the existing `UserId + Platform + DeviceName` key. The UUID is pseudonymous account-linked operational metadata, not anonymous data. Backend device retention/cleanup/deletion remains an owner/backend policy decision; no endpoint or migration was added. Account deletion remains the existing deletion-request flow, not an invented immediate local/server erasure flow.

## Privacy Policy, Google Play Data safety and advertising status

Owner-confirmed console checkpoint (2026-10-19): the Google Play Data safety update for v14 is complete, retaining existing categories/disclosures and adding optional analytics-related **Device or other IDs** and **Approximate location**, for the **Analytics** purpose. This is supplied console evidence, not a fresh console inspection or a statement that advertising-ID collection was enabled. The Android manifest still disables advertising-ID collection and removes AD_ID/AdServices permissions. Internal authenticated device records remain operational account data independent of the optional Firebase choice.

The owner reports these configured GA4 key events in property **543566893** and Android Google Ads conversion actions:

| GA4 key event | Google Ads Android conversion role |
| --- | --- |
| `first_lesson_started` | Primary |
| `sign_up` | Secondary |
| `lesson_complete` | Secondary |

The owner also confirmed that an Android advertising campaign was created and launched, with first-lesson engagement as the intended optimization goal. The existing Google Play installation conversion remains separate. No budget, spend, conversion counts, campaign effectiveness or successful attribution is established here. Console configuration is distinct from source implementation, DebugView observations and normal production reports.

The existing public Privacy Policy link is `https://languagevoicetutor.com/privacy.html`. The 2026-10-18 local backend-policy draft review is historical and does not establish current live policy wording. Final live policy wording, retention/minors decisions and server-side deletion handling are not newly verified here; no legal approval or policy publication is inferred from the completed Data safety update. Withdrawal/reset does not erase previously received server-side events. No website, Play, Firebase or Ads setting was changed during this documentation update.

## Historical v14 DebugView validation and manual checks

Owner-supplied device observations verified **`lesson_start`** and **`lesson_complete`** in Firebase DebugView. Other manual events remain source/test-backed; they are not all independently verified in production analytics reports. Automatic Firebase events and advertising attribution require their own evidence. The following is a validation procedure, not a claim that every step has passed.

### Historical v14 DebugView procedure (not applicable to deactivated v15)

Use a physical Google Play-capable Android device and the correctly configured debug client. Do not mark conversions/import events or change console links as part of validation. Follow [Firebase DebugView](https://firebase.google.com/docs/analytics/debugview) and [app consent guidance](https://developers.google.com/tag-platform/security/guides/app-consent?consentmode=basic&platform=android).

1. Connect `adb`; select the device with `adb -s SERIAL` when multiple devices are attached. Enable debug events:

   ```powershell
   adb shell setprop debug.firebase.analytics.app com.languagevoicetutor.mobile
   adb shell setprop log.tag.FA VERBOSE
   adb shell setprop log.tag.FA-SVC VERBOSE
   adb shell am force-stop com.languagevoicetutor.mobile
   adb shell monkey -p com.languagevoicetutor.mobile -c android.intent.category.LAUNCHER 1
   ```

2. Open the **existing** `orralen-lvt-production` project → Analytics → DebugView (or the linked GA4 property's DebugView). Select the test device. With a fresh app-data state, register with the optional checkbox unchecked: account creation and normal use should work and no optional client events should arrive. Confirm the manifest defaults and consent messages with `adb logcat -v time -s FA FA-SVC`; avoid sharing raw personal logs.
3. Allow analytics in Settings → App. Confirm analytics storage granted and all three advertising consent types denied. Firebase owns `first_open`/session/engagement timing; never compensate by manually logging them. Automatic screen views should remain off.
4. Using suitable QA accounts, verify successful explicit login gives one `login`; failed login gives none. A successful registration with the checkbox selected gives one `sign_up` after consent is saved/applied; unchecked registration and failed registration give none. Verify both outcomes without any duplicate consent UI. Force-stop/relaunch, resume and Restore Credentials must not emit login.
5. Use an account with an authoritative empty server lesson history. Opening the screen/scenario emits nothing. Successful session creation emits one `lesson_start` and one `first_lesson_started`; fail the start and expect neither. Rebuild/retry/recover/relaunch and inspect duplicate counts. Use existing accounts with prior Finished, Abandoned or Expired sessions and verify no first-lesson conversion. Deny network/history responses or induce a timeout and verify successful starts can occur without the conversion.
6. Confirm the normal finish flow emits one `lesson_complete` only for a matching `Finished` response. Retry duplicate completion and verify no extra event; failed finish, API-level abandonment, expiry and uncompleted screen disposal must not emit completion. Back -> Finish is an explicit completion action in v14. Confirm summary-unavailable behavior still works.
7. Open Premium, trigger UI state rebuilds and then reopen it. Expect one view per opening, no additional view per rebuild. During a separately authorized Play test purchase, verify automatic purchase reporting only; restoration, pending/cancelled/failed outcomes and backend refresh must not produce any custom purchase event. Do not initiate a live paid purchase as part of this coding task.
8. Inspect event payloads in DebugView: only approved parameters, no account/session/device IDs, email/name, tokens, text or scenario prose. Account switching must not set a Firebase user ID. Verify consent decline does not stop device LastSeenAt updates.
9. Withdraw consent; verify no further optional client events, then force-stop/relaunch to verify the denied state persists. Test backup/device transfer to a clean device: consent starts unknown/denied and the operational installation UUID differs. Test small/landscape viewports, keyboard use and all supported languages.
10. Disable debug mode when finished:

    ```powershell
    adb shell setprop debug.firebase.analytics.app .none.
    adb shell setprop log.tag.FA INFO
    adb shell setprop log.tag.FA-SVC INFO
    ```

Debug-mode events are development validation, not evidence that a Google Ads conversion is configured or that normal production reporting is complete.

## Historical v14 physical Android QA and release gate

- Login, signup, access-token refresh, startup session recovery, cross-device Restore Credentials, account switch, explicit logout and deletion request retain their existing behavior.
- Operational device row has platform Android, generic label + stable UUID, installed app version/build and server LastSeenAt. Relaunch reuses the row; two same-model devices and a restored device do not merge. Verify no record churn or sensitive device identifiers.
- Foreground >15 minutes updates LastSeenAt approximately every 15 minutes. Background >15 minutes produces no new activity sends; foreground resume refreshes subject to the one-minute throttle. Logout and account switch leave no old timer/request scope. Offline requests fail quietly and a later foreground/periodic update recovers.
- Voice and text lesson starts, runtime setup, audio pause/resume, heartbeat, shared Back/flag completion and summary, Stay, free/Premium gates, subscription verification/restore/renewal and reminders remain functional. Billing source/configuration is unchanged.
- Confirm the final merged manifest still contains all consent-off defaults and no AD_ID/AdServices permissions. Backup/transfer tests must establish a fresh analytics choice and fresh installation identity.
- Firebase native-resource configuration, v14 release build/signing and the Data safety update are completed checkpoints. Confirm Play approval/publication later and record a v14 Play-installed smoke only after actual store installation; broader DebugView, device-transfer and billing lifecycle checks require separate evidence.
- V14 packaging/signing and upload/submission are recorded completed actions. Any future artifact, console mutation, deployment or publication action needs its own authorization; this documentation update performs none.

## Historical implementation and v14 automated verification

Focused Dart tests cover consent, initialization/startup failure, exact success triggers, authoritative/ambiguous history, persistent local deduplication, payload allowlists, startup and cross-device session restoration, activity lifecycle/throttling/concurrency, installed package metadata, wrong/stale account responses, Premium rebuild behavior and the absence of manual purchase events. Native JVM tests cover actual file-backed identity reuse, distinct same-model installations, length/fallback and corrupt persistence.

Original analytics/device implementation verification (2026-10-18, before the registration UI correction): `flutter pub get`, generated localization, formatting of changed Dart files, `flutter analyze` (no issues), `flutter test` (**812 passed**), and `gradlew.bat :app:compileDebugSources :app:testDebugUnitTest` (**BUILD SUCCESSFUL**, **4 native tests, 0 failures/errors**) all passed. `git diff --check` passed. The merged debug manifest was checked for the seven collection/consent/advertising defaults; all are false, with AD_ID and AdServices permissions absent.


Registration UI correction verification (2026-10-18): `flutter gen-l10n`, formatting, **213 focused Flutter tests**, `flutter analyze --no-pub` (no issues), and `git diff --check` passed. The focused suite covers the exact field/optional-checkbox/button/legal-notice order, successful opted-in and opted-out registrations, consent persistence/application before conversion, storage failure isolation, duplicate submit suppression, no global/duplicate consent UI or registration modal, Settings withdrawal/persistence, all 16 locales, small keyboard/large-font layouts, accessible checkbox/link semantics, and existing event/deduplication/device-activity behavior. The actual application-root registration layout was rendered and visually inspected at 390×844. The full suite and Android compilation were not rerun for that historical UI correction; the later v14 release verification supersedes its unconfigured-release status.

The existing Gradle/Kotlin/plugin deprecation warnings were non-blocking at the implementation checkpoint. Firebase normal transitive WAKE_LOCK and Play install-referrer permissions were present in the inspected debug manifest; operational tracking adds no runtime permission or background service. Later supplied v14 release verification records **897 passing Flutter tests**, clean analysis, successful AAB creation and certificate verification, Production upload/submission, and DebugView `lesson_start`/`lesson_complete`. Approval/publication, a v14 Play-installed smoke, wider production-event reporting and device-transfer validation remain unconfirmed. No Flutter, Gradle, dependency resolution or release command was run for this documentation-only reconciliation.