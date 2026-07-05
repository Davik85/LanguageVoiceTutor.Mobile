# Testing Checklist

## Docs-only foundation checks

- Confirm no Flutter app files were created.
- Confirm no Android project files were created.
- Confirm no iOS project files were created.
- Confirm no runtime code was added.
- Confirm no secrets were added.
- Confirm repository documents state the backend source-of-truth model.

## Pre-skeleton checks

Before creating the Flutter skeleton, verify:

- Backend base URL strategy is approved.
- Auth/session contract is documented.
- `/api/me` and settings contracts are confirmed.
- Subscription-status contract is confirmed.
- Lesson-access contract is confirmed.
- Lesson start/message/history/progress contracts are confirmed.
- Voice upload and TTS contracts are confirmed.
- Android minimum SDK and target SDK are confirmed.
- Flutter version/channel is confirmed.

## Future Flutter checks

After runtime code exists, add checks for:

- Flutter formatting.
- Static analysis.
- Unit tests.
- Widget tests.
- Integration tests against mocked backend contracts.
- Secure storage behavior.
- Expired session handling.
- Offline and retry states.
- Audio permission handling.
- Voice upload errors.
- TTS playback errors.

## Future billing checks

After Google Play Billing runtime code exists, add checks for:

- Sandbox purchase success.
- Pending purchase state.
- Purchase cancellation.
- Purchase token backend submission.
- Backend verification success.
- Backend verification failure.
- Entitlement refresh after purchase.
- Restore or reconciliation flow.
- Grace period, account hold, cancellation, and expiration states.

## Future release-readiness checks

Before any store release:

- Confirm privacy policy requirements.
- Confirm data safety disclosures.
- Confirm microphone permission rationale.
- Confirm account deletion requirements.
- Confirm crash reporting and analytics consent behavior.
- Confirm production backend environment configuration.
- Confirm no secrets are present in the app bundle or repository.
