import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:touring_game/core/search_filters.dart';
import 'package:touring_game/models/activity.dart';

export 'package:touring_game/core/search_filters.dart'
    show ActivityStatusFilter;

class ActivitiesState extends Equatable {
  const ActivitiesState({
    required this.activities,
    this.filter,
    this.query = '',
  });

  final List<DatabaseActivity> activities;
  final ActivityStatusFilter? filter;
  final String query;

  @override
  List<Object?> get props => [activities, filter, query];
}

class ActivitiesCubit extends Cubit<ActivitiesState> {
  ActivitiesCubit(List<DatabaseActivity> activities)
    : _allActivities = List.unmodifiable(activities),
      super(ActivitiesState(activities: List.unmodifiable(activities)));

  List<DatabaseActivity> _allActivities;

  void search(String query) => _emitFiltered(query, state.filter);

  void toggleFilter(ActivityStatusFilter filter) {
    _emitFiltered(state.query, state.filter == filter ? null : filter);
  }

  void replace(DatabaseActivity activity) {
    _allActivities = List.unmodifiable(
      _allActivities.map(
        (current) => current.id == activity.id ? activity : current,
      ),
    );
    _emitFiltered(state.query, state.filter);
  }

  void _emitFiltered(String query, ActivityStatusFilter? filter) {
    Iterable<DatabaseActivity> filtered = searchWithText(_allActivities, query);
    if (filter != null) {
      filtered = searchWithActivityFinished(
        list: filtered.toList(growable: false),
        finished: filter == ActivityStatusFilter.finished,
      );
    }
    emit(
      ActivitiesState(
        activities: List.unmodifiable(filtered),
        filter: filter,
        query: query,
      ),
    );
  }
}
