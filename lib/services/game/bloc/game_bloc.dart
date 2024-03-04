import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:touring_game/models/activity.dart';
import 'package:touring_game/models/place.dart';
import 'package:touring_game/services/game/bloc/game_event.dart';
import 'package:touring_game/services/game/bloc/game_state.dart';
import 'package:touring_game/services/game/game_service.dart';
import 'package:touring_game/utilities/search_list.dart';
import 'package:webview_flutter/webview_flutter.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  GameBloc(FirebaseCloudGameService service)
      : super(const GameStateUninitialized(isLoading: true)) {
    on<GameEventLoadPlaces>((event, emit) async {
      service.activityNotes = [];
      if (service.places.isEmpty) {
        emit(const GameStateLoadingPlaces(
            isLoading: true, loadingText: 'Loading places'));
        try {
          await service.allPlaces();
        } on Exception catch (e) {
          emit(GameStateLoadingPlaces(
            exception: e,
          ));
        }
      }

      emit(GameStateLoadedPlaces(
          placesList: service.places, activitiesList: service.allActivities));
    });

    on<GameEventLoadActivities>((event, emit) {
      emit(const GameStateLoadingActivities(
          isLoading: true, loadingText: 'Loading activities'));

      List<DatabaseActivity> activitiesList = [];

      try {
        activitiesList = service.getPlaceActivities(placeId: event.placeId);
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
      var webController = WebViewController();
      await webController.loadRequest(Uri.parse(event.activity.webUrl));

      emit(GameStateLoadedActivityDetails(webController: webController));
    });

    on<GameEventActivityDone>((event, emit) {
      try {
        service.activityDoneChanged(event.activity);
      } on Exception catch (e) {
        emit(GameStateLoadingActivityDetails(
          exception: e,
        ));
      }

      emit(GameStateLoadedActivityDetails(webController: event.webController));
    });

    on<GameEventSearchPlaces>((event, emit) {
      List searchedPlaces = [];
      searchedPlaces = searchWithText(event.places, event.text);

      emit(GameStateLoadedPlaces(
          placesList: searchedPlaces as List<DatabasePlace>,
          activitiesList: service.allActivities));
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

    on<GameEventLoadNotes>((event, emit) async {
      emit(const GameStateLoadingNotes(
          isLoading: true, loadingText: 'Loading notes'));

      if (service.activityNotes.isEmpty) {
        await service.getActivityNotes(activityId: event.activityId);
      }

      emit(GameStateLoadedNotes(activityNotes: service.activityNotes));
    });

    on<GameEventAddNote>((event, emit) async {
      emit(const GameStateAddingNote());

      service.activityNotes.add(event.databaseNote);
      emit(GameStateLoadedNotes(activityNotes: service.activityNotes));
    });

    on<GameEventDeleteNote>((event, emit) async {
      emit(const GameStateDeletingNote());
      var noteImage = event.databaseNote.content.image;
      // check if file is from firebase storage
      if (noteImage is NetworkImage) {
        await service.deleteImageFromStorage(
            imagePath: event.databaseNote.imagePath!);
      }
      service.deleteNote(note: event.databaseNote);

      emit(GameStateLoadedNotes(activityNotes: service.activityNotes));
    });

    on<GameEventUpdateNotes>((event, emit) async {
      emit(const GameStateUpdatingNotes());

      for (var note in event.databaseNotes) {
        await service.addActivityNote(note: note);
      }
      service.activityNotes = [];

      emit(GameStateLoadedNotes(activityNotes: service.activityNotes));
    });

    on<GameEventDeleteImageFromStorage>((event, emit) async {
      emit(const GameStateDeletingImageFromStorage());
      await service.deleteImageFromStorage(imagePath: event.imagePath);
      emit(GameStateLoadedNotes(activityNotes: service.activityNotes));
    });
  }
}
