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
