# Project Instructions

## Project

This is a Flutter application for a location-based touring game. It uses
Firebase Authentication, Cloud Firestore, Firebase Storage, OpenStreetMap
search, device location, image picking, web views, and persisted theme
preferences.

Before making changes:

- inspect the existing implementation and all affected callers
- follow the established project structure and naming conventions
- preserve user changes already present in the working tree
- prefer focused changes over unrelated refactors

## Architecture

Preserve the current layered organization unless an architectural change is
explicitly requested:

```text
lib/
  models/       domain and database-facing models
  services/     state management, service facades, providers, repositories
  utilities/    shared UI helpers, routes, themes, dialogs, and map utilities
  views/        authentication and game screens
```

The established dependency flow is:

```text
view/widget -> Bloc -> repository contract -> service contract -> external SDK/client
```

Repository contracts belong at the application boundary. Concrete
repositories own domain mapping, orchestration, and error translation;
stateless services own Firebase, HTTP, storage, and platform SDK integration.
Inject contracts from the app root; do not instantiate infrastructure in
widgets or Blocs. Keep providers stateless and avoid mutable singleton caches.

Do not reorganize the project into feature-first, clean architecture, or
another structure without an explicit request and migration plan.

## State Management

Use `bloc` and `flutter_bloc`.

- Keep one focused Bloc or Cubit per screen/feature responsibility under
  `lib/services/**/bloc/`; do not recreate a broad application-wide Bloc.
- Provide Blocs with `BlocProvider` and render state with `BlocBuilder` or
  `BlocConsumer`, matching nearby code.
- Dispatch one-time initialization and loading events when a Bloc is created
  or from a guarded widget lifecycle method, never unconditionally from
  `build()`.
- Keep asynchronous work and business decisions in Blocs and services rather
  than directly in widgets.
- Preserve loading, success, empty, and error state behavior when changing a
  flow. Await writes before emitting a successful state, and never emit a
  success state after a failed operation.
- Bloc events are concurrent by default. Select `restartable`, `droppable`, or
  `sequential` from `bloc_concurrency` according to the operation; mutations
  whose order matters must be sequential.
- Keep states immutable and value-comparable. Expose collection state through
  unmodifiable lists.

Do not introduce Riverpod, Provider, GetX, or another state-management system
unless explicitly requested.

## Navigation

The app uses `go_router` with centralized paths and typed route arguments from
`lib/utilities/routes.dart`.

- Add routes to the root `GoRouter` configuration.
- Keep route paths centralized in `lib/utilities/routes.dart`.
- Use typed route-argument objects; do not pass positional `List<dynamic>`
  payloads between screens.
- Use `BuildContext` navigation extensions from `go_router`; do not add new
  `Navigator.pushNamed` flows.

## Services and External Integrations

- Authentication uses the `AuthRepository` contract and
  `FirebaseAuthRepository` implementation over injected Firebase services.
- Game data uses the `GameRepository` contract and
  `FirebaseGameRepository` implementation over injected Firestore and Storage
  services.
- Map and location access use `PlaceSearchRepository` and
  `LocationRepository` contracts.
- Image selection uses `ImagePickerRepository`; widgets must not instantiate
  `ImagePicker` directly.
- Theme persistence uses `ThemeRepository`; `ThemeBloc` does not access
  `shared_preferences` directly.

Keep external exceptions contained at provider boundaries. Convert them to
typed `AppException` subclasses before presenting them in the UI.

Do not change Firebase project identifiers, generated Firebase options,
Android application identifiers, permissions, or backend collection paths
without an explicit requirement.

## Models

Models currently use explicit Dart constructors and manual `fromJson` mapping.
Follow those conventions for focused changes.

Keep domain models immutable and independent of Flutter widgets, Firebase
types, platform file objects, and map-library coordinate types. Convert those
types at infrastructure or presentation boundaries.

Do not add Freezed, json_serializable, code generation, or a new model layer
unless the task justifies a project-wide migration.

## Flutter and Widget Lifecycle

Follow `flutter_lints` and the component patterns already used in the project.
Pay particular attention to:

- controller, stream, subscription, and other resource disposal
- avoiding state changes and event dispatches as side effects of `build()`
- guarding work performed from `didChangeDependencies()`
- checking `BuildContext.mounted` after asynchronous gaps when context is used
- avoiding unnecessary rebuilds and nested `setState()` calls
- handling denied and permanently denied location permissions
- maintaining loading and error feedback for Firebase and network operations

Prefer current, non-deprecated Flutter APIs when modifying nearby code.

## Dependencies and Android Toolchain

- Use Flutter or Dart package commands to update `pubspec.lock`; do not edit the
  lock file manually.
- Prefer upgrades within current constraints before proposing major dependency
  migrations.
- Keep Android Gradle Plugin, Gradle, Kotlin, Java, compile SDK, target SDK, and
  NDK versions mutually compatible and aligned with the installed stable
  Flutter template.
- For Android build changes, verify with a debug APK build.
- Do not commit local SDK paths, Gradle caches, build outputs, or ephemeral
  plugin symlinks.

## Testing

Add meaningful tests for changed behavior when practical.

- Follow the existing `test/` organization and `flutter_test` conventions.
- Prefer behavioral tests of state transitions, model mapping, and visible
  outcomes over tests of implementation details.
- Use fakes or provider/service contracts instead of live Firebase or network
  access in automated tests.
- Add regression coverage when fixing a reproducible defect.

## Validation

Before considering an implementation complete, run:

```text
dart format <changed Dart files>
flutter analyze
flutter test
```

For Android or dependency changes, also run:

```text
flutter build apk --debug
```

Run `git diff --check` before handoff. If a required command fails, report the
failure and do not claim full completion.

## Change Scope and Git

Keep diffs focused on the requested task. Do not:

- perform unrelated refactors
- replace established architecture without explicit approval
- add dependencies unless they are necessary
- rewrite working code solely for stylistic preference
- overwrite or discard unrelated working-tree changes
- commit generated caches, local environment files, or build artifacts

Do not create commits unless the user asks. When commits are requested, group
changes by logical purpose and stage only reviewed files.

## Codex Skills

Use the available Flutter skills for non-trivial work:

- `flutter-architect`: inspect conventions and plan architectural changes or
  significant refactors before implementation
- `flutter-coder`: implement non-trivial Flutter features and fixes using the
  existing architecture
- `flutter-tester`: independently investigate defects, add behavioral tests,
  and verify changes when dedicated testing is requested
- `flutter-reviewer`: perform an independent senior review when review is the
  requested outcome
- `flutter-feature-workflow`: coordinate architecture, implementation,
  independent testing, and review for end-to-end feature delivery

Routine, isolated documentation or configuration edits do not require a
multi-stage workflow unless the user requests one.
