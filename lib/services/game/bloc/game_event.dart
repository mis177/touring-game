import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:touring_game/models/activity.dart';
import 'package:touring_game/models/place.dart';

sealed class GameEvent extends Equatable {
  const GameEvent();
  @override
  List<Object?> get props => [];
}

class GameEventLoadPlaces extends GameEvent {
  const GameEventLoadPlaces();
}

class GameEventLoadActivities extends GameEvent {
  final String placeId;

  const GameEventLoadActivities({
    required this.placeId,
  });
  @override
  List<Object?> get props => [placeId];
}

class GameEventLoadActivityDetails extends GameEvent {
  final DatabaseActivity activity;

  const GameEventLoadActivityDetails({
    required this.activity,
  });
  @override
  List<Object?> get props => [activity.id];
}

class GameEventActivityDone extends GameEvent {
  final Widget activityImage;
  final DatabaseActivity activity;

  const GameEventActivityDone({
    required this.activity,
    required this.activityImage,
  });
  @override
  List<Object?> get props => [activity.id];
}

class GameEventSearchPlaces extends GameEvent {
  final String text;
  final List<DatabasePlace> places;

  const GameEventSearchPlaces({required this.text, required this.places});
  @override
  List<Object?> get props => [text];
}

class GameEventSearchActivitiesText extends GameEvent {
  final String text;
  final List<DatabaseActivity> activities;

  const GameEventSearchActivitiesText(
      {required this.text, required this.activities});
  @override
  List<Object?> get props => [text];
}

class GameEventSearchActivitiesFinished extends GameEvent {
  final bool finished;
  final bool value;
  final List<DatabaseActivity> activities;

  const GameEventSearchActivitiesFinished(
      {required this.finished, required this.value, required this.activities});
}
