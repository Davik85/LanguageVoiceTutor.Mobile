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

## Controlled closed-testing runtime state

The single normal Mobile runtime now uses the implemented Google Play path:

- normal application composition creates `GooglePlayPremiumPurchaseAdapter` without a build flag, flavor, or alternate entrypoint;
- `AppConfig.googlePlayPremiumProductId` is `premium` and `AppConfig.googlePlayPremiumBasePlanId` is `monthly`;
- startup catalog availability is advisory rather than permanently sticky: every user-initiated new purchase performs a fresh Product ID `premium` query and retries that catalog operation once after a short bounded delay;
- Mobile requires exactly one no-offer catalog entry for Base Plan ID `monthly` and launches the fresh `GooglePlayProductDetails` with the exact offer token supplied on that query;
- missing products, missing or mismatched base plans, promotional offer entries, missing offer tokens, and ambiguous matching entries fail closed without launching the Play purchase UI;
- backend Google Play processing is enabled separately for the controlled sandbox test, with test-purchase verification restricted on the backend to the approved test user;
- RTDN is configured separately and remains backend infrastructure rather than Mobile configuration;
- no real Google Play sandbox purchase has validated the end-to-end path;
- no public production rollout has occurred.

The runtime composition change must not be described as completed sandbox validation or public production rollout.

The approved Google Play Product ID is `premium` and Base Plan ID is `monthly`. Mobile does not activate or mutate Play Console products or base plans. No Google Play free trial, introductory offer, annual subscription, or second product is configured by Mobile; the seven-day registration trial remains backend-owned.

New purchase and restore are intentionally separate. A startup store/catalog failure does not suppress a later user-initiated refresh attempt. After a fresh valid catalog entry is selected, the coordinator re-fetches the authenticated additive backend gate immediately before `launchSubscriptionOffer`; missing, stale, invalid, blocked, or unavailable status prevents the store call. Persistent catalog failure after the two bounded user attempts shows a temporary-unavailable message. Restore rechecks store availability and restored-token verification continues through its existing backend path without consulting new-purchase catalog eligibility or the new-purchase gate.

## Remaining controlled sandbox validation

1. Confirm the approved license tester can see Product ID `premium` and its Base Plan ID `monthly` from the closed-testing install.
2. Run one controlled sandbox purchase and verify token submission, backend acknowledgement, and backend-owned entitlement/status refresh.
3. Validate pending purchase, cancellation, restore, RTDN/reconciliation, lifecycle handling, and provider isolation against sandbox state.
4. Record the controlled evidence before considering any broader rollout.

Production rollout remains a later, separately approved step after controlled sandbox evidence. Apart from approved Product ID `premium` and draft Base Plan ID `monthly`, no credential, Pub/Sub name, price, currency, or production value is defined by this document.

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
