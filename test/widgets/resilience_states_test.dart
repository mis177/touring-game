import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:touring_game/core/errors/app_exception.dart';
import 'package:touring_game/models/activity.dart';
import 'package:touring_game/models/coordinates.dart';
import 'package:touring_game/services/game/bloc/catalog/catalog_bloc.dart';
import 'package:touring_game/services/game/bloc/catalog/catalog_event.dart';
import 'package:touring_game/services/game/game_repository.dart';
import 'package:touring_game/utilities/routes.dart';
import 'package:touring_game/views/game/activities/activity_detail_view.dart';
import 'package:touring_game/views/game/places/places_list_view.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../helpers/fake_game_repository.dart';

void main() {
  testWidgets('empty catalog explains that there are no places', (
    tester,
  ) async {
    await tester.pumpWidget(
      BlocProvider(
        create: (_) =>
            CatalogBloc(FakeGameRepository())
              ..add(const CatalogLoadRequested()),
        child: const MaterialApp(home: PlacesList()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No places are available yet.'), findsOneWidget);
  });

  testWidgets('catalog error offers a retry action', (tester) async {
    await tester.pumpWidget(
      BlocProvider(
        create: (_) => CatalogBloc(
          FakeGameRepository(catalogError: const DataException('offline')),
        )..add(const CatalogLoadRequested()),
        child: const MaterialApp(home: PlacesList()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Could not load places.'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('invalid activity URL renders a safe fallback', (tester) async {
    const activity = DatabaseActivity(
      id: 'activity',
      name: 'Invalid page',
      webUrl: 'not a URL',
      isDone: false,
      coords: Coordinates(latitude: 50, longitude: 20),
      placeId: 'place',
    );
    final repository = FakeGameRepository();

    await tester.pumpWidget(
      RepositoryProvider<ActivityProgressRepository>.value(
        value: repository,
        child: MaterialApp(
          home: ActivityDetailsProvider(
            arguments: ActivityDetailsArguments(
              activity: activity,
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('The activity page address is invalid.'), findsOneWidget);
    expect(find.byType(WebViewWidget), findsNothing);
  });
}
