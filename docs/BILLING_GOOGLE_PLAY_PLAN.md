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
- regression coverage proving that verification does not create Premium locally.

For `verified`, persistence and backend-owned acknowledgement succeeded. For `acknowledgement_pending`, verified entitlement persistence succeeded while backend acknowledgement retry remains pending. Mobile calls neither Google Play acknowledgement nor `completePurchase`; it refreshes and displays only backend-confirmed subscription state.

## Intentionally disabled production/runtime state

The implemented foundation is not an enabled Google Play sales channel:

- production Mobile still composes `UnavailablePremiumPurchaseAdapter`;
- no real Google Play product ID or base-plan ID is connected to Mobile runtime configuration;
- backend Google Play processing remains disabled in production;
- production Google service-account/Data Protection configuration is not enabled;
- production RTDN/Pub/Sub configuration is not enabled;
- no real Google Play sandbox purchase has validated the end-to-end path;
- no Google Play billing rollout has occurred.

The presence of adapter, verification, acknowledgement, reconciliation, and lifecycle code must not be described as production enablement or sandbox validation.

## Remaining prerequisites before a controlled sandbox purchase

1. Configure the existing Premium subscription and base plan in Play Console.
2. Map the approved Google Play product ID into runtime configuration without hardcoding or inventing identifiers.
3. Provision the backend Google service-account credentials and required Google API/Data Protection access through approved production-secret handling.
4. Configure and validate RTDN/Pub/Sub production resources without exposing topic, credential, or token values in Mobile.
5. Enable the real Mobile Google Play adapter and backend Google Play runtime through a separately reviewed configuration change.
6. Confirm the approved license tester, test track, pending-purchase, cancellation, restore, and lifecycle validation procedure.
7. Run one controlled sandbox purchase and verify token submission, backend acknowledgement, entitlement/status refresh, restore, RTDN/reconciliation, and provider isolation before considering rollout.

Production rollout remains a later, separately approved step after controlled sandbox evidence. No product ID, base-plan ID, credential, Pub/Sub name, price, currency, or production value is defined by this document.

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
