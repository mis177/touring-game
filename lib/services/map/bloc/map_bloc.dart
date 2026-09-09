import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:touring_game/models/activity.dart';
import 'package:touring_game/models/address.dart';
import 'package:touring_game/models/coordinates.dart';
import 'package:touring_game/services/game/game_repository.dart';
import 'package:touring_game/services/map/bloc/map_event.dart';
import 'package:touring_game/services/map/bloc/map_state.dart';
import 'package:touring_game/services/map/location_repository.dart';
import 'package:touring_game/services/map/place_search_repository.dart';
import 'package:touring_game/core/search_filters.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc({
    required CatalogRepository gameRepository,
    required PlaceSearchRepository searchRepository,
    required LocationRepository locationRepository,
  }) : _gameRepository = gameRepository,
       _searchRepository = searchRepository,
       _locationRepository = locationRepository,
       super(const MapStateUninitialized(isLoading: true)) {
    on<MapEventLoadMap>(_loadMap, transformer: restartable());
    on<MapEventGetUserLocation>(_getUserLocation, transformer: droppable());
    on<MapEventSearchAddress>(_searchAddress, transformer: restartable());
    on<MapEventActivityFilterToggled>(_toggleActivityFilter);
    on<MapEventAddressResultsCleared>(_clearAddressResults);
  }

  final CatalogRepository _gameRepository;
  final PlaceSearchRepository _searchRepository;
  final LocationRepository _locationRepository;

  List<DatabaseActivity> _activities = const [];
  Coordinates? _currentLocation;
  ActivityStatusFilter? _activityFilter;

  Future<void> _loadMap(MapEventLoadMap event, Emitter<MapState> emit) async {
    emit(const MapStateLoadingMap(isLoading: true, loadingText: 'Loading map'));
    try {
      final catalog = await _gameRepository.loadCatalog();
      _activities = catalog.activities;
      emit(_loadedMap(isLoading: true, loadingText: 'Loading map'));
      try {
        _currentLocation = await _locationRepository.getCurrentLocation();
        emit(_loadedMap());
      } on Exception catch (error) {
        emit(_loadedMap(exception: error));
      }
    } on Exception catch (error) {
      emit(MapStateLoadingMap(exception: error));
    }
  }

  Future<void> _getUserLocation(
    MapEventGetUserLocation event,
    Emitter<MapState> emit,
  ) async {
    emit(_loadedMap(isLoading: true, loadingText: 'Getting current location'));
    try {
      _currentLocation = await _locationRepository.getCurrentLocation();
      emit(_loadedMap());
    } on Exception catch (error) {
      emit(_loadedMap(exception: error));
    }
  }

  Future<void> _searchAddress(
    MapEventSearchAddress event,
    Emitter<MapState> emit,
  ) async {
    final query = event.searchedText.trim();
    if (query.isEmpty) {
      emit(_loadedMap());
      return;
    }

    emit(_loadedMap(isLoading: true, loadingText: 'Searching address'));
    try {
      final addresses = await _searchRepository.search(query);
      emit(_loadedMap(searchResults: addresses));
    } on Exception catch (error) {
      emit(_loadedMap(exception: error));
    }
  }

  void _toggleActivityFilter(
    MapEventActivityFilterToggled event,
    Emitter<MapState> emit,
  ) {
    _activityFilter = _activityFilter == event.filter ? null : event.filter;
    emit(_loadedMap());
  }

  void _clearAddressResults(
    MapEventAddressResultsCleared event,
    Emitter<MapState> emit,
  ) {
    emit(_loadedMap());
  }

  MapStateLoadedMap _loadedMap({
    List<AddressModel> searchResults = const [],
    bool isLoading = false,
    String? loadingText,
    Exception? exception,
  }) {
    final filteredActivities = _activityFilter == null
        ? _activities
        : searchWithActivityFinished(
            list: _activities,
            finished: _activityFilter == ActivityStatusFilter.finished,
          );
    return MapStateLoadedMap(
      activities: List.unmodifiable(filteredActivities),
      currentLocation: _currentLocation,
      searchResults: List.unmodifiable(searchResults),
      activityFilter: _activityFilter,
      isLoading: isLoading,
      loadingText: loadingText,
      exception: exception,
    );
  }
}
