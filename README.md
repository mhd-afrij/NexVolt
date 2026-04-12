# nexvolt

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Google Maps API Setup (EV Station Finder)

Set your Google Maps API key in all platform placeholders below:

1. Android: update `MAPS_API_KEY` in `android/local.properties`
2. iOS: update `MAPS_API_KEY` in `ios/Flutter/Debug.xcconfig` and `ios/Flutter/Release.xcconfig`
3. Web: replace `YOUR_GOOGLE_MAPS_API_KEY` in `web/index.html`

Enable these APIs in Google Cloud Console for your key:

1. Maps SDK for Android
2. Maps SDK for iOS
3. Maps JavaScript API
4. Places API (recommended for search/autocomplete)
5. Geocoding API (optional)

Then run:

```bash
flutter clean
flutter pub get
flutter run
```

### Web-specific note

The web script currently contains `YOUR_GOOGLE_MAPS_API_KEY`. Replace it with a real key and allow your localhost/domain in HTTP referrer restrictions.

To enable map rendering on web, run with:

```bash
flutter run -d chrome --dart-define=ENABLE_WEB_MAPS=true
```

## Firebase Firestore Setup

This app now uses Cloud Firestore as the primary database. On first run it seeds default data into these collections:

- `profiles` (document: `default`)
- `vehicles`
- `stations`
- `charging_activity`

### 1. Configure Firebase for the app

```bash
dart pub global activate flutterfire_cli
dart pub global run flutterfire_cli:flutterfire configure
```

This command generates platform configuration and links Android/iOS/web to your Firebase project.

### 2. Android specific check

Ensure `android/app/google-services.json` exists (created by FlutterFire configure or downloaded from Firebase console).

### 3. iOS specific check

Ensure `ios/Runner/GoogleService-Info.plist` exists.

### 4. Install packages and run

```bash
flutter pub get
flutter run
```

If Firebase is not configured yet, the app falls back to local in-memory data and shows a startup warning.
