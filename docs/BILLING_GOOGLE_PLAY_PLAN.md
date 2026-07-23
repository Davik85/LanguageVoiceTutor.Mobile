# Google Play Billing Plan

## Billing model

## Mobile adapter foundation

Mobile includes a Google Play adapter foundation, but it remains disabled: production composes `UnavailablePremiumPurchaseAdapter` and cannot open billing. Real activation still requires Play Console product configuration, backend token verification, post-verification acknowledgment, restoration/reconciliation, and RTDN. No product IDs or live billing configuration are present.

Google Play Billing must be implemented as a client-to-backend verification bridge, not as a client-side entitlement system.

Premium UI and Google Play Billing are separate implementation stages. First add complete learner-facing Premium UI and purchase entry points; then add the Billing bridge. A Premium button, local purchase callback, or Google Play result never grants Premium. Google Play Billing is complete only when purchase-token submission, backend verification, entitlement refresh, restore/reconciliation, and relevant subscription lifecycle states are implemented. Paddle remains unchanged for website/desktop, and Google Play purchases map through the shared provider-neutral backend entitlement model so valid Premium remains visible to other clients.

The mobile app may initiate a Google Play purchase and receive a purchase token from Google Play. The app must send that purchase token to the Language Voice Tutor backend. The backend verifies the purchase with Google, reconciles the account, updates entitlement state, and returns authoritative subscription status through backend APIs.

## Required flow

1. User starts a purchase in the Android app.
2. Google Play returns purchase information to the app.
3. Mobile sends the purchase token and required product metadata to the backend over HTTPS.
4. Backend verifies the purchase token with Google Play APIs.
5. Backend maps the verified purchase to the authenticated Language Voice Tutor account.
6. Backend updates subscription and entitlement state.
7. Mobile refreshes subscription status from backend.
8. Mobile displays the backend-confirmed entitlement state.

## Rules

The mobile app must not:

- Treat a local Google Play purchase callback as Premium entitlement by itself.
- Decide subscription status locally.
- Store Google Play API secrets.
- Store backend billing secrets.
- Store Paddle secrets.
- Store Apple secrets.
- Bypass backend verification.

## Backend responsibilities

Backend remains responsible for:

- Google Play purchase token verification.
- Product and subscription mapping.
- Duplicate purchase handling.
- Account entitlement updates.
- Cross-provider subscription reconciliation.
- Refund, cancellation, grace-period, hold, pause, expiration, and renewal state.
- Webhook or real-time developer notification handling if used.

## Mobile responsibilities

Mobile is responsible for:

- Initiating Google Play purchase UI when billing runtime is added.
- Receiving purchase token from Google Play Billing APIs.
- Sending token to backend while authenticated.
- Showing pending, success, and failure states.
- Refreshing entitlement from backend after verification.
- Offering restore/recheck actions that call backend reconciliation paths.

## Open decisions

Before adding billing runtime code, confirm:

- Product IDs and subscription base plans.
- Backend endpoint for purchase-token submission.
- Required request fields.
- Backend response shape.
- Pending purchase behavior.
- Restore purchase behavior.
- Grace period and account-hold UI states.
- Sandbox tester workflow.
- Whether desktop Paddle subscriptions and Google Play subscriptions can coexist or need conflict handling.
