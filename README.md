# flutter_application_2

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

### Firebase CLI workflow

1. Install the Firebase CLI:

```bash
npm install -g firebase-tools
```

2. Log in and select the project:

```bash
firebase login
firebase use nexvolt-c7eaf
```

3. Deploy Firestore rules and indexes:

```bash
firebase deploy --only firestore
```

4. Run the Firestore emulator locally if needed:

```bash
firebase emulators:start --only firestore
```

### FlutterFire config

If you need to regenerate platform configuration, run:

```bash
dart pub global activate flutterfire_cli
dart pub global run flutterfire_cli:flutterfire configure
```

### Run the app

```bash
flutter pub get
flutter run
```

If Firebase is not configured yet, the app falls back to local in-memory data and shows a startup warning.
