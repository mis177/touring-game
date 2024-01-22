import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:touring_game/models/activity.dart';
import 'package:touring_game/models/place.dart';
import 'package:touring_game/services/game/bloc/game_event.dart';
import 'package:touring_game/services/game/bloc/game_state.dart';
import 'package:touring_game/services/game/game_service.dart';
import 'package:touring_game/utilities/search_list.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  GameBloc(FirebaseCloudGameService service)
      : super(const GameStateUninitialized(isLoading: true)) {
    on<GameEventLoadPlaces>((event, emit) async {
      if (service.places.isEmpty) {
        emit(const GameStateLoadingPlaces(
            isLoading: true, loadingText: 'Loading places'));
        List<DatabasePlace> placeslist = [];
        try {
          placeslist = await service.allPlaces();
          event.places = placeslist;
        } on Exception catch (e) {
          emit(GameStateLoadingPlaces(
            exception: e,
          ));
        }
        emit(GameStateLoadedPlaces(placeslist: event.places));
      } else {
        emit(GameStateLoadedPlaces(placeslist: service.places));
      }
    });

    on<GameEventLoadActivities>((event, emit) async {
      emit(const GameStateLoadingActivities(
          isLoading: true, loadingText: 'Loading activities'));

      List<DatabaseActivity> activitiesList = [];

      try {
        activitiesList =
            await service.getPlaceActivities(placeId: event.placeId);
      } on Exception catch (e) {
        emit(GameStateLoadingActivities(
          exception: e,
        ));
      }

      emit(GameStateLoadedActivities(activitiesList: activitiesList));
    });

    on<GameEventLoadActivityDetails>((event, emit) async {
      emit(const GameStateLoadingActivityDetails(
          isLoading: true, loadingText: 'Loading activity details'));

      Widget activityImage;
      try {
        activityImage = await service.getImage(path: event.activity.imagePath);
      } on Exception catch (e) {
        activityImage = const Text('Error while loading image');
        emit(GameStateLoadingActivityDetails(
          exception: e,
        ));
      }

      emit(GameStateLoadedActivityDetails(activityImage: activityImage));
    });

    on<GameEventActivityDone>((event, emit) {
      try {
        service.activityDoneChanged(event.activity);
      } on Exception catch (e) {
        emit(GameStateLoadingActivityDetails(
          exception: e,
        ));
      }

      emit(GameStateLoadedActivityDetails(activityImage: event.activityImage));
    });

    on<GameEventSearchPlaces>((event, emit) {
      List searchedPlaces = [];
      searchedPlaces = searchWithText(event.places, event.text);

      emit(GameStateLoadedPlaces(
          placeslist: searchedPlaces as List<DatabasePlace>));
    });

    on<GameEventSearchActivitiesText>((event, emit) {
      List searchedActivities = [];
      searchedActivities = searchWithText(event.activities, event.text);

      emit(GameStateLoadedActivities(
          activitiesList: searchedActivities as List<DatabaseActivity>));
    });

    on<GameEventSearchActivitiesFinished>((event, emit) {
      List searchedActivities = [];
      if (event.value) {
        searchedActivities = searchWithActivityFinished(
          list: event.activities,
          finished: event.finished,
          value: event.value,
        );
      } else {
        searchedActivities = event.activities;
      }

      emit(GameStateLoadedActivities(
          activitiesList: searchedActivities as List<DatabaseActivity>));
    });
  }
}
