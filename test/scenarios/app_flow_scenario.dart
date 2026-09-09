import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:touring_game/models/activity.dart';
import 'package:touring_game/models/coordinates.dart';
import 'package:touring_game/models/place.dart';
import 'package:touring_game/services/game/game_repository.dart';

import '../helpers/fake_app_dependencies.dart';
import '../helpers/fake_game_repository.dart';

Future<void> runLoginToActivitiesFlow(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(430, 932));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final gameRepository = FakeGameRepository(
    catalog: const GameCatalog(
      places: [DatabasePlace(id: 'place-1', name: 'Kraków')],
      activities: [
        DatabaseActivity(
          id: 'activity-1',
          name: 'Wawel Castle',
          webUrl: 'https://example.com',
          isDone: false,
          coords: Coordinates(latitude: 50.054, longitude: 19.935),
          placeId: 'place-1',
        ),
      ],
    ),
  );

  await tester.pumpWidget(
    buildTestApp(
      authRepository: FakeAuthRepository(),
      gameRepository: gameRepository,
    ),
  );
  await tester.pumpAndSettle();

  await tester.tap(find.widgetWithText(OutlinedButton, 'Log In'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField).at(0), 'traveler@example.com');
  await tester.enterText(find.byType(TextField).at(1), 'password');
  await tester.tap(find.widgetWithText(FilledButton, 'Log In'));
  await tester.pumpAndSettle();

  expect(find.text('Kraków'), findsOneWidget);
  await tester.tap(find.text('Kraków'));
  await tester.pumpAndSettle();

  expect(find.text('Activities list'), findsOneWidget);
  expect(find.text('Wawel Castle'), findsOneWidget);
}
