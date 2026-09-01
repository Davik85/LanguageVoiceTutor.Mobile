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

## Controlled Internal-testing runtime state (updated 2026-09-01)

The single normal Mobile runtime uses the implemented Google Play path, with no billing flavor, duplicate runtime, or local Premium authority. Controlled production configuration has `GooglePlayBilling.Enabled=true`, `GooglePlayRtdn.Enabled=true`, and `GooglePlayReconciliation.Enabled=true`; pending-refund review remains disabled unless separately verified. Product ID is `premium`, Base Plan ID is `monthly`, `monthly` is active, and there is no Google Play free trial or introductory offer.

- normal application composition creates `GooglePlayPremiumPurchaseAdapter` without a build flag, flavor, or alternate entrypoint;
- `AppConfig.googlePlayPremiumProductId` is `premium` and `AppConfig.googlePlayPremiumBasePlanId` is `monthly`;
- startup catalog availability is advisory rather than permanently sticky: every user-initiated new purchase performs a fresh Product ID `premium` query and retries that catalog operation once after a short bounded delay;
- Mobile requires exactly one no-offer catalog entry for Base Plan ID `monthly` and launches the fresh `GooglePlayProductDetails` with the exact offer token supplied on that query;
- missing products, missing or mismatched base plans, promotional offer entries, missing offer tokens, and ambiguous matching entries fail closed without launching the Play purchase UI;
- backend Google Play processing is enabled for the approved controlled license-test context;
- RTDN and reconciliation remain backend infrastructure rather than Mobile configuration;
- the real Play-distributed Internal-testing versionCode 5 completed a controlled license-test purchase: the purchase sheet opened, backend verification succeeded, backend-owned Premium became active, and Admin CMS showed `billingProvider=google_play` and `renewalStatus=renewal_active`;
- no public production rollout has occurred.

Mobile remains `0.1.0+8` / versionCode 8 from Google Play Internal testing; this operational checkpoint requires no versionCode 9. The 2026-09-01 purchase-gate investigation found that affected accounts hid the new-purchase action because the backend correctly returned `googlePlayPurchaseAllowed=false` for ten legacy pre-Live local Paddle rows still marked active after their locally known July end dates. After a fresh backup, a controlled two-row change and guarded cleanup repaired those stale local statuses (six to `expired`, two locally scheduled cancellations to `canceled`) without deleting rows or changing payment/provider/event history. It was a one-time production-data repair, not a change to the backend gate or Mobile runtime: uncertain live external renewal ownership still fails closed to prevent double billing.

License testing is now isolated in Play Console to the dedicated `pay` list with one intended tester, rather than the broad Internal Testers list. The 2026-09-01 real-money first purchase was completed by an account outside that list using normal payment methods; the normal receipt completed, backend-confirmed Premium was active in Mobile and Admin CMS, and fresh provider-management state showed active auto-renew with next payment on 2026-10-08. The existing backend-owned registration trial and continuous Premium coverage were preserved by the initial Premium/trial deferral mechanism, extending the provider-backed Premium tail to 2026-10-08. This is not a Google Play trial or introductory offer: the Google Play `monthly` base plan still has neither. The post-deferral provider state, not a purchase-time receipt baseline date, is the final verified schedule. Existing controlled license-test purchase, renewal, reconciliation, and final-expiry evidence remains valid.

The earlier catalog-visibility / `configuration_invalid` blocker is closed. The initial controlled purchase, subsequent accelerated license-test renewals, and final expiry proved the core path: new purchase -> backend Premium -> backend reconciliation refreshes Google Play subscriptions-v2 authoritative state across renewals -> final expiry -> backend Free -> new-purchase eligibility restored. A few-second transient Free window was observed at accelerated renewal boundaries before reconciliation refreshed state. It is a known non-blocking controlled-test observation, not a production outage or a defect reproduced under a normal monthly billing period; no backend redesign was chosen solely for that observation.

The approved Google Play Product ID is `premium` and Base Plan ID is `monthly`. Mobile does not activate or mutate Play Console products or base plans. No Google Play free trial, introductory offer, annual subscription, or second product is configured by Mobile; the seven-day registration trial remains backend-owned.

New purchase and restore are intentionally separate. A startup store/catalog failure does not suppress a later user-initiated refresh attempt. After a fresh valid catalog entry is selected, the coordinator re-fetches the authenticated additive backend gate immediately before `launchSubscriptionOffer`; missing, stale, invalid, blocked, or unavailable status prevents the store call. Persistent catalog failure after the two bounded user attempts shows a temporary-unavailable message. Restore rechecks store availability and restored-token verification continues through its existing backend path without consulting new-purchase catalog eligibility or the new-purchase gate.

## Remaining validation before broader rollout

Historical controlled license-test purchase, renewal, and final expiry are proven. The 2026-09-01 real-money first purchase and backend-owned initial Premium/trial deferral are also proven. They do not prove the actual real-money renewal charge scheduled for 2026-10-08, pending-payment handling, explicit cancellation before natural expiry, restore on a fresh installation, refund/voided-purchase lifecycle, chargeback lifecycle, broad public rollout, or provider-isolation edge cases beyond existing automated/backend coverage.

Before public rollout, re-review legal/public-policy wording and Google Play Data Safety, review test-only production controls (including `TestPurchasesEnabled`), the pending-refund-review decision, monitoring, and rollback readiness. Signed-out password recovery is already in the current `0.1.0+8` / versionCode 8 Internal-testing build; a new upload is needed only for a separately approved Mobile artifact change. Run a Play-installed smoke covering Login, registration, Forgot password, reset completion, normal sign-in, Premium status, basic billing sanity, and key lesson/voice flows. Only after legal, Data Safety, and that smoke is a separate production-rollout decision appropriate.

Production rollout remains a later, separately approved step after controlled Internal-testing evidence. Product ID `premium` and active Base Plan ID `monthly` are recorded here; no credential, Pub/Sub name, price, currency, or other sensitive production value is defined by this document.

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
