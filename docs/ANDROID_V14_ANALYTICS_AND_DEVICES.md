# Android v14 preparation: analytics, consent and account device activity

Implementation checkpoint: 2026-10-18. Base commit: `07f7b82ffd2c1aa465780cb9483674b074e40d68`.
The application remains `0.1.0+13`; this is preparation for a future explicitly approved v14 candidate, not a released version.
Backend contract reference: production `.169`, checked against local backend source read-only. No backend, database, console, website or production changes are part of this work.

## Firebase configuration and operator action

Approved project: `orralen-lvt-production`. Android package: `com.languagevoicetutor.mobile`.
Existing Analytics account: Orralen; linked GA4 property: `543566893`. These console relationships were supplied by the owner; they have not been independently inspected in the consoles.
The existing Firebase Android app must be reused. Its Firebase app ID, API key and messaging sender ID were not supplied and must not be invented.

This machine has no Firebase CLI, FlutterFire CLI, Firebase CLI authentication file, `android/app/google-services.json`, or generated `lib/firebase_options.dart` at implementation time. Analytics therefore remains unavailable until operator setup. No substitute config or generated-looking stub is included.

Follow the [official FlutterFire setup workflow](https://firebase.google.com/docs/flutter/setup):

1. An operator with access to the existing project installs the Firebase CLI, runs `firebase login`, and runs `dart pub global activate flutterfire_cli`. Use interactive authentication; do not paste credentials into chat, commit credentials, or capture them in logs.
2. Confirm in Firebase Project settings that the **existing** Android app has package `com.languagevoicetutor.mobile`. Confirm its existing Firebase App ID there. `firebase apps:list ANDROID --project orralen-lvt-production` is an alternative inventory check.
3. From `C:\dev\LanguageVoiceTutor.Mobile\app`, run:

   ```powershell
   flutterfire configure --project=orralen-lvt-production --platforms=android --android-package-name=com.languagevoicetutor.mobile --out=lib/firebase_options.dart
   ```

   Select/match the existing app only. Do not accept creation of a project, app, or property. Cancel if the expected app cannot be matched; resolve account access first. Do not use an unattended `--yes` workflow that could accept creation.
4. Confirm the workflow generated `lib/firebase_options.dart` and `android/app/google-services.json` from that exact app. If needed, download that existing app's Android client JSON from Project settings, without displaying its contents. Review the generated diff for accidental platform, Gradle or configuration changes.
5. `FirebaseAnalyticsSink` currently uses supported Android native-resource initialization (`Firebase.initializeApp()`); the Google services plugin creates these resources from the JSON. After the generated options file exists, integrate the standard FlutterFire initialization in that sink: import `../firebase_options.dart` and use `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`. Keep native JSON/resources for Android Analytics and automatic purchase reporting. Do not remove any consent defaults or error isolation.
6. Rerun dependency resolution, format, analysis, Flutter tests and the debug compilation/QA below. Do not change the approved package, project or GA4 property. Generating the genuine options file, integrating it and validating a configured build remain release blockers.

The Groovy Google services plugin is applied only when the real JSON exists. Build-time validation rejects a wrong project/package. Runtime also checks the project before enabling collection. An unconfigured debug build compiles and works with analytics unavailable; this does not validate a configured production build.

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

## Consent behavior

The Android manifest disables collection and defaults analytics storage, advertising storage, advertising user data and advertising personalization to denied **before native SDK startup**. Advertising-ID collection is disabled; merged advertising-ID and AdServices permissions are explicitly removed. Automatic screen reporting is disabled. Android backup/transfer rules also exclude Analytics preferences/local queue and the secure-store preference file, so a restored native collection grant does not precede a new local choice.

Registration shows Email, Password, optional Display name, one initially unchecked optional usage-statistics checkbox (English: “I agree to share app usage statistics to help improve the app.”), Register, and then a small informational Terms/Privacy notice. The notice has two independent external links; there is no mandatory legal checkbox, analytics link, global analytics panel or registration modal. Register works with analytics unchecked. Immediately before calling the existing registration service, the form awaits persistence/application of the selected analytics choice, so the successful `sign_up` observes that choice. Analytics errors remain fail-closed and do not prevent account creation; denied events are not replayed. A failed registration emits no conversion.

Settings → App has one “Usage statistics” switch with the description “Share app usage statistics to help improve the app.” inside a standard rounded Settings card. It inherits the shared card background, border and 14-pixel radius, uses matching 16-pixel inner padding and existing 12-pixel inter-card spacing, and keeps the trailing switch vertically centered. The same consent service retains persistence and withdrawal. All 16 existing locale resources are translated, preserving identical Latin-only `sr`/`sr_Latn` and existing routing. The registration checkbox is a fresh unchecked draft each time registration is entered; Settings reflects the persisted choice. The persisted choice is separate from account tokens, installation-wide and retained across logout/account switching. Missing/unreadable preference is not consent. The shortened registration and Settings copy changes presentation only; Firebase collection/consent defaults, event boundaries and denied advertising purposes remain unchanged. The shortened wording has not received legal approval in this task.

On allowance, Firebase `setConsent` grants **only** analytics storage, with ad storage/user data/personalization explicitly denied; collection is then enabled. Withdrawal immediately closes the manual-event gate, disables SDK collection, denies all four consent types and resets local Analytics data. This reset is not a server-side erasure request for previously received events. No analytics-consent choice suppresses operational device activity.

Conservative product decision for this change: optional product analytics only, with **all advertising purposes disabled worldwide**, including the EEA, UK and Switzerland. The existing GA4/Ads link is not consent. Capturing `first_lesson_started` in GA4 does not authorize its use for Ads targeting or conversion uploads. Before any advertising activation, the owner/legal reviewer must decide separately scoped advertising consent, disclosures, regional/age handling, consent-record requirements and the Google EU User Consent Policy obligations. This implementation is not a legal compliance certification.

## Operational Android device and activity contract

`DeviceActivityTracker` is owned by the application root and observes app lifecycle separately from the lesson screen's existing audio lifecycle. `AuthService` exposes only backend-confirmed account changes, including the verified Restore Credentials assertion response. No new request is needed to discover the restored user.

The existing authenticated/session-recovering API client posts to `POST /api/me/devices` with camel-case JSON keys matching normal ASP.NET JSON handling:

```json
{"platform":"Android","deviceName":"Manufacturer Model [installation UUID]","appVersion":"installed version+build"}
```

The response is parsed as `registered` (boolean), `lastSeenAt` (date/time), and `trackingScope` (string). The server remains the authority for `LastSeenAt` and record scope.

Native code reads only `Build.MANUFACTURER` and `Build.MODEL`. A cryptographically random UUID plus the readable label is saved once in Android `noBackupFilesDir`, outside cloud backup and device transfer, and reused as the complete name. This distinguishes separate same-model installations without serials, IMEI, Android ID, user device names, advertising IDs or hardware fingerprints. Label + UUID is limited to 128 UTF-16 code units, preserving the complete UUID. The generic fallback is `Android device [UUID]`. Corrupt/unwritable identity persistence skips tracking rather than generating unstable rows or collapsing all devices into a shared fallback.

`package_info_plus` supplies the installed version and build, bounded to 64 characters; unavailable optional version metadata uses `Unknown`. No application version is hardcoded in production metadata code.

Updates occur after successful login, signup, startup session restoration and cross-device credential restoration, on foreground resume and every **15 minutes** of continued foreground use. Only authenticated foreground sessions run a timer. Rapid updates for the same account are coalesced for one minute, including failures; this avoids repeated rapid resume traffic. Backgrounding and logout cancel the timer; account switching resets the throttle. There is one in-flight operation, and stale account requests cannot refresh or clear a newly selected account. An already-sent HTTP request can finish after background/logout; there is no background service or aggressive retry loop. Operational network errors do not set Premium, change lesson limits, revoke credentials or block navigation.

Reinstall/app-data clearing creates a new installation record; old backend records are not deleted by this endpoint. The same physical installation used by different accounts creates one row per account under the existing `UserId + Platform + DeviceName` key. The UUID is pseudonymous account-linked operational metadata, not anonymous data. Backend device retention/cleanup/deletion remains an owner/backend policy decision; no endpoint or migration was added. Account deletion remains the existing deletion-request flow, not an invented immediate local/server erasure flow.

## Privacy Policy and Google Play Data safety follow-up

The checked-in backend website policy was reviewed read-only. It is still a product/legal draft, describes optional **website cookies**, and has unresolved retention/minors text. It does not specifically explain this Android Firebase SDK or the installation UUID/LastSeenAt. Live website and Play declarations were not inspected or changed.

Before v14 publication, the owner must:

- Add an Android-specific Firebase/Google Analytics disclosure: optional usage events, app-instance/device metadata, automatic first-open/purchase collection, provider/processor, purposes, recipients, cross-border handling, retention and user rights. Check the [SDK disclosure guidance](https://firebase.google.com/docs/android/play-data-disclosure) for the actual pinned SDK and Play integration. Do not claim the SDK collects no identifiers just because advertising ID is disabled. Assess approximate-location information derived from IP by Google and automatic subscription/purchase-history data.
- Explain analytics opt-in/withdrawal under Settings → App, denied advertising purposes, no replay of denied events, and why website cookie choices do not control mobile consent. Explain that withdrawal/reset does not erase historical server-side data; document an actual rights/deletion route.
- Separately disclose required account-linked device records: generic manufacturer/model, random installation UUID, installed version/build, platform and LastSeenAt; functionality/security/support purposes, authentication linkage, retention and deletion. Declining Firebase analytics does not stop those records. Decide the lawful basis and retention with the owner/legal reviewer.
- Review/update Play Data safety for optional **App activity / app interactions** and **Device or other IDs**, potential **Approximate location** and **Purchase history** where applicable to SDK/Play behavior. Review collected/shared classifications and any service-provider exception against actual contracts; optional consent does not automatically make collection exempt. Keep operational device collection separate from optional analytics when answering whether collection is optional.
- Reconcile existing account/lesson/audio/purchase declarations, encryption in transit, deletion-request mechanisms and the linked Privacy Policy. Confirm the in-app disclosure and policy accurately describe the shipped artifact rather than just the source.
- Resolve the existing minors/age stance, final retention periods, Google terms/data-processing responsibilities and whether the intended future advertising workflow needs further consent UI. Do not enable Ads usage merely because an account link exists.

No website or Play Console edits/publication are authorized by this implementation.

## DebugView validation (manual, after genuine configuration)

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
6. Confirm the normal finish flow emits one `lesson_complete` only for a matching `Finished` response. Retry duplicate completion, abandon, expire or close lessons; those must not add events. Confirm summary-unavailable behavior still works.
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

## Physical Android QA and release gate

- Login, signup, access-token refresh, startup session recovery, cross-device Restore Credentials, account switch, explicit logout and deletion request retain their existing behavior.
- Operational device row has platform Android, generic label + stable UUID, installed app version/build and server LastSeenAt. Relaunch reuses the row; two same-model devices and a restored device do not merge. Verify no record churn or sensitive device identifiers.
- Foreground >15 minutes updates LastSeenAt approximately every 15 minutes. Background >15 minutes produces no new activity sends; foreground resume refreshes subject to the one-minute throttle. Logout and account switch leave no old timer/request scope. Offline requests fail quietly and a later foreground/periodic update recovers.
- Voice and text lesson starts, runtime setup, audio pause/resume, heartbeat, summary completion, abandonment, free/Premium gates, subscription verification/restore/renewal and reminders remain functional. Billing source/configuration is unchanged.
- Confirm the final merged manifest still contains all consent-off defaults and no AD_ID/AdServices permissions. Backup/transfer tests must establish a fresh analytics choice and fresh installation identity.
- Finish genuine FlutterFire configuration, rerun configured Android compilation, perform DebugView and physical Play-installed billing smoke, and approve privacy/Data safety updates before v14 release approval.
- Version increment, commit, push, release packaging, signing, AAB creation/upload and publication all require separate explicit approval.

## Automated verification

Focused Dart tests cover consent, initialization/startup failure, exact success triggers, authoritative/ambiguous history, persistent local deduplication, payload allowlists, startup and cross-device session restoration, activity lifecycle/throttling/concurrency, installed package metadata, wrong/stale account responses, Premium rebuild behavior and the absence of manual purchase events. Native JVM tests cover actual file-backed identity reuse, distinct same-model installations, length/fallback and corrupt persistence.

Original analytics/device implementation verification (2026-10-18, before the registration UI correction): `flutter pub get`, generated localization, formatting of changed Dart files, `flutter analyze` (no issues), `flutter test` (**812 passed**), and `gradlew.bat :app:compileDebugSources :app:testDebugUnitTest` (**BUILD SUCCESSFUL**, **4 native tests, 0 failures/errors**) all passed. `git diff --check` passed. The merged debug manifest was checked for the seven collection/consent/advertising defaults; all are false, with AD_ID and AdServices permissions absent.


Registration UI correction verification (2026-10-18): `flutter gen-l10n`, formatting, **213 focused Flutter tests**, `flutter analyze --no-pub` (no issues), and `git diff --check` passed. The focused suite covers the exact field/optional-checkbox/button/legal-notice order, successful opted-in and opted-out registrations, consent persistence/application before conversion, storage failure isolation, duplicate submit suppression, no global/duplicate consent UI or registration modal, Settings withdrawal/persistence, all 16 locales, small keyboard/large-font layouts, accessible checkbox/link semantics, and existing event/deduplication/device-activity behavior. The actual application-root registration layout was rendered and visually inspected at 390×844. The full suite and Android compilation were not rerun for this UI correction; physical/configured-device checks remain pending.

The existing Gradle/Kotlin/plugin deprecation warnings remain non-blocking. Firebase's normal transitive WAKE_LOCK and Play install-referrer service permissions appear in the merged manifest; there is no added runtime permission or background service for operational device tracking. No release/AAB/signing task was invoked. Physical device, genuine configured Firebase/DebugView, device-transfer and Play-installed billing validation remain unverified.
