import 'package:equatable/equatable.dart';
import 'package:touring_game/models/activity.dart';
import 'package:touring_game/models/note.dart';
import 'package:touring_game/models/place.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
  final WebViewController webController;
  final DatabaseActivity activity;

  const GameEventActivityDone({
    required this.activity,
    required this.webController,
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

class GameEventLoadNotes extends GameEvent {
  final String activityId;

  const GameEventLoadNotes({
    required this.activityId,
  });
  @override
  List<Object?> get props => [activityId];
}

class GameEventAddNote extends GameEvent {
  final DatabaseNote databaseNote;

  const GameEventAddNote({
    required this.databaseNote,
  });
  @override
  List<Object?> get props => [databaseNote.id];
}

class GameEventDeleteNote extends GameEvent {
  final DatabaseNote databaseNote;

  const GameEventDeleteNote({
    required this.databaseNote,
  });
  @override
  List<Object?> get props => [databaseNote.id];
}

class GameEventUpdateNotes extends GameEvent {
  final List<DatabaseNote> databaseNotes;

  const GameEventUpdateNotes({
    required this.databaseNotes,
  });
  @override
  List<Object?> get props => [];
}

class GameEventDeleteImageFromStorage extends GameEvent {
  final String imagePath;

  const GameEventDeleteImageFromStorage({
    required this.imagePath,
  });
  @override
  List<Object?> get props => [imagePath];
}
