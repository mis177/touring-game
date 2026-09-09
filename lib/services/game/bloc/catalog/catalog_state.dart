import 'package:equatable/equatable.dart';
import 'package:touring_game/models/activity.dart';
import 'package:touring_game/models/place.dart';

class CatalogState extends Equatable {
  const CatalogState({
    this.places = const [],
    this.activities = const [],
    this.suggestedActivities = const [],
    this.isLoading = false,
    this.exception,
    this.query = '',
  });

  final List<DatabasePlace> places;
  final List<DatabaseActivity> activities;
  final List<DatabaseActivity> suggestedActivities;
  final bool isLoading;
  final Exception? exception;
  final String query;

  @override
  List<Object?> get props => [
    places,
    activities,
    suggestedActivities,
    isLoading,
    exception,
    query,
  ];
}
