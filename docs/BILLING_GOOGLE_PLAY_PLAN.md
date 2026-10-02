# Google Play Billing Plan

## Cross-platform Premium architecture

Language Voice Tutor has one account system and one backend-owned Premium entitlement model. Google Play is an additional payment provider for the existing Premium product, not a separate Mobile entitlement or tariff system.

Paddle, Google Play, `manual_admin`, and trial are independent entitlement sources that feed the same provider-neutral backend Premium calculation. One provider must not shorten, hide, relabel, or revoke valid Premium supplied by another source. Mobile displays only backend `SubscriptionStatus`; a local purchase callback or verified Google purchase never grants or persists Premium locally.

## Implemented foundation

The backend foundation is implemented in the existing generic `Subscription` and `Entitlement` model:

- authenticated Google Play purchase-token verification;
- purchase-token ownership protection and protected-token persistence;
- verified purchase persistence for the existing `premium` plan;
- backend-owned acknowledgement and `acknowledgement_pending` retry behavior;
- authenticated RTDN receipt/persistence and reconciliation;
- linked-purchase replacement handling;
- pending-refund review foundation;
- lifecycle projection for `ACTIVE`, `IN_GRACE_PERIOD`, `CANCELED`, `ON_HOLD`, `PAUSED`, `EXPIRED`, and confirmed `SUBSCRIPTION_REVOKED`.

Fresh `purchases.subscriptionsv2.get` state is authoritative over RTDN. Authenticated `SUBSCRIPTION_REVOKED` plus fresh `EXPIRED` may be persisted as revoked. A full-refund subscription `VoidedPurchaseNotification` is a refund/reconciliation signal, not automatic proof of entitlement revocation. Invalid, unknown, ambiguous, and temporary provider results do not revoke existing access.

The Mobile foundation is also implemented:

- Google Play purchase adapter and purchase coordinator;
- authenticated token submission to `POST /api/me/billing/google-play/purchases/verify` using `{ "purchaseToken": "..." }`;
- sanitized handling of `verified`, `acknowledgement_pending`, `pending`, and fail-closed results;
- backend `SubscriptionStatus` refresh when `subscriptionStatusRefreshRecommended` is true;
- restore events routed through the same backend verification path;
- additive backend `SubscriptionStatus` new-purchase eligibility parsing, with missing or inconsistent fields failing closed;
- new-purchase UI suppression unless the backend explicitly allows Google Play purchase;
- a fresh authenticated backend status check immediately before store launch, independent of the earlier UI status;
- regression coverage proving that verification does not create Premium locally.

For `verified`, persistence and backend-owned acknowledgement succeeded. For `acknowledgement_pending`, verified entitlement persistence succeeded while backend acknowledgement retry remains pending. Mobile calls neither Google Play acknowledgement nor `completePurchase`; it refreshes and displays only backend-confirmed subscription state.

## Historical controlled validation and current Production review checkpoint (updated 2026-10-02)

The single normal Mobile runtime uses the implemented Google Play path, with no billing flavor, duplicate runtime, or local Premium authority. Production has `GooglePlayBilling.Enabled=true`, `GooglePlayRtdn.Enabled=true`, and `GooglePlayReconciliation.Enabled=true`. Pending Refund Review is production-enabled with `RefundPreference=NEUTRAL` and `SampleContentProvided=true`. A controlled `PendingRefundReviewNotification` -> protected persistence -> `ReviewRefund` worker -> processed path passed, and the protected payload was cleared after successful processing. At the verified production checkpoint, `TestPurchasesEnabled=false`, the temporary test-purchase allowlist was cleared, and the open pending-refund, permanent-failure, and acknowledgement backlog was clean. This validation is not relabeled as v11 billing testing; v11 made no new billing-policy or lifecycle change. Product ID is `premium`, Base Plan ID is `monthly`, `monthly` is active, and there is no Google Play free trial or introductory offer.

- normal application composition creates `GooglePlayPremiumPurchaseAdapter` without a build flag, flavor, or alternate entrypoint;
- `AppConfig.googlePlayPremiumProductId` is `premium` and `AppConfig.googlePlayPremiumBasePlanId` is `monthly`;
- startup catalog availability is advisory rather than permanently sticky: every user-initiated new purchase performs a fresh Product ID `premium` query and retries that catalog operation once after a short bounded delay;
- Mobile requires exactly one no-offer catalog entry for Base Plan ID `monthly` and launches the fresh `GooglePlayProductDetails` with the exact offer token supplied on that query;
- missing products, missing or mismatched base plans, promotional offer entries, missing offer tokens, and ambiguous matching entries fail closed without launching the Play purchase UI;
- backend Google Play processing is enabled for the approved controlled license-test context;
- RTDN and reconciliation remain backend infrastructure rather than Mobile configuration;
- the real Play-distributed Internal-testing versionCode 5 completed a controlled license-test purchase: the purchase sheet opened, backend verification succeeded, backend-owned Premium became active, and Admin CMS showed `billingProvider=google_play` and `renewalStatus=renewal_active`;
- this Internal-testing evidence is historical validation, not the current distribution state.

Historical Mobile `0.1.0+8` / versionCode 8 became publicly available in Google Play Production as **Orralen - Language Voice Tutor** on 2026-09-03. The existing v8 Play artifact was selected as the Production candidate, submitted after owner approval, and later confirmed publicly installable. The 2026-09-01 purchase-gate investigation found that affected accounts hid the new-purchase action because the backend correctly returned `googlePlayPurchaseAllowed=false` for ten legacy pre-Live local Paddle rows still marked active after their locally known July end dates. After a fresh backup, a controlled two-row change and guarded cleanup repaired those stale local statuses (six to `expired`, two locally scheduled cancellations to `canceled`) without deleting rows or changing payment/provider/event history. It was a one-time production-data repair, not a change to the backend gate or Mobile runtime: uncertain live external renewal ownership still fails closed to prevent double billing.

Historical Mobile `0.1.0+10` / versionCode 10 from source `3389786c16d676dae2a66a9cdf73367780babcad` became publicly active in Google Play Production on 2026-09-20. V10 did not change or newly validate the billing architecture, and historical controlled billing evidence is not relabeled as v10 testing.

Last confirmed publicly active Mobile `0.1.0+11` / versionCode 11 from source `1113a4c09ee75021a435f67dceee8b7b55ba1160` became publicly active in Google Play Production as **Orralen - Language Voice Tutor** as of 2026-09-27. V11 did not change or newly validate Product ID `premium`, Base Plan ID `monthly`, backend-owned Premium authority, purchase verification, acknowledgement ownership, RTDN, reconciliation, trial behavior, or fail-closed purchase rules. Earlier controlled purchase, renewal, expiry, and real-money first-purchase evidence remains historical evidence, not v11 billing lifecycle validation. Signed-out password recovery was first distributed publicly in v8 and remains present in v11.

Current Mobile source is `a75f8b308c400b895a2a708bc9320f208ae033f7` / `0.1.0+12` / versionCode 12. V12 has been submitted to the Google Play Production release path and is under Google review as of 2026-10-02; it is not yet confirmed publicly active. V11 remains the last confirmed publicly active Android release until Google approval and rollout availability are verified. This distribution checkpoint claims no new v12 billing validation.

License testing is now isolated in Play Console to the dedicated `pay` list with one intended tester, rather than the broad Internal Testers list. The 2026-09-01 real-money first purchase was completed by an account outside that list using normal payment methods; the normal receipt completed, backend-confirmed Premium was active in Mobile and Admin CMS, and fresh provider-management state showed active auto-renew with next payment on 2026-10-08. The existing backend-owned registration trial and continuous Premium coverage were preserved by the initial Premium/trial deferral mechanism, extending the provider-backed Premium tail to 2026-10-08. This is not a Google Play trial or introductory offer: the Google Play `monthly` base plan still has neither. The post-deferral provider state, not a purchase-time receipt baseline date, is the final verified schedule. Existing controlled license-test purchase, renewal, reconciliation, and final-expiry evidence remains valid.

The earlier catalog-visibility / `configuration_invalid` blocker is closed. The initial controlled purchase, subsequent accelerated license-test renewals, and final expiry proved the core path: new purchase -> backend Premium -> backend reconciliation refreshes Google Play subscriptions-v2 authoritative state across renewals -> final expiry -> backend Free -> new-purchase eligibility restored. A few-second transient Free window was observed at accelerated renewal boundaries before reconciliation refreshed state. It is a known non-blocking controlled-test observation, not a production outage or a defect reproduced under a normal monthly billing period; no backend redesign was chosen solely for that observation.

The approved Google Play Product ID is `premium` and Base Plan ID is `monthly`. Mobile does not activate or mutate Play Console products or base plans. No Google Play free trial, introductory offer, annual subscription, or second product is configured by Mobile; the seven-day registration trial remains backend-owned.

New purchase and restore are intentionally separate. A startup store/catalog failure does not suppress a later user-initiated refresh attempt. After a fresh valid catalog entry is selected, the coordinator re-fetches the authenticated additive backend gate immediately before `launchSubscriptionOffer`; missing, stale, invalid, blocked, or unavailable status prevents the store call. Persistent catalog failure after the two bounded user attempts shows a temporary-unavailable message. Restore rechecks store availability and restored-token verification continues through its existing backend path without consulting new-purchase catalog eligibility or the new-purchase gate.

## Post-release lifecycle monitoring

Historical controlled license-test purchase, renewal, and final expiry are proven. The 2026-09-01 real-money first purchase and backend-owned initial Premium/trial deferral are also proven. Android v11 remains the last confirmed publicly active Production release while v12 is submitted and under Google review; the v8/v9/v10 checkpoints remain historical; remaining lifecycle evidence is post-release monitoring, not a v11 validation claim. Actual real-money renewal scheduled for 2026-10-08, pending-payment handling, explicit cancellation before natural expiry, restore on a fresh installation, production refund/voided-purchase lifecycle, real chargeback lifecycle, and provider-isolation edge cases beyond existing automated/backend coverage remain unobserved.

This is now post-release monitoring: periodically re-review legal/public-policy wording, Google Play Data Safety, test-only controls (including keeping `TestPurchasesEnabled=false` and the temporary allowlist cleared), Pending Refund Review failures and refund lifecycle evidence, and rollback readiness. Signed-out password recovery was first distributed in public `0.1.0+8` / versionCode 8 and remains present in public `0.1.0+11` / versionCode 11; v12 is already submitted and under Google review, and any next future upload requires a separately approved Mobile artifact change using versionCode at least 13. Targeted Play-installed smokes remain appropriate after future changes.

Historical v11 Production publication is complete; v12 remains under Google review; Product ID `premium` and active Base Plan ID `monthly` are unchanged and recorded here. No credential, Pub/Sub name, price, currency, or other sensitive production value is defined by this document.

## Commercial mapping rule

Google Play must map to the same existing Language Voice Tutor Premium commercial product used across clients. It must not introduce a separate Mobile tariff, plan, entitlement type, or Google-specific Premium authority. This plan does not define or propose an annual subscription. Billing period, price, currency, and external identifiers must come from the separately approved existing commercial configuration and Play Console setup; they must not be inferred or invented in repository documentation.

## Permanent client boundaries

Mobile must not:

- treat a Play callback, purchase token, verification result, or local cache as Premium entitlement;
- persist a local Premium grant in preferences, secure storage, or a local database;
- acknowledge or complete Google purchases locally;
- store provider/backend credentials or secrets;
- bypass authenticated backend verification or backend `SubscriptionStatus`;
- change Paddle, trial, or manual-admin entitlement behavior.
