# Conversation-mode tutor GIFs

This folder is reserved for future fullscreen conversation-mode GIF assets.

## Scope

- Mode: fullscreen conversation mode
- Layout target: portrait conversation screen
- Tutors: `lana`, `nelli`, `david`
- Desktop-aligned core states: `idle`, `listening`, `thinking`, `speaking`, `transcribing`

## Recommended size

- Aspect ratio: `9:16`
- Recommended export size: `1080x1920`
- Safe center area: keep the face and upper torso inside the middle `810x1440`

## Naming

Use lowercase snake case:

- `lana_idle.gif`
- `lana_listening.gif`
- `lana_thinking.gif`
- `lana_speaking.gif`
- `lana_transcribing.gif`
- `nelli_idle.gif`
- `nelli_listening.gif`
- `nelli_thinking.gif`
- `nelli_speaking.gif`
- `nelli_transcribing.gif`
- `david_idle.gif`
- `david_listening.gif`
- `david_thinking.gif`
- `david_speaking.gif`
- `david_transcribing.gif`

## Notes

- Do not register these folders in `pubspec.yaml` until real assets are added if Flutter build tooling objects to empty asset directories.
- Conversation-mode assets should preserve portrait framing and leave room for future overlay controls near the lower portion of the screen.
