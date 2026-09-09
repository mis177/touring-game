import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:touring_game/models/activity.dart';
import 'package:touring_game/models/coordinates.dart';
import 'package:touring_game/services/game/bloc/catalog/catalog_bloc.dart';
import 'package:touring_game/services/game/bloc/catalog/catalog_event.dart';
import 'package:touring_game/services/game/game_repository.dart';

import '../helpers/fake_game_repository.dart';

void main() {
  test(
    'catalog failure preserves an error state without false success',
    () async {
      final failure = Exception('catalog failed');
      final bloc = CatalogBloc(FakeGameRepository(catalogError: failure));

      bloc.add(const CatalogLoadRequested());
      final state = await bloc.stream.firstWhere(
        (state) => state.exception != null,
      );

      expect(state.exception, same(failure));
      expect(state.isLoading, isFalse);
      await bloc.close();
    },
  );

  test('suggestions are selected once and survive search rebuilds', () async {
    final activities = List.generate(
      4,
      (index) => DatabaseActivity(
        id: '$index',
        name: 'Activity $index',
        webUrl: 'https://example.com',
        isDone: false,
        coords: const Coordinates(latitude: 1, longitude: 2),
        placeId: 'place',
      ),
    );
    final bloc = CatalogBloc(
      FakeGameRepository(
        catalog: GameCatalog(places: const [], activities: activities),
      ),
      random: Random(1),
    );

    bloc.add(const CatalogLoadRequested());
    final loaded = await bloc.stream.firstWhere(
      (state) => !state.isLoading && state.activities.isNotEmpty,
    );
    bloc.add(const CatalogSearchChanged('missing'));
    final searched = await bloc.stream.firstWhere((state) => state.query != '');

    expect(loaded.suggestedActivities, hasLength(3));
    expect(searched.suggestedActivities, loaded.suggestedActivities);
    await bloc.close();
  });
}
