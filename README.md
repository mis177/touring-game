# Touring Game (Visiter)

[![Flutter CI](https://github.com/mis177/touring-game/actions/workflows/flutter_ci.yml/badge.svg)](https://github.com/mis177/touring-game/actions/workflows/flutter_ci.yml)

Visiter is a Flutter portfolio application for discovering places and
completing location-based activities. It demonstrates authentication, maps,
device integrations, resilient asynchronous state, and a testable layered
architecture.

## Try the demo

The demo build starts with a verified sample account and in-memory places,
activities, progress, notes, address search, and location. It does not require
a Firebase project or credentials:

```bash
flutter pub get
flutter run --dart-define=DEMO_MODE=true
```

To prepare an installable Android artifact:

```bash
flutter build apk --debug --dart-define=DEMO_MODE=true
```

Map tiles and activity web pages still need internet access. Image selection
uses the device gallery. Demo changes remain in memory until the application
is restarted.

## Features

- email/password authentication, verification, password reset, and account
  deletion with Firebase Authentication
- Firestore-backed places, activities, completion state, and personal notes
- OpenStreetMap map, device location, and rate-limited Nominatim search
- movable text notes and device-local image notes
- persisted light and dark themes
- explicit loading, empty, validation, offline, and retry states
- an offline-friendly portfolio demo mode selected at build time

## Screenshots

| Authentication | Places | Map | Notes |
| --- | --- | --- | --- |
| ![Authentication screen](https://github.com/mis177/touring-game/assets/56123042/13710feb-dece-46ec-a2b5-eb9939814b00) | ![Places screen](https://github.com/mis177/touring-game/assets/56123042/a9edda5a-49fc-4c71-9779-cb963eb5f1bb) | ![Map screen](https://github.com/mis177/touring-game/assets/56123042/d2667a52-5a9e-439b-ab0e-7b3f26653926) | ![Notes screen](https://github.com/mis177/touring-game/assets/56123042/172fbfe1-51be-4032-81ee-52d186d3bde9) |

## Architecture

The application uses dependency inversion and keeps platform SDKs outside the
presentation and state-management layers:

```text
view/widget -> focused Bloc or Cubit -> repository contract
            -> service contract -> Firebase/platform/HTTP client
```

Dependencies are composed in `lib/main.dart` and injected with
`RepositoryProvider`. Production Firebase repositories can be replaced by
in-memory demo or test implementations without changing widgets or Blocs.

The main source areas are:

```text
lib/models       immutable application models
lib/services     contracts, implementations, and Bloc/Cubit state
lib/utilities    shared UI, routing, map, notes, and error helpers
lib/views        authentication and game screens
```

Notable implementation decisions:

- authentication observes Firebase `userChanges`, so delayed verification or
  restored sessions are reflected in application state
- ordered mutations use appropriate Bloc concurrency transformers
- note locations are persisted as normalized coordinates and survive layout
  or orientation changes
- image files are copied into durable app-local storage; only their note
  metadata is stored in Firestore
- Nominatim requests run only on explicit submission, have a minimum interval,
  and use a bounded in-memory cache
- embedded web content validates URLs and exposes loading, error, retry, and
  external-browser paths

## Production Firebase setup

1. Configure the target Firebase project with FlutterFire CLI.
2. Enable Email/Password in Firebase Authentication.
3. Seed the `places/{placeId}/activities/{activityId}` catalog expected by the
   app.
4. Review the checked-in Firebase rules and extension configuration.
5. Deploy them with:

   ```bash
   firebase deploy --only firestore:rules,extensions --project=YOUR_PROJECT_ID
   ```

The checked-in rules make the catalog read-only for authenticated users and
restrict each user's progress and notes to that user's UID. Image files are
stored only in the application's local documents directory; they are not
uploaded to Firebase and do not synchronize across devices. Firestore stores
only image-note metadata, so an image note opened on another device displays an
unavailable-image placeholder. Uninstalling the app or clearing its data also
removes the images.

`firebase.json` contains local Auth and Firestore emulator configuration. The
official Delete User Data extension recursively removes the user's Firestore
document after Firebase Authentication has successfully deleted the account.
This extension requires a Firebase project on the Blaze plan. Rules and the
deletion flow must be tested against the final backend model before a real
production launch.

## Quality checks

Run locally:

```bash
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze
flutter test
flutter build apk --debug --dart-define=DEMO_MODE=true
```

GitHub Actions performs the same formatting, analysis, test, and demo APK
build checks for pushes and pull requests. Behavioral coverage includes Bloc
state transitions, repository orchestration and rollback, authentication
flows, responsive widgets, resilience states, and a login-to-activities
integration scenario.

Run the integration scenario on a connected device with:

```bash
flutter test integration_test/app_flow_test.dart
```

## Portfolio scope

This repository prioritizes architecture, testability, failure handling, and
a reproducible demo over store-release configuration. A release would still
need a unique application identifier, production signing, privacy/legal
material, accessibility and device-matrix verification, observability, and
Firebase Emulator Suite rule tests.

Do not commit local SDK paths, signing keys, build output, Gradle caches, or
generated platform symlinks.
