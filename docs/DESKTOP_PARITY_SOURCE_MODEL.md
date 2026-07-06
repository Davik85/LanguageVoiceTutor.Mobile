# Desktop Parity Source Model

## Status

The reviewed Windows desktop client walkthrough presentation is now a product reference source for mobile parity. Mobile parity means preserving the desktop product flow, product decisions, and backend-owned state boundaries; it does not mean copying the Windows pixel layout directly.

Latest known mobile baseline after commit `fcecef5` (`Fix mobile settings parity foundation`):

- Mobile Settings parity foundation is fixed.
- `dart format --set-exit-if-changed lib test` passed.
- `flutter analyze` returned `No issues found`.
- `flutter test` returned `All tests passed`.
- Settings has stable visible sections: **Account**, **Learning**, **Audio**, and **Backend diagnostics**.
- **Save settings** is visible and tested.
- User level is not in Settings.
- **Open Lesson** remains a placeholder.
- `selectedTutorId` is not sent to `PUT /api/me/settings`.
- Selected tutor avatar persistence remains a backend/API gap unless an existing backend-supported API is later confirmed.

## Product parity rule

Mobile must match desktop product logic, not desktop pixel layout. Desktop screens should be translated into phone-first layouts that fit mobile navigation, scrolling, touch targets, platform permissions, and smaller displays.

The desktop source flow is:

```text
Start -> Settings/preferences -> Choose level -> Pick topic -> Pick situation -> Practice
```

Level selection must remain a separate lesson-start step before topic/situation selection. It must not be moved into Settings.

## Settings parity target

Settings parity should gradually cover desktop-equivalent product concepts where the backend contract supports them:

- Profile / learning goal.
- Study language.
- Native language.
- Interface/explanation language.
- Tutor avatar.
- Tutor voice.
- Account/subscription.
- Audio.
- Progress.

Study language, native language, and interface/explanation language are separate concepts.

Current backend-supported mobile settings fields from `GET /api/me/settings` and `PUT /api/me/settings` are:

- `nativeLanguage`
- `studyLanguage`
- `explanationLanguage`
- `speechVoice`
- `speechSpeed`
- `conversationModeEnabled`

Current visible mobile Settings sections are:

- **Account**
- **Learning**
- **Audio**
- **Backend diagnostics**

`selectedTutorId` is not part of the current settings contract. `GET /api/tutor-options` can provide available tutors, but mobile must not document or implement fake local selected-tutor persistence as the source of truth.

## Language catalogs

Supported study languages remain:

- English
- French
- German
- Portuguese
- Spanish
- Italian

Release-ready interface languages remain:

- `en`
- `es`
- `fr`
- `de`
- `it`
- `pt`
- `ru`
- `pl`
- `ar`
- `ja`
- `ko`
- `sr`
- `hr`
- `bg`

The native/explanation language catalog is broader than the study-language catalog and broader than the release-ready interface-language catalog.

## Tutor model

Tutor profiles currently represented by desktop are:

- Lana
- Nelli
- David

Tutor choice is product-significant. It affects display name, profile/persona, and preferred voice behavior in lessons.

Selected tutor avatar persistence is not currently supported by `/api/me/settings`; it remains an API/product gap unless another existing backend-supported endpoint is confirmed.

## Backend-owned state boundaries

Account, subscription, and progress must remain backend-owned. Mobile must not create mobile-only Premium, limits, history, progress, or subscription state.

## Lesson Chat parity target

Lesson Chat parity should include:

- Text input.
- Voice recording.
- Hints.
- Translation.
- TTS/play voice.
- Conversation mode.
- Finish lesson and summary/history flow.

Conversation mode should reuse the same lesson flow concept:

```text
record speech -> transcribe audio -> generate lesson reply -> display and speak the same text -> keep transcript for review
```

Lesson runtime, voice recording, TTS playback, billing, analytics, Google Play Billing, and Apple billing remain out of scope for the current documentation update.
