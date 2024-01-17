import 'package:flutter/material.dart' show Widget, immutable;
import 'package:touring_game/models/activity.dart';
import 'package:touring_game/models/place.dart';

@immutable
sealed class GameState {
  final bool isLoading;
  final String? loadingText;
  const GameState({
    this.isLoading = false,
    this.loadingText = 'Please wait a moment',
  });
}

class GameStateUninitialized extends GameState {
  const GameStateUninitialized({bool isLoading = false})
      : super(isLoading: isLoading);
}

class GameStateLoadingPlaces extends GameState {
  final Exception? exception;
  const GameStateLoadingPlaces({
    this.exception,
    bool isLoading = false,
    String? loadingText,
  }) : super(
          isLoading: isLoading,
          loadingText: loadingText,
        );
}

class GameStateLoadedPlaces extends GameState {
  final List<DatabasePlace> placeslist;
  const GameStateLoadedPlaces({required this.placeslist});
}

class GameStateLoadingActivities extends GameState {
  final Exception? exception;
  const GameStateLoadingActivities({
    this.exception,
    bool isLoading = false,
    String? loadingText,
  }) : super(
          isLoading: isLoading,
          loadingText: loadingText,
        );
}

class GameStateLoadedActivities extends GameState {
  final List<DatabaseActivity> activitiesList;
  const GameStateLoadedActivities({required this.activitiesList});
}

class GameStateLoadingActivityDetails extends GameState {
  final Exception? exception;
  const GameStateLoadingActivityDetails({
    this.exception,
    bool isLoading = false,
    String? loadingText,
  }) : super(
          isLoading: isLoading,
          loadingText: loadingText,
        );
}

class GameStateLoadedActivityDetails extends GameState {
  final Widget activityImage;
  const GameStateLoadedActivityDetails({required this.activityImage});
}
