# Netlify Music

A cross-platform music app built with Flutter, using Netlify's orange-and-black visual identity.

## Current status

The first UI prototype is in progress. It includes:
- Responsive desktop and mobile layouts
- Home, Search and Library navigation
- Featured music area, sample track cards and recent plays
- Persistent bottom player UI (visual prototype only)

Music API integrations are not connected yet. Sample tracks are demonstration data, not playable licensed audio.

## Run locally

1. Install Flutter: https://docs.flutter.dev/get-started/install
2. From this repository root, run `flutter pub get`
3. Run on a connected device or emulator: `flutter run`

## Build targets

Flutter can build Android, iOS, Windows, macOS, Linux and web. Each target needs its platform toolchain; iOS and macOS builds require macOS and Xcode.

## API integration

Do not commit API secrets to this repository. Add credentials through secure environment configuration or a backend. Playback must use each provider's approved API/player and comply with its terms.
