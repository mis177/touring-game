import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:touring_game/models/activity.dart';
import 'package:touring_game/services/game/game_repository.dart';

class ActivityDetailsState extends Equatable {
  const ActivityDetailsState({
    required this.activity,
    this.isSaving = false,
    this.exception,
  });

  final DatabaseActivity activity;
  final bool isSaving;
  final Exception? exception;

  @override
  List<Object?> get props => [activity, isSaving, exception];
}

class ActivityDetailsCubit extends Cubit<ActivityDetailsState> {
  ActivityDetailsCubit(this._repository, DatabaseActivity activity)
    : super(ActivityDetailsState(activity: activity));

  final ActivityProgressRepository _repository;

  Future<void> updateDone(bool isDone) async {
    if (state.isSaving || state.activity.isDone == isDone) {
      return;
    }
    final previous = state.activity;
    final updated = previous.copyWith(isDone: isDone);
    emit(ActivityDetailsState(activity: updated, isSaving: true));
    try {
      await _repository.updateActivityDone(updated);
      emit(ActivityDetailsState(activity: updated));
    } on Exception catch (error) {
      emit(ActivityDetailsState(activity: previous, exception: error));
    }
  }
}
