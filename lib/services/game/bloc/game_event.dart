import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:touring_game/models/activity.dart';
import 'package:touring_game/models/place.dart';

sealed class GameEvent extends Equatable {
  const GameEvent();
  @override
  List<Object?> get props => [];
}

class GameEventLoadPlaces extends GameEvent {
  List<DatabasePlace> places;
  GameEventLoadPlaces({this.places = const []});
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

class GameEventSearchActivities extends GameEvent {
  final String text;
  final List<DatabaseActivity> activities;

  const GameEventSearchActivities(
      {required this.text, required this.activities});
  @override
  List<Object?> get props => [text];
}
