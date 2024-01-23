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
  const GameStateUninitialized({super.isLoading});
}

class GameStateLoadingPlaces extends GameState {
  final Exception? exception;
  const GameStateLoadingPlaces({
    this.exception,
    super.isLoading,
    super.loadingText = null,
  });
}

class GameStateLoadedPlaces extends GameState {
  final List<DatabasePlace> placesList;
  final List<DatabaseActivity> activitiesList;
  const GameStateLoadedPlaces({
    required this.placesList,
    required this.activitiesList,
  });
}

class GameStateLoadingActivities extends GameState {
  final Exception? exception;
  const GameStateLoadingActivities({
    this.exception,
    super.isLoading,
    super.loadingText = null,
  });
}

class GameStateLoadedActivities extends GameState {
  final List<DatabaseActivity> activitiesList;
  const GameStateLoadedActivities({required this.activitiesList});
}

class GameStateLoadingActivityDetails extends GameState {
  final Exception? exception;
  const GameStateLoadingActivityDetails({
    this.exception,
    super.isLoading,
    super.loadingText = null,
  });
}

class GameStateLoadedActivityDetails extends GameState {
  final Widget activityImage;
  const GameStateLoadedActivityDetails({required this.activityImage});
}
