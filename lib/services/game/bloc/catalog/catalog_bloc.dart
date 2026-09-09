import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:touring_game/core/search_filters.dart';
import 'package:touring_game/models/activity.dart';
import 'package:touring_game/models/place.dart';
import 'package:touring_game/services/game/bloc/catalog/catalog_event.dart';
import 'package:touring_game/services/game/bloc/catalog/catalog_state.dart';
import 'package:touring_game/services/game/game_repository.dart';

class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  CatalogBloc(this._repository, {Random? random})
    : _random = random ?? Random(),
      super(const CatalogState()) {
    on<CatalogLoadRequested>(_load, transformer: restartable());
    on<CatalogSearchChanged>(_search);
  }

  final CatalogRepository _repository;
  final Random _random;
  List<DatabasePlace> _allPlaces = const [];
  List<DatabaseActivity> _activities = const [];
  String _query = '';

  Future<void> _load(
    CatalogLoadRequested event,
    Emitter<CatalogState> emit,
  ) async {
    emit(
      CatalogState(
        places: state.places,
        activities: state.activities,
        suggestedActivities: state.suggestedActivities,
        isLoading: true,
        query: _query,
      ),
    );
    try {
      final catalog = await _repository.loadCatalog();
      _allPlaces = List.unmodifiable(catalog.places);
      _activities = List.unmodifiable(catalog.activities);
      final unfinished =
          _activities
              .where((activity) => !activity.isDone)
              .toList(growable: false)
            ..shuffle(_random);
      final suggestions = List<DatabaseActivity>.unmodifiable(
        unfinished.take(3),
      );
      emit(
        CatalogState(
          places: List.unmodifiable(searchWithText(_allPlaces, _query)),
          activities: _activities,
          suggestedActivities: suggestions,
          query: _query,
        ),
      );
    } on Exception catch (error) {
      emit(
        CatalogState(
          places: state.places,
          activities: state.activities,
          suggestedActivities: state.suggestedActivities,
          exception: error,
          query: _query,
        ),
      );
    }
  }

  void _search(CatalogSearchChanged event, Emitter<CatalogState> emit) {
    _query = event.query;
    emit(
      CatalogState(
        places: List.unmodifiable(searchWithText(_allPlaces, _query)),
        activities: _activities,
        suggestedActivities: state.suggestedActivities,
        isLoading: state.isLoading,
        query: _query,
      ),
    );
  }
}
