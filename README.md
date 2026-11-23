# Netlify Music

A cross-platform music app built with Flutter, using Netlify's orange-and-black visual identity.

## Current status

The responsive Flutter UI includes:
- Home, Search and Library navigation
- YouTube search through a Supabase Edge Function
- Search results with titles, channel names and thumbnails
- Official YouTube embedded playback inside the app
- YouTube's own player controls and fullscreen support

The original sample tracks and visual player are still demo content until a provider integration is selected for them. YouTube playback is provided by the official YouTube IFrame Player API; it is not an audio downloader.

## YouTube search setup

The app calls the Supabase Edge Function:

`https://nraxrduredxbswmvoijy.supabase.co/functions/v1/youtube-search`

The YouTube API key must remain stored as the `YOUTUBE_API_KEY` Supabase Function secret. Never put it in Flutter code or commit it to GitHub.

## YouTube playback

The app uses the `youtube_player` Flutter package, which embeds the official YouTube IFrame Player API. YouTube player branding, controls, ads, links and other required functionality must remain available. The package currently requires Dart 3.14+ and Flutter 3.50+.

## Run locally

1. Install Flutter 3.50 or newer: https://docs.flutter.dev/get-started/install
2. From this repository root, run `flutter pub get`
3. Run on a connected device or emulator: `flutter run`

## Build targets

Flutter can build Android, iOS, Windows, macOS, Linux and web. Each target needs its platform toolchain; iOS and macOS builds require macOS and Xcode.

## Provider requirements

Playback and metadata must use each provider's approved API/player and comply with its terms, including any required attribution and branding.

## In-app update system

The app checks the latest GitHub Release on startup and from the update icon in the top bar. When a newer semantic version is published, it offers the official release page.

The GitHub Actions workflow publishes the Windows package and web bundle as a rolling release. To publish a new app version, increment the `version:` value in `pubspec.yaml` (for example, `1.0.1+2` to `1.0.2+3`) and push to `main`. The release tag is generated from the version before the `+` build number.

### Platform update notes

- **Windows:** The app opens the official release downloads. Close the app and replace the old app folder with the newly extracted package.
- **Web:** Deploy the new web bundle to the chosen host; users receive it on refresh.
- **Android:** A permanent Android signing key is required before safe in-place APK updates can be published. Do not change the signing key after the first public release.
- **iOS/macOS/Linux:** Store signing, notarization or package-specific distribution still needs to be configured before one-click in-app installation can be offered.

The current updater is a version checker and download handoff; it does not silently install software or bypass operating-system security prompts.

