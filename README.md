# Netlify Music

A cross-platform music app built with Flutter, using Netlify's orange-and-black visual identity.

## Current status

The responsive Flutter UI includes:
- Home, Search and Library navigation
- Responsive desktop and mobile layouts
- YouTube search through a Supabase Edge Function
- Search results with video titles, channel names and thumbnails
- Search results open in the official YouTube app or website

The bottom player and sample tracks are still UI prototypes. In-app audio playback has not been implemented yet.

## YouTube search setup

The app calls the Supabase Edge Function:

`https://nraxrduredxbswmvoijy.supabase.co/functions/v1/youtube-search`

The YouTube API key must remain stored as the `YOUTUBE_API_KEY` Supabase Function secret. Never put it in Flutter code or commit it to GitHub.

## Run locally

1. Install Flutter: https://docs.flutter.dev/get-started/install
2. From this repository root, run `flutter pub get`
3. Run on a connected device or emulator: `flutter run`

## Build targets

Flutter can build Android, iOS, Windows, macOS, Linux and web. Each target needs its platform toolchain; iOS and macOS builds require macOS and Xcode.

## Provider requirements

Playback and metadata must use each provider's approved API/player and comply with its terms, including any required attribution and branding.
