import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:touring_game/models/activity.dart';
import 'package:touring_game/models/address.dart';
import 'package:touring_game/models/place.dart';
import 'package:touring_game/services/game/game_service.dart';
import 'package:touring_game/services/map/bloc/map_event.dart';
import 'package:touring_game/services/map/bloc/map_state.dart';
import 'package:touring_game/services/map/location_search_repo.dart';
import 'package:touring_game/utilities/map/current_location.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc(
      FirebaseCloudGameService service, LocationSearchRepository? repository)
      : super(const MapStateUninitialized(isLoading: true)) {
    on<MapEventLoadMap>((event, emit) async {
      List<DatabasePlace> placesList = [];
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
      placesList = service.places;

      try {
        activitiesList = await service.getAllActivities(placesList);
      } on Exception catch (e) {
        emit(MapStateLoadingMap(
          exception: e,
        ));
      }

      final Position? currentLocation = await getUserLocation();

      emit(MapStateLoadedMap(
        activities: activitiesList,
        currentLocation: currentLocation,
        searchResults: const [],
      ));
    });

    on<MapEventGetUserLocation>((event, emit) async {
      Position? userLocation = await getUserLocation();

      emit(MapStateLoadedMap(
        activities: service.allActivities,
        currentLocation: userLocation,
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
  }
}
