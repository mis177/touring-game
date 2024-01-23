import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:touring_game/models/activity.dart';
import 'package:touring_game/models/address.dart';
import 'package:touring_game/services/game/game_service.dart';
import 'package:touring_game/services/map/bloc/map_event.dart';
import 'package:touring_game/services/map/bloc/map_state.dart';
import 'package:touring_game/services/map/location_search_repo.dart';
import 'package:touring_game/utilities/map/current_location.dart';
import 'package:touring_game/utilities/search_list.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc(
      FirebaseCloudGameService service, LocationSearchRepository? repository)
      : super(const MapStateUninitialized(isLoading: true)) {
    on<MapEventLoadMap>((event, emit) async {
      List<DatabaseActivity> activitiesList = [];

      emit(const MapStateLoadingMap(
          isLoading: true, loadingText: 'Loading map'));
      if (service.places.isEmpty) {
        try {
          await service.allPlaces();
        } on Exception catch (e) {
          emit(MapStateLoadingMap(
            exception: e,
          ));
        }
      }

      activitiesList = service.allActivities;
      emit(MapStateLoadingMarkers(
          activities: activitiesList,
          isLoading: true,
          loadingText: 'Loading map'));
      Position? currentPosition = await getUserLocation();
      emit(MapStateLoadedMap(
        activities: activitiesList,
        currentLocation: currentPosition,
        searchResults: const [],
      ));
    });

    on<MapEventGetUserLocation>((event, emit) async {
      Position? currentPosition = await getUserLocation();

      emit(const MapStateGettingUserLocation());
      emit(MapStateLoadedMap(
        activities: service.allActivities,
        currentLocation: currentPosition,
        searchResults: const [],
      ));
    });

    on<MapEventSearchAddress>((event, emit) async {
      List<AddressModel> addresses = [];
      try {
        addresses = await repository!.fetchAddress(event.searchedText);
      } on Exception catch (e) {
        emit(MapStateSearchingAddress(
          exception: e,
        ));
      }

      emit(MapStateAddressSearchEnded(repo: addresses));
      emit(MapStateLoadedMap(
        activities: service.allActivities,
        currentLocation: null,
        searchResults: addresses,
      ));
    });

    on<MapEventSearchActivitiesFinished>((event, emit) {
      List searchedActivities = service.allActivities;

      if (event.value) {
        searchedActivities = searchWithActivityFinished(
          list: service.allActivities,
          finished: event.finished,
          value: event.value,
        );
      }
      emit(MapStateLoadingMarkers(
          activities: searchedActivities as List<DatabaseActivity>));

      emit(MapStateLoadedMap(
        activities: searchedActivities,
        currentLocation: null,
        searchResults: const [],
      ));
    });
  }
}
