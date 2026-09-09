import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:touring_game/core/search_filters.dart';
import 'package:touring_game/models/activity.dart';
import 'package:touring_game/models/address.dart';
import 'package:touring_game/models/coordinates.dart';
import 'package:touring_game/models/note.dart';
import 'package:touring_game/services/game/game_repository.dart';
import 'package:touring_game/services/map/bloc/map_bloc.dart';
import 'package:touring_game/services/map/bloc/map_event.dart';
import 'package:touring_game/services/map/bloc/map_state.dart';
import 'package:touring_game/services/map/location_repository.dart';
import 'package:touring_game/services/map/place_search_repository.dart';

void main() {
  const activity = DatabaseActivity(
    id: 'activity-1',
    name: 'Museum',
    webUrl: 'https://example.com',
    isDone: false,
    coords: Coordinates(latitude: 50, longitude: 20),
    placeId: 'place-1',
  );

  test('location failure keeps the loaded catalog available', () async {
    final failure = Exception('permission denied');
    final bloc = MapBloc(
      gameRepository: const _FakeGameRepository(activity),
      searchRepository: _FakeSearchRepository(),
      locationRepository: _FakeLocationRepository(error: failure),
    );

    bloc.add(const MapEventLoadMap());
    final state =
        await bloc.stream.firstWhere(
              (state) => state is MapStateLoadedMap && state.exception != null,
            )
            as MapStateLoadedMap;

    expect(state.activities, [activity]);
    expect(state.currentLocation, isNull);
    expect(state.exception, same(failure));

    await bloc.close();
  });

  test('a stale address response cannot replace a newer response', () async {
    const firstResult = AddressModel(
      name: 'First',
      coords: Coordinates(latitude: 1, longitude: 1),
    );
    const secondResult = AddressModel(
      name: 'Second',
      coords: Coordinates(latitude: 2, longitude: 2),
    );
    final searchRepository = _FakeSearchRepository();
    final bloc = MapBloc(
      gameRepository: const _FakeGameRepository(activity),
      searchRepository: searchRepository,
      locationRepository: const _FakeLocationRepository(),
    );
    final states = <MapState>[];
    final subscription = bloc.stream.listen(states.add);

    bloc.add(const MapEventSearchAddress(searchedText: 'first'));
    bloc.add(const MapEventSearchAddress(searchedText: 'second'));
    await Future<void>.delayed(Duration.zero);
    searchRepository.requests['second']!.complete(const [secondResult]);
    await bloc.stream.firstWhere(
      (state) =>
          state is MapStateLoadedMap &&
          state.searchResults.contains(secondResult),
    );
    searchRepository.requests['first']!.complete(const [firstResult]);
    await Future<void>.delayed(Duration.zero);

    final results = states.whereType<MapStateLoadedMap>().expand(
      (state) => state.searchResults,
    );
    expect(results, contains(secondResult));
    expect(results, isNot(contains(firstResult)));

    await subscription.cancel();
    await bloc.close();
  });

  test(
    'activity filter is owned by the bloc and toggles exclusively',
    () async {
      final bloc = MapBloc(
        gameRepository: const _FakeGameRepository(activity),
        searchRepository: _FakeSearchRepository(),
        locationRepository: const _FakeLocationRepository(),
      );

      bloc.add(const MapEventLoadMap());
      await bloc.stream.firstWhere(
        (state) => state is MapStateLoadedMap && !state.isLoading,
      );

      bloc.add(
        const MapEventActivityFilterToggled(ActivityStatusFilter.finished),
      );
      var state =
          await bloc.stream.firstWhere(
                (state) =>
                    state is MapStateLoadedMap &&
                    state.activityFilter == ActivityStatusFilter.finished,
              )
              as MapStateLoadedMap;
      expect(state.activities, isEmpty);

      bloc.add(
        const MapEventActivityFilterToggled(ActivityStatusFilter.finished),
      );
      state =
          await bloc.stream.firstWhere(
                (state) =>
                    state is MapStateLoadedMap && state.activityFilter == null,
              )
              as MapStateLoadedMap;
      expect(state.activities, [activity]);

      await bloc.close();
    },
  );
}

class _FakeGameRepository implements GameRepository {
  const _FakeGameRepository(this.activity);

  final DatabaseActivity activity;

  @override
  Future<GameCatalog> loadCatalog() async =>
      GameCatalog(places: const [], activities: [activity]);

  @override
  Future<void> updateActivityDone(DatabaseActivity activity) async {}

  @override
  Future<List<DatabaseNote>> loadNotes(String activityId) async => const [];

  @override
  Future<DatabaseNote> saveNote(DatabaseNote note) async => note;

  @override
  Future<DatabaseNote> updateNote(
    DatabaseNote previousNote,
    DatabaseNote updatedNote,
  ) async => updatedNote;

  @override
  Future<void> deleteNote(DatabaseNote note) async {}
}

class _FakeLocationRepository implements LocationRepository {
  const _FakeLocationRepository({this.error});

  final Exception? error;

  @override
  Future<Coordinates> getCurrentLocation() async {
    if (error case final error?) {
      throw error;
    }
    return const Coordinates(latitude: 50, longitude: 20);
  }
}

class _FakeSearchRepository implements PlaceSearchRepository {
  final Map<String, Completer<List<AddressModel>>> requests = {};

  @override
  Future<List<AddressModel>> search(String query) {
    return (requests[query] ??= Completer<List<AddressModel>>()).future;
  }

  @override
  void close() {}
}
